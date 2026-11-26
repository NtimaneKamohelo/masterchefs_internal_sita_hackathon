import 'package:masterchefs_internal_sita_hackathon/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
//import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  AuthUser _mapUser(User user) {
    return AuthUser(id: user.id, email: user.email ?? '');
  }

  @override
  Future<AuthUser?> register({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.register(
      email: email.trim(),
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw const AuthException('Registration failed.');
    }

    if (response.session == null) {
      return null;
    }

    return _mapUser(user);
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      email: email.trim(),
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw const AuthException('Authentication failed.');
    }

    return _mapUser(user);
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  Future<void> resetPassword({required String email}) {
    return remoteDataSource.resetPassword(email: email.trim());
  }

  @override
  Future<void> resendVerificationEmail({required String email}) {
    return remoteDataSource.resendVerificationEmail(email: email.trim());
  }

  @override
  Future<void> updatePassword({required String password}) async {
    await remoteDataSource.updatePassword(password: password);
  }

  @override
  AuthUser? get getCurrentUser {
    final user = remoteDataSource.currentUser;

    return user == null ? null : _mapUser(user);
  }

  @override
  set getCurrentUser(AuthUser? value) {
    // TODO: implement getCurrentUser
  }
}
