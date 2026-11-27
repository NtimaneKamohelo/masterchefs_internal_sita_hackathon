import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grantsandbenfits/core/constants/route_paths.dart';
import 'package:grantsandbenfits/core/security/input_validator.dart';
import 'package:grantsandbenfits/core/widgets/app_text_field.dart';
import 'package:grantsandbenfits/core/widgets/form_message.dart';
import 'package:grantsandbenfits/core/widgets/primary_button.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_event.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_state.dart';
import 'package:grantsandbenfits/features/auth/presentation/widgets/auth_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _honeypot = TextEditingController();
  late final DateTime _openedAt = DateTime.now();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _honeypot.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthSignInRequested(
        email: _email.text,
        password: _password.text,
        honeypot: _honeypot.text,
        formOpenedAt: _openedAt,
      ),
    );
  }

  void _google() {
    context.read<AuthBloc>().add(
      AuthGoogleSignInRequested(
        honeypot: _honeypot.text,
        formOpenedAt: _openedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Sign in',
      subtitle: 'Use the account that will own this application.',
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.errorMessage != null) ...[
                    FormMessage(message: state.errorMessage!, isError: true),
                    const SizedBox(height: 12),
                  ],
                  if (state.infoMessage != null) ...[
                    FormMessage(message: state.infoMessage!, isError: false),
                    const SizedBox(height: 12),
                  ],
                  AppTextField(
                    controller: _email,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    validator: (value) => InputValidator.email(value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _password,
                    label: 'Password',
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _submit(),
                    validator: (value) => InputValidator.password(
                      value ?? '',
                      email: InputValidator.normalizeEmail(_email.text),
                    ),
                  ),
                  HoneypotField(controller: _honeypot),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          GoRouter.maybeOf(context)?.go(RoutePaths.forgotPassword),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  PrimaryButton(
                    label: 'Sign in',
                    isLoading: state.isSubmitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: state.isSubmitting ? null : _google,
                    icon: const Text(
                      'G',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    label: Text(
                      state.issuesOutOfBandCodes
                          ? 'Continue with Google (demo)'
                          : 'Continue with Google',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        GoRouter.maybeOf(context)?.go(RoutePaths.register),
                    child: const Text('Create an account'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
