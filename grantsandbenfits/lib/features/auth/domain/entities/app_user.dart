import 'package:equatable/equatable.dart';

enum AuthProviderKind { email, google }

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.emailVerified,
    required this.provider,
    required this.isSynthetic,
  });

  final String id;
  final String email;
  final String displayName;
  final bool emailVerified;
  final AuthProviderKind provider;
  final bool isSynthetic;

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    emailVerified,
    provider,
    isSynthetic,
  ];
}
