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
              if (state.errorMessage != null) ...[
                FormMessage(message: state.errorMessage!, isError: true),
                const SizedBox(height: 12),
              ],
              if (state.infoMessage != null) ...[
                FormMessage(message: state.infoMessage!, isError: false),
                const SizedBox(height: 12),
              ],
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
              const SizedBox(height: 24),
              const _OfficialReviewSection(),
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

class _OfficialReviewSection extends StatefulWidget {
  const _OfficialReviewSection();

  @override
  State<_OfficialReviewSection> createState() => _OfficialReviewSectionState();
}

class _OfficialReviewSectionState extends State<_OfficialReviewSection> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _record(String action) {
    context.read<EligibilityBloc>().add(
      OfficialDecisionSubmitted(action: action, reason: _reason.text),
    );
    _reason.clear();
  }

  @override
  Widget build(BuildContext context) {
    final auditTrail = context.watch<EligibilityBloc>().state.auditTrail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Official Decision & Audit Trail',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        const Text(
          'Human-in-the-loop: An accountable official approves, escalates, or overrides the AI recommendation with a PAJA reason.',
          style: TextStyle(color: AppColors.muted, height: 1.35),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reason,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Official PAJA reason (required)',
            hintText: 'e.g. Verified SAPS stamp and household income within NSFAS limit.',
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _record('Approved'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.forest),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Approve'),
            ),
            OutlinedButton.icon(
              onPressed: () => _record('Escalated for Review'),
              icon: const Icon(Icons.rate_review_outlined, size: 16),
              label: const Text('Escalate'),
            ),
            OutlinedButton.icon(
              onPressed: () => _record('Overridden'),
              icon: const Icon(Icons.gavel_outlined, size: 16),
              label: const Text('Override'),
            ),
          ],
        ),
        if (auditTrail.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Recorded Audit Trail',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final entry in auditTrail)
            Card(
              elevation: 0,
              color: AppColors.white,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.line),
              ),
              child: ListTile(
                title: Text(
                  '${entry.action} • ${entry.ruleVersion}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                subtitle: Text(
                  '${entry.reason}\n${entry.recordedAt.toLocal().toString().substring(0, 16)}',
                  style: const TextStyle(fontSize: 12.5, height: 1.35),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
