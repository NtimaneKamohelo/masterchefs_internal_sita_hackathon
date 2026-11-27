import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/app_user.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final AppUser? user;

  @override
  List<Object?> get props => [user];
}

final class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({
    required this.email,
    required this.password,
    required this.honeypot,
    required this.formOpenedAt,
  });

  final String email;
  final String password;
  final String honeypot;
  final DateTime formOpenedAt;

  @override
  List<Object?> get props => [email, password, honeypot, formOpenedAt];
}

final class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmation,
    required this.popiaConsent,
    required this.honeypot,
    required this.formOpenedAt,
  });

  final String name;
  final String email;
  final String password;
  final String confirmation;
  final bool popiaConsent;
  final String honeypot;
  final DateTime formOpenedAt;

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    confirmation,
    popiaConsent,
    honeypot,
    formOpenedAt,
  ];
}

final class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested({
    required this.honeypot,
    required this.formOpenedAt,
  });

  final String honeypot;
  final DateTime formOpenedAt;

  @override
  List<Object?> get props => [honeypot, formOpenedAt];
}

final class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested({
    required this.email,
    required this.honeypot,
    required this.formOpenedAt,
  });

  final String email;
  final String honeypot;
  final DateTime formOpenedAt;

  @override
  List<Object?> get props => [email, honeypot, formOpenedAt];
}

final class AuthPasswordResetConfirmed extends AuthEvent {
  const AuthPasswordResetConfirmed({
    required this.email,
    required this.code,
    required this.newPassword,
    required this.confirmation,
  });

  final String email;
  final String code;
  final String newPassword;
  final String confirmation;

  @override
  List<Object?> get props => [email, code, newPassword, confirmation];
}

final class AuthVerificationResendRequested extends AuthEvent {
  const AuthVerificationResendRequested();
}

final class AuthVerificationConfirmed extends AuthEvent {
  const AuthVerificationConfirmed(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
