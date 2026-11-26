import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/presentation/bloc/auth_event.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/presentation/bloc/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../domain/repositories/auth_repository.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({
    required this.repository,
  }) : super(AuthInitial()) {
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthSessionRequested>(_onSession);
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await repository.register(
        email: event.email.trim(),
        password: event.password,
      );

      if (user == null) {
        emit(AuthEmailVerificationPending(event.email));
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
      final user = await repository.login(
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
      await repository.logout();
      emit(AuthUnauthenticated());
    } catch (_) {
      emit(const AuthError('Unable to log out.'));
    }
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await repository.resetPassword(
        email: event.email.trim(),
      );

      emit(AuthPasswordResetSent());
    } on AuthException catch (e) {
      emit(AuthError(_mapError(e)));
    } catch (_) {
      emit(const AuthError('Unable to send password reset email.'));
    }
  }

  Future<void> _onSession(
    AuthSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = repository.getCurrentUser;

      if (user == null) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated(user));
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  String _mapError(AuthException exception) {
    switch (exception.code) {
      case 'invalid_credentials':
        return 'Invalid email or password.';

      case 'email_not_confirmed':
        return 'Please verify your email before logging in.';

      case 'user_already_exists':
        return 'An account with this email already exists.';

      case 'weak_password':
        return 'Your password does not meet security requirements.';

      case 'over_email_send_rate_limit':
        return 'Too many email requests. Try again later.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }
}