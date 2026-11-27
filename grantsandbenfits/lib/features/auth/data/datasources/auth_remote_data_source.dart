import 'package:grantsandbenfits/features/auth/domain/entities/app_user.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/auth_session.dart';

abstract interface class AuthRemoteDataSource {
  bool get issuesOutOfBandCodes;

  Stream<AppUser?> watch();

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthSession> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required bool popiaConsent,
  });

  Future<AppUser> signInWithGoogle();

  Future<String?> sendPasswordReset({required String email});

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<String?> sendEmailVerification();

  Future<AppUser> confirmEmailVerification({required String code});

  Future<void> signOut();
}
