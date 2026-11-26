import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSource({required this.client});

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) {
    return client.auth.signUp(email: email, password: password);
  }

  /*Future<AuthResponse> register({
  required String email,
  required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      print('SUPABASE SIGNUP REQUEST COMPLETED');
      print('User created: ${response.user != null}');
      print('Session created: ${response.session != null}');

      return response;
    } on AuthException catch (e) {
      print('SUPABASE AUTH ERROR: ${e.message}');
      rethrow;
    } catch (e) {
      print('UNEXPECTED SIGNUP ERROR: $e');
      rethrow;
    }
  }*/

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() {
    return client.auth.signOut();
  }

  Future<void> resetPassword({required String email}) {
    return client.auth.resetPasswordForEmail(email);
  }

  Future<void> resendVerificationEmail({required String email}) {
    return client.auth.resend(type: OtpType.signup, email: email);
  }

  Future<UserResponse> updatePassword({required String password}) {
    return client.auth.updateUser(UserAttributes(password: password));
  }

  User? get currentUser => client.auth.currentUser;
}
