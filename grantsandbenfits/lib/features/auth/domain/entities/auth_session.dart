import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/app_user.dart';

class AuthSession extends Equatable {
  const AuthSession({required this.user, this.demoCode});

  final AppUser user;
  final String? demoCode;

  @override
  List<Object?> get props => [user, demoCode];
}
