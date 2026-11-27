import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';
import 'package:grantsandbenfits/features/documents/domain/repositories/document_verification_repository.dart';
import 'package:grantsandbenfits/features/eligibility/domain/entities/eligibility_assessment.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';
import 'package:grantsandbenfits/features/profile/domain/repositories/profile_repository.dart';

class EvaluateEligibility {
  const EvaluateEligibility({
    required ProfileRepository profileRepository,
    required DocumentVerificationRepository documentRepository,
  }) : _profiles = profileRepository,
       _documents = documentRepository;

  final ProfileRepository _profiles;
  final DocumentVerificationRepository _documents;

  static const _coreRequiredTypes = [
    DocumentType.southAfricanId,
    DocumentType.payslip,
    DocumentType.academicTranscript,
    DocumentType.proofOfResidence,
    DocumentType.bankStatement,
  ];

  Future<Result<EligibilityAssessment>> call(String userId) async {
    final profileResult = await _profiles.loadProfile(userId);
    final profile = profileResult is Ok<UserProfile?> ? profileResult.value : null;
    final latestDocs = await _documents.loadLatestDocuments();
    final byType = {for (final doc in latestDocs) doc.documentType: doc};

    final items = <DocumentValidationItem>[];
    for (final type in _coreRequiredTypes) {
      final scan = byType[type];
      if (scan == null) {
        items.add(
          DocumentValidationItem(
            type: type,
            status: DocumentCheckStatus.notValidated,
            detail: 'Not uploaded yet. Upload a SAPS or Post Office certified copy.',
          ),
        );
      } else if (scan.verdict == VerificationVerdict.authentic) {
        items.add(
          DocumentValidationItem(
            type: type,
            status: DocumentCheckStatus.validated,
            detail: 'Certified by ${scan.authority.label}.',
            fileName: scan.fileName,
            authority: scan.authority,
          ),
        );
      } else if (scan.verdict == VerificationVerdict.needsReview) {
        items.add(
          DocumentValidationItem(
            type: type,
            status: DocumentCheckStatus.requiresReview,
            detail:
                'Flagged for official review (expired stamp or low-confidence signature).',
            fileName: scan.fileName,
            authority: scan.authority,
          ),
        );
      } else {
        items.add(
          DocumentValidationItem(
            type: type,
            status: DocumentCheckStatus.notValidated,
            detail:
                'Failed validation (${scan.authority.label}). Re-upload a valid SAPS/Post Office copy.',
            fileName: scan.fileName,
            authority: scan.authority,
          ),
        );
      }
    }

    final profileComplete = profile != null;
    final idValidated = byType[DocumentType.southAfricanId]?.verdict ==
        VerificationVerdict.authentic;
    final validatedCount = items
        .where((i) => i.status == DocumentCheckStatus.validated)
        .length;
    final hasReviewDoc = items.any(
      (i) => i.status == DocumentCheckStatus.requiresReview,
    );
    final hasRejectedDoc = latestDocs.any(
      (d) => d.verdict == VerificationVerdict.notAuthentic,
    );

    final (recommendation, confidence, requiresReview, explanation) = _score(
      profile: profile,
      idValidated: idValidated,
      validatedCount: validatedCount,
      hasReviewDoc: hasReviewDoc,
      hasRejectedDoc: hasRejectedDoc,
    );

    final popiaRules = _buildPopiaRules(profileComplete: profileComplete);

    return Ok(
      EligibilityAssessment(
        recommendation: recommendation,
        confidence: confidence,
        requiresReview: requiresReview,
        profileComplete: profileComplete,
        documents: items,
        popiaRules: popiaRules,
        explanation: explanation,
      ),
    );
  }

  (EligibilityRecommendation, double, bool, String) _score({
    required UserProfile? profile,
    required bool idValidated,
    required int validatedCount,
    required bool hasReviewDoc,
    required bool hasRejectedDoc,
  }) {
    final profileComplete = profile != null;
    if (profile != null && !profile.meetsNsfasIncomeThreshold) {
      final threshold = profile.nsfasIncomeThreshold;
      return (
        EligibilityRecommendation.needsReview,
        0.78,
        true,
        'Flagged under rule INC-01: Declared annual household income (R${profile.annualHouseholdIncome}) '
            'exceeds the applicable NSFAS threshold of R$threshold '
            '(${profile.hasDisability ? "disability threshold" : "standard threshold"}). '
            'Escalated for official review — no application is declined automatically.',
      );
    }

    if (profileComplete && idValidated && validatedCount >= 2 && !hasReviewDoc && !hasRejectedDoc) {
      return (
        EligibilityRecommendation.likelyEligible,
        0.92,
        false,
        'Passed rules PROF-01, CERT-01, and CERT-02: Applicant profile is complete and '
            '$validatedCount certified document(s) (including South African ID) passed SAPS/Post Office validation. '
            'Recommended as Likely Eligible for official approval.',
      );
    }

    if (hasReviewDoc || (profileComplete && validatedCount >= 1)) {
      return (
        EligibilityRecommendation.needsReview,
        0.68,
        true,
        'Escalated under PAJA & POPIA Section 71: Some documents require official review or additional '
            'supporting evidence is still missing ($validatedCount of ${_coreRequiredTypes.length} validated). '
            'Low-confidence or incomplete cases are escalated rather than guessed.',
      );
    }

    return (
      EligibilityRecommendation.notEligible,
      0.85,
      true,
      'Flagged under rules PROF-01 / CERT-01: Applicant profile or required SAPS/Post Office certified '
          'documents have not been validated yet. No application is declined automatically — '
          'an accountable official must review this case.',
    );
  }

  List<PopiaRuleItem> _buildPopiaRules({required bool profileComplete}) {
    return [
      const PopiaRuleItem(
        code: 'POPIA-01',
        title: 'Purpose Limitation (Section 13)',
        description:
            'Personal information is collected and processed solely to assess bursary and grant eligibility.',
        satisfied: true,
      ),
      PopiaRuleItem(
        code: 'POPIA-02',
        title: 'Data Minimisation (Section 10)',
        description:
            'Only essential fields are collected; 13-digit SA ID numbers are masked in summaries and never logged.',
        satisfied: true,
      ),
      const PopiaRuleItem(
        code: 'POPIA-03',
        title: 'Consent & Transparency (Section 11)',
        description:
            'Explicit POPIA consent was recorded at account registration before any data processing.',
        satisfied: true,
      ),
      PopiaRuleItem(
        code: 'POPIA-04',
        title: 'Security Safeguards (Section 19)',
        description:
            'Profiles and sessions are encrypted at rest in platform secure storage and isolated per user.',
        satisfied: profileComplete,
      ),
      const PopiaRuleItem(
        code: 'POPIA-05',
        title: 'Automated Decision-Making Safeguard (Section 71)',
        description:
            'No application is declined automatically. Low-confidence or incomplete cases are escalated to an official.',
        satisfied: true,
      ),
      const PopiaRuleItem(
        code: 'POPIA-06',
        title: 'Fairness & Auditability (PAJA + POPIA)',
        description:
            'Avoids discriminatory proxies and logs every scan and rule citation without storing raw document bytes.',
        satisfied: true,
      ),
    ];
  }
}
