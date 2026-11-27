import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grantsandbenfits/core/constants/route_paths.dart';
import 'package:grantsandbenfits/core/theme/app_colors.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_event.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final user = state.user;
    final name = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : 'there';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.forestDark,
        foregroundColor: AppColors.white,
        title: const Text('Grants & Benefits'),
        actions: [
          TextButton(
            onPressed: state.isSubmitting
                ? null
                : () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
            child: const Text('Sign out', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Welcome, $name',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? '',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          if (state.issuesOutOfBandCodes)
            const _Notice(
              message:
                  'Demo mode is on. Keep using synthetic data. Real ID numbers, payslips, and addresses do not belong in this build yet.',
            ),
          if (user?.isSynthetic ?? false) ...[
            const SizedBox(height: 12),
            const _Notice(
              message:
                  'This Google sign-in used a synthetic identity. Google was not contacted.',
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            'An official remains the decision-maker. The assistant can recommend. It cannot decline an application on its own.',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 24),
          Text(
            'Next in this build',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const _NextCard(
            title: 'Profile',
            detail: 'Name, South African ID number, and address, saved for the signed-in person only.',
          ),
          const _NextCard(
            title: 'Bursaries',
            detail: 'SITA internal bursary and NSFAS, with the rules visible to a policy owner.',
          ),
          _NextCard(
            title: 'Certified documents — AI Validator',
            detail:
                'Upload SAPS or Post Office certified documents. The AI agent checks authenticity, recency, and POPIA compliance.',
            badge: 'Open',
            onTap: () => context.push(RoutePaths.documents),
          ),
          const _NextCard(
            title: 'Eligibility decision',
            detail: 'Likely eligible, not eligible, or needs review — with the rule, the evidence, and a human reason.',
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: const TextStyle(height: 1.4)),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({
    required this.title,
    required this.detail,
    this.badge,
    this.onTap,
  });

  final String title;
  final String detail;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: onTap != null ? AppColors.forest : AppColors.line,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                color: AppColors.forestDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      detail,
                      style: const TextStyle(
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.forest),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
