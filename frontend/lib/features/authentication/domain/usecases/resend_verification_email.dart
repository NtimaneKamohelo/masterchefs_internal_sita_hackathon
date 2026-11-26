import '../repositories/auth_repository.dart';

class ResendVerificationEmail {
  final AuthRepository repository;

  ResendVerificationEmail(this.repository);

  Future<void> call({required String email}) {
    return repository.resendVerificationEmail(email: email);
  }
}
