import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grantsandbenfits/core/constants/route_paths.dart';
import 'package:grantsandbenfits/core/theme/app_colors.dart';
import 'package:grantsandbenfits/core/widgets/form_message.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/eligibility/domain/entities/eligibility_assessment.dart';
import 'package:grantsandbenfits/features/eligibility/presentation/bloc/eligibility_bloc.dart';
import 'package:grantsandbenfits/features/eligibility/presentation/bloc/eligibility_event.dart';
import 'package:grantsandbenfits/features/eligibility/presentation/bloc/eligibility_state.dart';

class EligibilityPage extends StatelessWidget {
  const EligibilityPage({super.key});

  Future<void> _openDocumentsAndRefresh(BuildContext context) async {
    final bloc = context.read<EligibilityBloc>();
    final userId = context.read<AuthBloc>().state.user?.id ?? '';
    await context.push(RoutePaths.documents);
    if (context.mounted) {
      bloc.add(EligibilityLoadRequested(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.forestDark,
        foregroundColor: AppColors.white,
        title: const Text('Eligibility & POPIA Rules'),
      ),
      body: BlocBuilder<EligibilityBloc, EligibilityState>(
        builder: (context, state) {
          if (state.isLoading && state.assessment == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: FormMessage(message: state.errorMessage!, isError: true),
            );
          }

          final assessment = state.assessment;
          if (assessment == null) return const SizedBox.shrink();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _RecommendationCard(assessment: assessment),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Document Validation Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openDocumentsAndRefresh(context),
                    child: const Text('Scan docs'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final item in assessment.documents)
                _DocumentStatusRow(item: item),
              const SizedBox(height: 24),
              Text(
                'POPIA Rules & Safeguards',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'All rules below are enforced under the Protection of Personal Information Act (POPIA) and PAJA.',
                style: TextStyle(color: AppColors.muted, height: 1.35),
              ),
              const SizedBox(height: 12),
              for (final rule in assessment.popiaRules)
                _PopiaRuleCard(rule: rule),
            ],
          );
        },
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.assessment});

  final EligibilityAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (assessment.recommendation) {
      EligibilityRecommendation.likelyEligible => (
        AppColors.successSurface,
        AppColors.forestDark,
        Icons.verified_outlined,
      ),
      EligibilityRecommendation.needsReview => (
        const Color(0xFFFFF7E8),
        const Color(0xFF7A5600),
        Icons.rate_review_outlined,
      ),
      EligibilityRecommendation.notEligible => (
        AppColors.dangerSurface,
        AppColors.danger,
        Icons.gpp_bad_outlined,
      ),
    };

    final confidencePct = (assessment.confidence * 100).round();

    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: fg),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          assessment.recommendation.label,
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$confidencePct% confidence',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (assessment.requiresReview) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 16,
                      color: Color(0xFF7A5600),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Requires Official Review — No application is declined automatically.',
                        style: TextStyle(
                          color: Color(0xFF7A5600),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              assessment.explanation,
              style: const TextStyle(height: 1.4, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentStatusRow extends StatelessWidget {
  const _DocumentStatusRow({required this.item});

  final DocumentValidationItem item;

  @override
  Widget build(BuildContext context) {
    final Widget trailing = switch (item.status) {
      DocumentCheckStatus.validated => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Validated',
            style: TextStyle(
              color: Color(0xFF1B7A43),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 6),
          Icon(Icons.check_circle, color: Color(0xFF1B7A43), size: 24),
        ],
      ),
      DocumentCheckStatus.requiresReview => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Requires Review',
            style: TextStyle(
              color: Color(0xFFB26A00),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 6),
          Icon(Icons.rate_review, color: Color(0xFFB26A00), size: 22),
        ],
      ),
      DocumentCheckStatus.notValidated => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Not Validated',
            style: TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 6),
          Icon(Icons.cancel, color: AppColors.danger, size: 24),
        ],
      ),
    };

    return Card(
      elevation: 0,
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.type.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.detail,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _PopiaRuleCard extends StatelessWidget {
  const _PopiaRuleCard({required this.rule});

  final PopiaRuleItem rule;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              rule.satisfied ? Icons.check_circle : Icons.info_outline,
              color: rule.satisfied
                  ? const Color(0xFF1B7A43)
                  : const Color(0xFFB26A00),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${rule.code}: ${rule.title}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rule.description,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
