import 'package:flutter/material.dart';
import 'package:grantsandbenfits/core/theme/app_colors.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';

class VerificationResultCard extends StatelessWidget {
  const VerificationResultCard({required this.result, super.key});

  final DocumentVerificationResult result;

  @override
  Widget build(BuildContext context) {
    final (badgeBg, badgeFg, icon) = switch (result.verdict) {
      VerificationVerdict.authentic => (
        AppColors.successSurface,
        AppColors.forestDark,
        Icons.verified_outlined,
      ),
      VerificationVerdict.needsReview => (
        const Color(0xFFFFF7E8),
        const Color(0xFF7A5600),
        Icons.rate_review_outlined,
      ),
      VerificationVerdict.notAuthentic => (
        AppColors.dangerSurface,
        AppColors.danger,
        Icons.gpp_bad_outlined,
      ),
    };

    final confidencePct = (result.confidence * 100).round();

    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: badgeFg),
                      const SizedBox(width: 6),
                      Text(
                        result.verdict.label,
                        style: TextStyle(
                          color: badgeFg,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
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
            const SizedBox(height: 14),
            Text(
              result.fileName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${result.documentType.label} • ${result.authority.label}',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAJA Plain-Language Explanation',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.explanation,
                    style: const TextStyle(height: 1.4, color: AppColors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'AI Verification Checks',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final check in result.checks)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      check.passed
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 18,
                      color: check.passed ? AppColors.forest : AppColors.danger,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${check.ruleCode}: ${check.title}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            check.detail,
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
            if (result.extractedSummary.isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Extracted Evidence (POPIA Minimised)',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              for (final entry in result.extractedSummary.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 165,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
