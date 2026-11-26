import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSource({
    required this.client,
  });

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) {
    return client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() {
    return client.auth.signOut();
  }

  Future<void> resetPassword({
    required String email,
  }) {
    return client.auth.resetPasswordForEmail(email);
  }

  User? get currentUser => client.auth.currentUser;
}