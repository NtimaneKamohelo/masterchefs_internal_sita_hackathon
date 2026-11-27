import 'package:grantsandbenfits/core/error/failure.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/auth/data/auth_audit_logger.dart';
import 'package:grantsandbenfits/features/auth/data/auth_exception.dart';
import 'package:grantsandbenfits/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/app_user.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/auth_session.dart';
import 'package:grantsandbenfits/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthAuditLogger audit,
  }) : _remote = remote,
       _audit = audit;

  final AuthRemoteDataSource _remote;
  final AuthAuditLogger _audit;

  @override
  bool get issuesOutOfBandCodes => _remote.issuesOutOfBandCodes;

  @override
  Stream<AppUser?> watchAuthState() => _remote.watch();

  @override
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final user = await _remote.signInWithEmail(
        email: email,
        password: password,
      );
      await _record('sign_in', user.id);
      return user;
    });
  }

  @override
  Future<Result<AuthSession>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required bool popiaConsent,
  }) {
    return _guard(() async {
      final session = await _remote.signUpWithEmail(
        name: name,
        email: email,
        password: password,
        popiaConsent: popiaConsent,
      );
      await _record('sign_up', session.user.id);
      return session;
    });
  }

  @override
  Future<Result<AppUser>> signInWithGoogle() {
    return _guard(() async {
      final user = await _remote.signInWithGoogle();
      await _record('sign_in_google', user.id);
      return user;
    });
  }

  @override
  Future<Result<String?>> sendPasswordReset({required String email}) {
    return _guard(() async {
      final code = await _remote.sendPasswordReset(email: email);
      await _record('password_reset_requested', null);
      return code;
    });
  }

  @override
  Future<Result<Completed>> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _guard(() async {
      await _remote.confirmPasswordReset(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      await _record('password_reset_confirmed', null);
      return const Completed();
    });
  }

  @override
  Future<Result<String?>> sendEmailVerification() {
    return _guard(() async {
      final code = await _remote.sendEmailVerification();
      await _record('verification_email_requested', null);
      return code;
    });
  }

  @override
  Future<Result<AppUser>> confirmEmailVerification({required String code}) {
    return _guard(() async {
      final user = await _remote.confirmEmailVerification(code: code);
      await _record('email_verified', user.id);
      return user;
    });
  }

  @override
  Future<Result<Completed>> signOut() {
    return _guard(() async {
      await _remote.signOut();
      await _record('sign_out', null);
      return const Completed();
    });
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on AuthCancelledException {
      return Err(const CancelledFailure());
    } on AuthException catch (error) {
      return Err(AuthFailure(error.message));
    } catch (_) {
      return const Err(AuthFailure('Something went wrong. Try again.'));
    }
  }

  Future<void> _record(String action, String? userId) async {
    try {
      await _audit.log(action: action, userId: userId);
    } catch (_) {
      reportAuditFailure();
    }
  }
}
