import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<AuthUser?> call({required String email, required String password}) {
    return repository.register(email: email, password: password);
  }
}
