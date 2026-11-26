import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'verify_email_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        return current is AuthInitial ||
            current is AuthAuthenticated ||
            current is AuthUnauthenticated ||
            current is AuthEmailVerificationPending;
      },
      builder: (context, state) {
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          return const HomePage();
        }

        if (state is AuthEmailVerificationPending) {
          return VerifyEmailPage(email: state.email);
        }

        return const LoginPage();
      },
    );
  }
}
