import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grantsandbenfits/core/constants/route_paths.dart';
import 'package:grantsandbenfits/core/security/content_sanitizer.dart';
import 'package:grantsandbenfits/core/security/input_validator.dart';
import 'package:grantsandbenfits/core/theme/app_colors.dart';
import 'package:grantsandbenfits/core/widgets/app_text_field.dart';
import 'package:grantsandbenfits/core/widgets/form_message.dart';
import 'package:grantsandbenfits/core/widgets/primary_button.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';
import 'package:grantsandbenfits/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:grantsandbenfits/features/profile/presentation/bloc/profile_event.dart';
import 'package:grantsandbenfits/features/profile/presentation/bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _idNumber = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _postalCode = TextEditingController();
  final _phone = TextEditingController();
  String _province = 'Gauteng';
  bool _hydrated = false;

  @override
  void dispose() {
    _fullName.dispose();
    _idNumber.dispose();
    _street.dispose();
    _city.dispose();
    _postalCode.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _hydrateFrom(UserProfile? profile) {
    if (_hydrated) return;
    _hydrated = true;
    final authUser = context.read<AuthBloc>().state.user;
    if (profile != null) {
      _fullName.text = profile.fullName;
      _idNumber.text = profile.idNumber;
      _street.text = profile.streetAddress;
      _city.text = profile.city;
      _province = southAfricanProvinces.contains(profile.province)
          ? profile.province
          : 'Gauteng';
      _postalCode.text = profile.postalCode;
      _phone.text = profile.phoneNumber;
    } else if (authUser != null && authUser.displayName.isNotEmpty) {
      _fullName.text = authUser.displayName;
    }
  }

  void _fillSyntheticDemo() {
    setState(() {
      _fullName.text = 'Thabo Mokoena';
      // Valid Luhn checksum synthetic SA ID (990101 5009 08 7 -> check digit 7).
      _idNumber.text = '9901015009087';
      _street.text = '459 Tsitsa Street, Erasmuskloof';
      _city.text = 'Pretoria';
      _province = 'Gauteng';
      _postalCode.text = '0048';
      _phone.text = '0821234567';
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final userId = context.read<AuthBloc>().state.user?.id ?? '';
    context.read<ProfileBloc>().add(
      ProfileSaveRequested(
        UserProfile(
          userId: userId,
          fullName: _fullName.text,
          idNumber: _idNumber.text,
          streetAddress: _street.text,
          city: _city.text,
          province: _province,
          postalCode: _postalCode.text,
          phoneNumber: _phone.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.forestDark,
        foregroundColor: AppColors.white,
        title: const Text('Applicant Profile'),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (!state.isLoading && !_hydrated) {
            setState(() => _hydrateFrom(state.profile));
          }
        },
        builder: (context, state) {
          if (state.isLoading && !_hydrated) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!_hydrated && !state.isLoading) {
            _hydrateFrom(state.profile);
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Personal & Address Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter valid information that matches your certified South African ID '
                'and proof of residence. Mismatches will be flagged for official review.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: AppColors.forestDark,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'POPIA protection: Saved in encrypted storage locked to your account. '
                        'Use synthetic details during the hackathon.',
                        style: TextStyle(
                          color: AppColors.forestDark,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: ActionChip(
                  avatar: const Icon(Icons.auto_fix_high_outlined, size: 16),
                  label: const Text('Fill synthetic demo profile'),
                  onPressed: state.isSaving ? null : _fillSyntheticDemo,
                ),
              ),
              const SizedBox(height: 12),
              if (state.errorMessage != null) ...[
                FormMessage(message: state.errorMessage!, isError: true),
                const SizedBox(height: 12),
              ],
              if (state.infoMessage != null) ...[
                FormMessage(message: state.infoMessage!, isError: false),
                const SizedBox(height: 12),
              ],
              if (state.profile != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saved Record (POPIA Masked)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${state.profile!.fullName} • ID ${state.profile!.maskedIdNumber}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.profile!.formattedAddress,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _fullName,
                      label: 'Full name (as on ID)',
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: (value) => InputValidator.name(
                        ContentSanitizer.sanitizePlainText(value ?? ''),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _idNumber,
                      label: 'South African ID number (13 digits)',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      maxLength: 13,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(13),
                      ],
                      validator: (value) =>
                          InputValidator.southAfricanId(value ?? ''),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _street,
                      label: 'Street address',
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.streetAddressLine1],
                      validator: (value) =>
                          InputValidator.streetAddress(value ?? ''),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _city,
                      label: 'City / Town',
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.addressCity],
                      validator: (value) => InputValidator.city(value ?? ''),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _province,
                      decoration: const InputDecoration(labelText: 'Province'),
                      items: [
                        for (final province in southAfricanProvinces)
                          DropdownMenuItem(
                            value: province,
                            child: Text(province),
                          ),
                      ],
                      onChanged: state.isSaving
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _province = value);
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _postalCode,
                      label: 'Postal code (4 digits)',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      maxLength: 4,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      autofillHints: const [AutofillHints.postalCode],
                      validator: (value) =>
                          InputValidator.postalCode(value ?? ''),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _phone,
                      label: 'Phone number (optional)',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      onSubmitted: (_) => _submit(),
                      validator: (value) =>
                          InputValidator.phoneNumber(value ?? ''),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Save profile',
                      isLoading: state.isSaving,
                      onPressed: _submit,
                    ),
                    if (state.profile != null) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push(RoutePaths.documents),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text(
                          'Proceed to Step 2: Upload Certified Documents',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
