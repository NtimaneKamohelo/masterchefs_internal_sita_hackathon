import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/app_user.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/auth_session.dart';

abstract interface class AuthRepository {
  /// True when verification and reset codes are returned on this device
  /// because no mail server is configured.
  bool get issuesOutOfBandCodes;

  Stream<AppUser?> watchAuthState();

  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AuthSession>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required bool popiaConsent,
  });

  Future<Result<AppUser>> signInWithGoogle();

  Future<Result<String?>> sendPasswordReset({required String email});

  Future<Result<Completed>> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<Result<String?>> sendEmailVerification();

  Future<Result<AppUser>> confirmEmailVerification({required String code});

  Future<Result<Completed>> signOut();
}
