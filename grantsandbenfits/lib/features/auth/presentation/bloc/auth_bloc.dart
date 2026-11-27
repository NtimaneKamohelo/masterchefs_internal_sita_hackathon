import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantsandbenfits/core/error/failure.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/app_user.dart';
import 'package:grantsandbenfits/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_event.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required WatchAuthState watchAuthState,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SendPasswordReset sendPasswordReset,
    required ConfirmPasswordReset confirmPasswordReset,
    required SendEmailVerification sendEmailVerification,
    required ConfirmEmailVerification confirmEmailVerification,
    required SignOut signOut,
    required bool issuesOutOfBandCodes,
  }) : _watchAuthState = watchAuthState,
       _signInWithEmail = signInWithEmail,
       _signUpWithEmail = signUpWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _sendPasswordReset = sendPasswordReset,
       _confirmPasswordReset = confirmPasswordReset,
       _sendEmailVerification = sendEmailVerification,
       _confirmEmailVerification = confirmEmailVerification,
       _signOut = signOut,
       super(AuthState(issuesOutOfBandCodes: issuesOutOfBandCodes)) {
    on<AuthStarted>(_onStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthGoogleSignInRequested>(_onGoogle);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthPasswordResetConfirmed>(_onPasswordResetConfirmed);
    on<AuthVerificationResendRequested>(_onVerificationResend);
    on<AuthVerificationConfirmed>(_onVerificationConfirmed);
    on<AuthSignOutRequested>(_onSignOut);
  }

  final WatchAuthState _watchAuthState;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SendPasswordReset _sendPasswordReset;
  final ConfirmPasswordReset _confirmPasswordReset;
  final SendEmailVerification _sendEmailVerification;
  final ConfirmEmailVerification _confirmEmailVerification;
  final SignOut _signOut;
  StreamSubscription<AppUser?>? _authSubscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await _authSubscription?.cancel();
    _authSubscription = _watchAuthState().listen(
      (user) {
        if (!isClosed) add(AuthUserChanged(user));
      },
      onError: (_) {
        if (!isClosed) add(const AuthUserChanged(null));
      },
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    emit(
      state.copyWith(
        status: _statusFor(user),
        user: user,
        clearUser: user == null,
        clearVerificationCode: user == null || user.emailVerified,
        clearResetCode: user != null,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await _signInWithEmail(
      email: event.email,
      password: event.password,
      honeypot: event.honeypot,
      formOpenedAt: event.formOpenedAt,
    );
    _emitAuthResult(result, emit);
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await _signUpWithEmail(
      name: event.name,
      email: event.email,
      password: event.password,
      confirmation: event.confirmation,
      popiaConsent: event.popiaConsent,
      honeypot: event.honeypot,
      formOpenedAt: event.formOpenedAt,
    );
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            isSubmitting: false,
            status: _statusFor(value.user),
            user: value.user,
            verificationCode: value.demoCode,
            clearVerificationCode: value.demoCode == null,
            clearError: true,
          ),
        );
      case Err(:final failure):
        _emitFailure(failure, emit);
    }
  }

  Future<void> _onGoogle(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await _signInWithGoogle(
      honeypot: event.honeypot,
      formOpenedAt: event.formOpenedAt,
    );
    _emitAuthResult(result, emit);
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await _sendPasswordReset(
      email: event.email,
      honeypot: event.honeypot,
      formOpenedAt: event.formOpenedAt,
    );
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            isSubmitting: false,
            resetCode: value,
            clearResetCode: value == null,
            resetEmail: event.email.trim(),
            openResetPage: state.issuesOutOfBandCodes,
            passwordResetCompleted: false,
            clearError: true,
            infoMessage: value == null
                ? 'If an account exists for that email, password reset instructions are ready.'
                : 'Enter the demo reset code and choose a new password.',
          ),
        );
      case Err(:final failure):
        _emitFailure(failure, emit);
    }
  }

  Future<void> _onPasswordResetConfirmed(
    AuthPasswordResetConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await _confirmPasswordReset(
      email: event.email,
      code: event.code,
      newPassword: event.newPassword,
      confirmation: event.confirmation,
    );
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(
          state.copyWith(
            isSubmitting: false,
            clearResetCode: true,
            clearResetEmail: true,
            openResetPage: false,
            passwordResetCompleted: true,
            clearError: true,
            infoMessage: 'Password updated. Sign in with the new password.',
          ),
        );
      case Err(:final failure):
        _emitFailure(failure, emit);
    }
  }

  Future<void> _onVerificationResend(
    AuthVerificationResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await _sendEmailVerification();
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            isSubmitting: false,
            verificationCode: value,
            clearVerificationCode: value == null,
            clearError: true,
            infoMessage: value == null
                ? 'Verification email sent. Open the link, then continue.'
                : 'A new demo code is ready on this device.',
          ),
        );
      case Err(:final failure):
        _emitFailure(failure, emit);
    }
  }

  Future<void> _onVerificationConfirmed(
    AuthVerificationConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await _confirmEmailVerification(event.code);
    if (isClosed) return;
    switch (result) {
      case Ok():
        await _signOut();
        if (isClosed) return;
        emit(
          AuthState(
            status: AuthStatus.unauthenticated,
            infoMessage: 'Email verified. Please sign in with your account.',
            issuesOutOfBandCodes: state.issuesOutOfBandCodes,
          ),
        );
      case Err(:final failure):
        _emitFailure(failure, emit);
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await _signOut();
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(
          AuthState(
            status: AuthStatus.unauthenticated,
            issuesOutOfBandCodes: state.issuesOutOfBandCodes,
          ),
        );
      case Err(:final failure):
        _emitFailure(failure, emit);
    }
  }

  void _emitAuthResult(
    Result<AppUser> result,
    Emitter<AuthState> emit, {
    bool clearVerificationCode = false,
  }) {
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            isSubmitting: false,
            status: _statusFor(value),
            user: value,
            clearError: true,
            clearVerificationCode: clearVerificationCode || value.emailVerified,
          ),
        );
      case Err(:final failure):
        _emitFailure(failure, emit);
    }
  }

  void _emitFailure(Failure failure, Emitter<AuthState> emit) {
    if (failure is CancelledFailure) {
      emit(state.copyWith(isSubmitting: false));
      return;
    }
    emit(
      state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
        clearInfo: true,
      ),
    );
  }

  AuthStatus _statusFor(AppUser? user) {
    if (user == null) return AuthStatus.unauthenticated;
    if (!user.emailVerified) return AuthStatus.unverified;
    return AuthStatus.authenticated;
  }
}
