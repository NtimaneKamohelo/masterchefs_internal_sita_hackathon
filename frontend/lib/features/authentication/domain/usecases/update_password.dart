import '../repositories/auth_repository.dart';

class UpdatePassword {
  final AuthRepository repository;

  UpdatePassword(this.repository);

  Future<void> call({required String password}) {
    return repository.updatePassword(password: password);
  }
}
