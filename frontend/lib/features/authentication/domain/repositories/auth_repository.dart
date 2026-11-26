import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> register({required String email, required String password});

  Future<AuthUser> login({required String email, required String password});

  Future<void> logout();

  Future<void> resetPassword({required String email});

  Future<void> resendVerificationEmail({required String email});

  Future<void> updatePassword({required String password});

  AuthUser? getCurrentUser;
}
