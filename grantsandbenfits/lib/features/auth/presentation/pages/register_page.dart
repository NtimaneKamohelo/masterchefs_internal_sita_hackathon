import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grantsandbenfits/core/constants/route_paths.dart';
import 'package:grantsandbenfits/core/security/content_sanitizer.dart';
import 'package:grantsandbenfits/core/security/input_validator.dart';
import 'package:grantsandbenfits/core/widgets/app_text_field.dart';
import 'package:grantsandbenfits/core/widgets/form_message.dart';
import 'package:grantsandbenfits/core/widgets/primary_button.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_event.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_state.dart';
import 'package:grantsandbenfits/features/auth/presentation/widgets/auth_shell.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _honeypot = TextEditingController();
  late final DateTime _openedAt = DateTime.now();
  bool _consent = false;
  String? _consentError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    _honeypot.dispose();
    super.dispose();
  }

  void _submit() {
    final formOk = _formKey.currentState?.validate() ?? false;
    setState(() {
      _consentError = _consent
          ? null
          : 'Consent is required before we can process an application.';
    });
    if (!formOk || !_consent) return;
    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        confirmation: _confirmation.text,
        popiaConsent: _consent,
        honeypot: _honeypot.text,
        formOpenedAt: _openedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Create an account',
      subtitle: 'Use synthetic details only. Real identity numbers are not collected here yet.',
      child: BlocBuilder<AuthBloc, AuthState>(
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
                  controller: _name,
                  label: 'Full name',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: (value) => InputValidator.name(
                    ContentSanitizer.sanitizePlainText(value ?? ''),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) => InputValidator.email(value ?? ''),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _password,
                  label: 'Password',
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) => InputValidator.password(
                    value ?? '',
                    email: InputValidator.normalizeEmail(_email.text),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _confirmation,
                  label: 'Confirm password',
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (value) => InputValidator.confirmation(
                    password: _password.text,
                    confirmation: value ?? '',
                  ),
                ),
                HoneypotField(controller: _honeypot),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _consent,
                  onChanged: (value) => setState(() {
                    _consent = value ?? false;
                    _consentError = null;
                  }),
                  title: const Text(
                    'I consent to processing this information only to assess bursary and benefit eligibility, in line with POPIA.',
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (_consentError != null)
                  FormMessage(message: _consentError!, isError: true),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Create account',
                  isLoading: state.isSubmitting,
                  onPressed: _submit,
                ),
                TextButton(
                  onPressed: () => GoRouter.maybeOf(context)?.go(RoutePaths.login),
                  child: const Text('I already have an account'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
