import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';

enum DocumentCheckStatus {
  validated('Validated'),
  requiresReview('Requires Review'),
  notValidated('Not Validated');

  const DocumentCheckStatus(this.label);

  final String label;
}

enum EligibilityRecommendation {
  likelyEligible('Likely Eligible'),
  needsReview('Needs Official Review'),
  notEligible('Not Eligible (Pending Official Review)');

  const EligibilityRecommendation(this.label);

  final String label;
}

class DocumentValidationItem extends Equatable {
  const DocumentValidationItem({
    required this.type,
    required this.status,
    required this.detail,
    this.fileName,
    this.authority,
  });

  final DocumentType type;
  final DocumentCheckStatus status;
  final String detail;
  final String? fileName;
  final CertifyingAuthority? authority;

  @override
  List<Object?> get props => [type, status, detail, fileName, authority];
}

class PopiaRuleItem extends Equatable {
  const PopiaRuleItem({
    required this.code,
    required this.title,
    required this.description,
    required this.satisfied,
  });

  final String code;
  final String title;
  final String description;
  final bool satisfied;

  @override
  List<Object?> get props => [code, title, description, satisfied];
}

class EligibilityAssessment extends Equatable {
  const EligibilityAssessment({
    required this.recommendation,
    required this.confidence,
    required this.requiresReview,
    required this.profileComplete,
    required this.documents,
    required this.popiaRules,
    required this.explanation,
  });

  final EligibilityRecommendation recommendation;
  final double confidence;
  final bool requiresReview;
  final bool profileComplete;
  final List<DocumentValidationItem> documents;
  final List<PopiaRuleItem> popiaRules;
  final String explanation;

  int get validatedCount => documents
      .where((d) => d.status == DocumentCheckStatus.validated)
      .length;

  int get reviewCount => documents
      .where((d) => d.status == DocumentCheckStatus.requiresReview)
      .length;

  @override
  List<Object?> get props => [
    recommendation,
    confidence,
    requiresReview,
    profileComplete,
    documents,
    popiaRules,
    explanation,
  ];
}
