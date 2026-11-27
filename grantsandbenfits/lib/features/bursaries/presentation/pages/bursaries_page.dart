import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grantsandbenfits/core/constants/route_paths.dart';
import 'package:grantsandbenfits/core/theme/app_colors.dart';
import 'package:grantsandbenfits/core/widgets/form_message.dart';
import 'package:grantsandbenfits/core/widgets/primary_button.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_program.dart';
import 'package:grantsandbenfits/features/bursaries/presentation/bloc/bursaries_bloc.dart';
import 'package:grantsandbenfits/features/bursaries/presentation/bloc/bursaries_event.dart';
import 'package:grantsandbenfits/features/bursaries/presentation/bloc/bursaries_state.dart';

class BursariesPage extends StatelessWidget {
  const BursariesPage({super.key});

  Future<void> _openRouteAndRefresh(BuildContext context, String route) async {
    final bloc = context.read<BursariesBloc>();
    final userId = context.read<AuthBloc>().state.user?.id ?? '';
    await context.push(route);
    if (context.mounted) {
      bloc.add(BursariesLoadRequested(userId));
    }
  }

  Future<void> _confirmOneTapApply(
    BuildContext context,
    BursaryProgram bursary,
    BursariesState state,
  ) async {
    final bloc = context.read<BursariesBloc>();
    final profile = state.profile;
    final matchingDocs = state.approvedDocuments
        .where((doc) => bursary.requiredDocuments.contains(doc.documentType))
        .toList();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Quick Apply — ${bursary.name}',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your saved profile and approved certified documents are pre-filled below. Confirm to submit.',
                  style: TextStyle(color: AppColors.muted, height: 1.35),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pre-filled Profile',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                if (profile != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.sand,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${profile.fullName}\nID: ${profile.maskedIdNumber}\n${profile.formattedAddress}',
                      style: const TextStyle(height: 1.4),
                    ),
                  )
                else
                  const FormMessage(
                    message: 'Profile not completed yet. Complete your profile first.',
                    isError: true,
                  ),
                const SizedBox(height: 14),
                const Text(
                  'Pre-attached Approved Documents',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                if (matchingDocs.isNotEmpty)
                  for (final doc in matchingDocs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_outlined,
                            size: 16,
                            color: AppColors.forest,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${doc.documentType.label} — ${doc.fileName}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )
                else
                  const FormMessage(
                    message:
                        'No approved SAPS/Post Office documents attached yet. Scan a document first.',
                    isError: true,
                  ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Submit Application',
                  onPressed: profile != null && matchingDocs.isNotEmpty
                      ? () => Navigator.of(sheetContext).pop(true)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      bloc.add(BursaryApplyRequested(bursary));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.forestDark,
        foregroundColor: AppColors.white,
        title: const Text('Available Bursaries'),
      ),
      body: BlocBuilder<BursariesBloc, BursariesState>(
        builder: (context, state) {
          if (state.isLoading && state.bursaries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _AutoFillReadinessCard(
                state: state,
                onOpenProfile: () =>
                    _openRouteAndRefresh(context, RoutePaths.profile),
                onOpenDocuments: () =>
                    _openRouteAndRefresh(context, RoutePaths.documents),
              ),
              const SizedBox(height: 16),
              if (state.errorMessage != null) ...[
                FormMessage(message: state.errorMessage!, isError: true),
                const SizedBox(height: 12),
              ],
              if (state.infoMessage != null) ...[
                FormMessage(message: state.infoMessage!, isError: false),
                const SizedBox(height: 12),
              ],
              Text(
                'Nationwide & Internal Schemes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final bursary in state.bursaries)
                _BursaryCard(
                  bursary: bursary,
                  state: state,
                  onApply: () => _confirmOneTapApply(context, bursary, state),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AutoFillReadinessCard extends StatelessWidget {
  const _AutoFillReadinessCard({
    required this.state,
    required this.onOpenProfile,
    required this.onOpenDocuments,
  });

  final BursariesState state;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenDocuments;

  @override
  Widget build(BuildContext context) {
    final hasProfile = state.profile != null;
    final docCount = state.approvedDocuments.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Auto-Fill Application Pack',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.forestDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                hasProfile ? Icons.check_circle_outline : Icons.info_outline,
                size: 18,
                color: AppColors.forestDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasProfile
                      ? 'Profile ready: ${state.profile!.fullName} (${state.profile!.maskedIdNumber})'
                      : 'Profile not saved yet',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: onOpenProfile,
                child: Text(hasProfile ? 'Edit' : 'Complete'),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                docCount > 0 ? Icons.verified_outlined : Icons.upload_file,
                size: 18,
                color: AppColors.forestDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  docCount > 0
                      ? '$docCount approved certified document(s) ready to pre-attach'
                      : 'No approved certified documents yet',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: onOpenDocuments,
                child: Text(docCount > 0 ? 'Add more' : 'Upload'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BursaryCard extends StatelessWidget {
  const _BursaryCard({
    required this.bursary,
    required this.state,
    required this.onApply,
  });

  final BursaryProgram bursary;
  final BursariesState state;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final applied = state.hasApplied(bursary.id);
    final approvedTypes = {
      for (final doc in state.approvedDocuments) doc.documentType,
    };

    return Card(
      elevation: 0,
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bursary.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                if (applied)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Applied',
                      style: TextStyle(
                        color: AppColors.forestDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${bursary.provider} • Closes ${bursary.closingDate}',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Text(bursary.summary, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 8),
            Text(
              'Coverage: ${bursary.coverage}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.forestDark,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Required Certified Documents (Auto-Attached)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            for (final docType in bursary.requiredDocuments)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      approvedTypes.contains(docType)
                          ? Icons.check_circle_outline
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: approvedTypes.contains(docType)
                          ? AppColors.forest
                          : AppColors.muted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        approvedTypes.contains(docType)
                            ? '${docType.label} (Pre-attached)'
                            : '${docType.label} (Upload in AI Validator)',
                        style: TextStyle(
                          fontSize: 13,
                          color: approvedTypes.contains(docType)
                              ? AppColors.ink
                              : AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: applied
                  ? 'Submitted — Pending Official Review'
                  : 'One-Tap Apply (Pre-filled)',
              isLoading: state.isSubmitting,
              onPressed: applied ? null : onApply,
            ),
          ],
        ),
      ),
    );
  }
}
