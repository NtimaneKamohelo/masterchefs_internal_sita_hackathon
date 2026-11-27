import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/app_user.dart';

enum AuthStatus { unknown, authenticated, unverified, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
    this.infoMessage,
    this.verificationCode,
    this.resetCode,
    this.resetEmail,
    this.openResetPage = false,
    this.passwordResetCompleted = false,
    required this.issuesOutOfBandCodes,
  });

  final AuthStatus status;
  final AppUser? user;
  final bool isSubmitting;
  final String? errorMessage;
  final String? infoMessage;
  final String? verificationCode;
  final String? resetCode;
  final String? resetEmail;
  final bool openResetPage;
  final bool passwordResetCompleted;
  final bool issuesOutOfBandCodes;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
    String? verificationCode,
    bool clearVerificationCode = false,
    String? resetCode,
    bool clearResetCode = false,
    String? resetEmail,
    bool clearResetEmail = false,
    bool? openResetPage,
    bool? passwordResetCompleted,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      verificationCode: clearVerificationCode
          ? null
          : (verificationCode ?? this.verificationCode),
      resetCode: clearResetCode ? null : (resetCode ?? this.resetCode),
      resetEmail: clearResetEmail ? null : (resetEmail ?? this.resetEmail),
      openResetPage: openResetPage ?? this.openResetPage,
      passwordResetCompleted:
          passwordResetCompleted ?? this.passwordResetCompleted,
      issuesOutOfBandCodes: issuesOutOfBandCodes,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    isSubmitting,
    errorMessage,
    infoMessage,
    verificationCode,
    resetCode,
    resetEmail,
    openResetPage,
    passwordResetCompleted,
    issuesOutOfBandCodes,
  ];
}
