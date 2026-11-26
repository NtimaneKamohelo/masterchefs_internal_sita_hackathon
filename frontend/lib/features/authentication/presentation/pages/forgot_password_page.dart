import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _requestSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _requestSent = false;
    });

    context.read<AuthBloc>().add(
      AuthPasswordResetRequested(_emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthPasswordResetSent || current is AuthError,
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          setState(() {
            _requestSent = true;
          });
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return AuthScaffold(
          title: 'Forgot password?',
          subtitle:
              'Enter your email address and we will send '
              'instructions to reset your password.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  controller: _emailController,
                  label: 'Email address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email address is required.';
                    }

                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())) {
                      return 'Enter a valid email address.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                if (_requestSent) ...[
                  const Icon(Icons.mark_email_read_outlined, size: 54),
                  const SizedBox(height: 12),
                  const Text(
                    'If an account exists for that email, '
                    'password reset instructions have been sent. '
                    'Please check your inbox.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],

                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Send reset instructions'),
                ),
              ],
            ),
          ),
          footer: TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: const Text('Back to sign in'),
          ),
        );
      },
    );
  }
}
