import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grantsandbenfits/core/constants/route_paths.dart';
import 'package:grantsandbenfits/core/di/injection.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/core/theme/app_colors.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_event.dart';
import 'package:grantsandbenfits/features/documents/domain/repositories/document_verification_repository.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';
import 'package:grantsandbenfits/features/profile/domain/repositories/profile_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _profileDone = false;
  int _approvedDocsCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshProgress();
  }

  Future<void> _refreshProgress() async {
    final userId = context.read<AuthBloc>().state.user?.id ?? '';
    if (userId.isEmpty) return;

    final profileResult = await getIt<ProfileRepository>().loadProfile(userId);
    final approvedDocs = await getIt<DocumentVerificationRepository>()
        .loadApprovedDocuments();

    if (!mounted) return;
    setState(() {
      _profileDone =
          profileResult is Ok<UserProfile?> && profileResult.value != null;
      _approvedDocsCount = approvedDocs.length;
    });
  }

  Future<void> _openAndRefresh(String route) async {
    await context.push(route);
    if (mounted) await _refreshProgress();
  }

  void _showStepLockedMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final user = state.user;
    final name = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : 'there';
    final docsDone = _approvedDocsCount > 0;
    final canApplyBursaries = _profileDone && docsDone;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.forestDark,
        foregroundColor: AppColors.white,
        title: const Text('Grants & Benefits'),
        actions: [
          TextButton(
            onPressed: state.isSubmitting
                ? null
                : () => context.read<AuthBloc>().add(
                    const AuthSignOutRequested(),
                  ),
            child: const Text(
              'Sign out',
              style: TextStyle(color: AppColors.white),
            ),
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
          const SizedBox(height: 6),
          Text(
            user?.email ?? '',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          if (state.issuesOutOfBandCodes)
            const _Notice(
              message:
                  'Demo mode is on. Use synthetic data only. An official remains the accountable decision-maker.',
            ),
          const SizedBox(height: 20),
          Text(
            'Application Journey',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Complete each step in order so your bursary application is pre-filled automatically.',
            style: TextStyle(color: AppColors.muted, height: 1.35),
          ),
          const SizedBox(height: 14),
          _StepCard(
            stepNumber: 1,
            title: 'Fill in Your Profile',
            detail:
                'Enter your valid full name, 13-digit South African ID (Luhn checked), and residential address.',
            completed: _profileDone,
            locked: false,
            badge: _profileDone ? 'Completed' : 'Start here',
            onTap: () => _openAndRefresh(RoutePaths.profile),
          ),
          _StepCard(
            stepNumber: 2,
            title: 'Upload & Validate Certified Documents',
            detail:
                'Upload SAPS or Post Office certified documents. The AI agent scans authenticity and applies POPIA masking.',
            completed: docsDone,
            locked: !_profileDone,
            badge: docsDone
                ? '$_approvedDocsCount approved'
                : (_profileDone ? 'Next step' : 'Complete Step 1'),
            onTap: _profileDone
                ? () => _openAndRefresh(RoutePaths.documents)
                : () => _showStepLockedMessage(
                    'Please complete Step 1 (Profile) before uploading documents.',
                  ),
          ),
          _StepCard(
            stepNumber: 3,
            title: 'Apply for Bursaries (SITA & NSFAS)',
            detail:
                'View available bursaries and apply in one tap with your profile and approved certified documents pre-attached.',
            completed: false,
            locked: !canApplyBursaries,
            badge: canApplyBursaries ? 'Ready' : 'Complete Steps 1 & 2',
            onTap: canApplyBursaries
                ? () => _openAndRefresh(RoutePaths.bursaries)
                : () => _showStepLockedMessage(
                    'Complete your Profile and validate at least one certified document first.',
                  ),
          ),
          _StepCard(
            stepNumber: 4,
            title: 'Eligibility & POPIA Rules',
            detail:
                'Check document validation status (green tick / red cross / requires review) and all enforced POPIA safeguards.',
            completed: false,
            locked: false,
            badge: 'View',
            onTap: () => _openAndRefresh(RoutePaths.eligibility),
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

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.stepNumber,
    required this.title,
    required this.detail,
    required this.completed,
    required this.locked,
    required this.badge,
    required this.onTap,
  });

  final int stepNumber;
  final String title;
  final String detail;
  final bool completed;
  final bool locked;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = completed
        ? const Color(0xFF1B7A43)
        : (locked ? AppColors.line : AppColors.forest);
    final circleBg = completed
        ? const Color(0xFF1B7A43)
        : (locked ? AppColors.line : AppColors.forestDark);

    return Card(
      elevation: 0,
      color: locked ? AppColors.sand : AppColors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: circleBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: completed
                    ? const Icon(Icons.check, size: 18, color: AppColors.white)
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: locked ? AppColors.muted : AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: locked ? AppColors.muted : AppColors.ink,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: completed
                                ? AppColors.successSurface
                                : (locked
                                      ? AppColors.white
                                      : const Color(0xFFFFF7E8)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: completed
                                  ? const Color(0xFF1B7A43)
                                  : (locked
                                        ? AppColors.muted
                                        : AppColors.forestDark),
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5,
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
              const SizedBox(width: 6),
              Icon(
                locked ? Icons.lock_outline : Icons.chevron_right,
                color: locked ? AppColors.muted : AppColors.forest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
