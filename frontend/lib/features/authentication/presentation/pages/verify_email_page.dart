import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_scaffold.dart';

class VerifyEmailPage extends StatelessWidget {
  final String email;

  const VerifyEmailPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthError ||
          current is AuthEmailVerificationPending ||
          current is AuthAuthenticated,
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }

        if (state is AuthAuthenticated) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return AuthScaffold(
          title: 'Verify your email',
          subtitle:
              'We sent a verification link to $email. '
              'Please verify your email before signing in.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 88),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<AuthBloc>().add(AuthSessionRequested());
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text("I've verified my email"),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<AuthBloc>().add(
                          AuthVerificationResendRequested(email),
                        );
                      },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Resend verification email'),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                child: const Text('Back to sign in'),
              ),
            ],
          ),
        );
      },
    );
  }
}
