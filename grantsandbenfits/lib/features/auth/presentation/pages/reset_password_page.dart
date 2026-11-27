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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final state = context.read<AuthBloc>().state;
    final email = state.resetEmail;
    final code = state.resetCode;
    if (email != null) _email.text = email;
    if (code != null) _code.text = code;
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthPasswordResetConfirmed(
        email: _email.text,
        code: _code.text,
        newPassword: _password.text,
        confirmation: _confirmation.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Choose a new password',
      subtitle:
          'Demo mode shows the code on this device. Firebase mode sends a link by email instead.',
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            !previous.passwordResetCompleted && current.passwordResetCompleted,
        listener: (context, state) {
          GoRouter.maybeOf(context)?.go(RoutePaths.login);
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
                AppTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) => InputValidator.email(value ?? ''),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _code,
                  label: '6-digit code',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      InputValidator.verificationCode(value ?? ''),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _password,
                  label: 'New password',
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  validator: (value) => InputValidator.password(
                    value ?? '',
                    email: InputValidator.normalizeEmail(_email.text),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _confirmation,
                  label: 'Confirm new password',
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (value) => InputValidator.confirmation(
                    password: _password.text,
                    confirmation: value ?? '',
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Update password',
                  isLoading: state.isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
