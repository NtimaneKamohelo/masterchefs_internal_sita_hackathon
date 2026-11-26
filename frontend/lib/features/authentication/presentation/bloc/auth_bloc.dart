import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/resend_verification_email.dart';
import '../../domain/usecases/update_password.dart';
import 'auth_event.dart';
import 'auth_state.dart';
//import '../../domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final ResetPassword resetPassword;
  final ResendVerificationEmail resendVerificationEmail;
  final UpdatePassword updatePassword;

  final AuthRepository _repository;

  AuthBloc({
    required this.registerUser,
    required this.loginUser,
    required this.logoutUser,
    required this.resetPassword,
    required this.resendVerificationEmail,
    required this.updatePassword,
    required AuthRepository repository,
  }) : _repository = repository,
       super(AuthInitial()) {
    on<AuthSessionRequested>(_onSessionRequested);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthVerificationResendRequested>(_onResendVerification);
    on<AuthPasswordUpdateRequested>(_onPasswordUpdate);
  }

  Future<void> _onSessionRequested(
    AuthSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _repository.getCurrentUser;

    if (user == null) {
      if (state is AuthEmailVerificationPending) {
        return;
      }

      emit(AuthUnauthenticated());
      return;
    }

    emit(AuthAuthenticated(user));
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await registerUser(
        email: event.email.trim(),
        password: event.password,
      );

      if (user == null) {
        emit(AuthEmailVerificationPending(event.email.trim()));
      } else {
        emit(AuthAuthenticated(user));
      }
    } on AuthException catch (e) {
      emit(AuthError(_mapError(e)));
    } catch (_) {
      emit(const AuthError('Registration failed. Please try again.'));
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await loginUser(
        email: event.email.trim(),
        password: event.password,
      );

      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(_mapError(e)));
    } catch (_) {
      emit(const AuthError('Login failed. Please try again.'));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await logoutUser();
      emit(AuthUnauthenticated());
    } catch (_) {
      emit(const AuthError('Unable to log out. Please try again.'));
    }
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await resetPassword(email: event.email.trim());
      emit(AuthPasswordResetSent());
    } on AuthException catch (e) {
      emit(AuthError(_mapError(e)));
    } catch (_) {
      emit(const AuthError('Unable to process your request.'));
    }
  }

  Future<void> _onResendVerification(
    AuthVerificationResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await resendVerificationEmail(email: event.email);
      emit(AuthEmailVerificationPending(event.email));
    } on AuthException catch (e) {
      emit(AuthError(_mapError(e)));
    } catch (_) {
      emit(const AuthError('Unable to resend verification email.'));
    }
  }

  Future<void> _onPasswordUpdate(
    AuthPasswordUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await updatePassword(password: event.password);
      emit(AuthPasswordUpdated());
    } on AuthException catch (e) {
      emit(AuthError(_mapError(e)));
    } catch (_) {
      emit(const AuthError('Unable to update your password.'));
    }
  }

  String _mapError(AuthException exception) {
    switch (exception.code) {
      case 'invalid_credentials':
        return 'Invalid email or password.';

      case 'email_not_confirmed':
        return 'Please verify your email before logging in.';

      case 'weak_password':
        return 'Your password does not meet security requirements.';

      case 'over_email_send_rate_limit':
        return 'Too many requests. Please try again later.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
