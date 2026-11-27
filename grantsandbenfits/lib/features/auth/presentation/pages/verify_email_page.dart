import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantsandbenfits/core/security/input_validator.dart';
import 'package:grantsandbenfits/core/widgets/app_text_field.dart';
import 'package:grantsandbenfits/core/widgets/form_message.dart';
import 'package:grantsandbenfits/core/widgets/primary_button.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_event.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_state.dart';
import 'package:grantsandbenfits/features/auth/presentation/widgets/auth_shell.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final code = context.read<AuthBloc>().state.verificationCode;
    if (code != null) _code.text = code;
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Verify your email',
      subtitle: 'The rest of the assistant stays locked until this account is verified.',
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.verificationCode != current.verificationCode &&
            current.verificationCode != null,
        listener: (context, state) {
          _code.text = state.verificationCode ?? '';
        },
        builder: (context, state) {
          final demo = state.issuesOutOfBandCodes;
          return Form(
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
                Text(
                  demo
                      ? 'No email is sent in demo mode. Enter the code shown here. It expires in 15 minutes.'
                      : 'Open the verification link we sent, then confirm below.',
                  style: const TextStyle(height: 1.4),
                ),
                if (demo) ...[
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _code,
                    label: '6-digit code',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: (value) =>
                        InputValidator.verificationCode(value ?? ''),
                  ),
                ],
                const SizedBox(height: 16),
                PrimaryButton(
                  label: demo ? 'Verify code' : "I've verified my email",
                  isLoading: state.isSubmitting,
                  onPressed: () {
                    if (demo && !(_formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    context.read<AuthBloc>().add(
                      AuthVerificationConfirmed(demo ? _code.text : ''),
                    );
                  },
                ),
                TextButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => context.read<AuthBloc>().add(
                          const AuthVerificationResendRequested(),
                        ),
                  child: Text(demo ? 'Send a new code' : 'Resend email'),
                ),
                TextButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () => context
                            .read<AuthBloc>()
                            .add(const AuthSignOutRequested()),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
