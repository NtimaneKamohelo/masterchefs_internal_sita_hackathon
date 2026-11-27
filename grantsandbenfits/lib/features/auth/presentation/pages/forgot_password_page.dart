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

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _honeypot = TextEditingController();
  late final DateTime _openedAt = DateTime.now();

  @override
  void dispose() {
    _email.dispose();
    _honeypot.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthPasswordResetRequested(
        email: _email.text,
        honeypot: _honeypot.text,
        formOpenedAt: _openedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Reset password',
      subtitle: 'We will not say whether this email is registered.',
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            !previous.openResetPage && current.openResetPage,
        listener: (context, state) {
          GoRouter.maybeOf(context)?.go(RoutePaths.resetPassword);
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.errorMessage != null) ...[
                  FormMessage(message: state.errorMessage!, isError: true),
                  const SizedBox(height: 12),
                ],
                if (state.infoMessage != null && !state.issuesOutOfBandCodes) ...[
                  FormMessage(message: state.infoMessage!, isError: false),
                  const SizedBox(height: 12),
                ],
                AppTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  onSubmitted: (_) => _submit(),
                  validator: (value) => InputValidator.email(value ?? ''),
                ),
                HoneypotField(controller: _honeypot),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Send reset instructions',
                  isLoading: state.isSubmitting,
                  onPressed: _submit,
                ),
                TextButton(
                  onPressed: () => GoRouter.maybeOf(context)?.go(RoutePaths.login),
                  child: const Text('Back to sign in'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
