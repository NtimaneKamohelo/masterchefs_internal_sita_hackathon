import 'package:masterchefs_internal_sita_hackathon/features/authentication/data/datasources/auth_remote_datasource.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
//import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  AuthUser _mapUser(dynamic user) {
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
    );
  }

  @override
  Future<AuthUser?> register({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.register(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Account registration failed.');
    }

    // When email confirmation is enabled,
    // Supabase returns a user without an active session.
    if (response.session == null) {
      return null;
    }

    return _mapUser(response.user!);
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Authentication failed.');
    }

    return _mapUser(response.user!);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) async {
    await remoteDataSource.resetPassword(
      email: email,
    );
  }

  @override
  AuthUser? get getCurrentUser {
    final user = remoteDataSource.currentUser;

    if (user == null) return null;

    return AuthUser(
      id: user.id,
      email: user.email ?? '',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}