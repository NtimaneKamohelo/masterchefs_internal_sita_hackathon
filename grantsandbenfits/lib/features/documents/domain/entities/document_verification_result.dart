import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';

enum VerificationVerdict {
  authentic('Likely Authentic'),
  needsReview('Needs Official Review'),
  notAuthentic('Not Certified / Rejected');

  const VerificationVerdict(this.label);

  final String label;
}

enum CertifyingAuthority {
  saps('South African Police Service (SAPS)'),
  postOffice('South African Post Office (SAPO)'),
  unknown('Unrecognised Authority'),
  none('No Certification Stamp Found');

  const CertifyingAuthority(this.label);

  final String label;

  bool get isApproved => this == saps || this == postOffice;
}

class VerificationCheck extends Equatable {
  const VerificationCheck({
    required this.ruleCode,
    required this.title,
    required this.passed,
    required this.detail,
  });

  final String ruleCode;
  final String title;
  final bool passed;
  final String detail;

  @override
  List<Object?> get props => [ruleCode, title, passed, detail];
}

class DocumentVerificationResult extends Equatable {
  const DocumentVerificationResult({
    required this.id,
    required this.fileName,
    required this.documentType,
    required this.verdict,
    required this.authority,
    required this.confidence,
    required this.scannedAt,
    required this.checks,
    required this.extractedSummary,
    required this.explanation,
    required this.popiaRedacted,
    this.certificationDate,
    this.isSyntheticDemo = false,
  });

  final String id;
  final String fileName;
  final DocumentType documentType;
  final VerificationVerdict verdict;
  final CertifyingAuthority authority;
  final double confidence;
  final DateTime scannedAt;
  final List<VerificationCheck> checks;
  final Map<String, String> extractedSummary;
  final String explanation;
  final bool popiaRedacted;
  final DateTime? certificationDate;
  final bool isSyntheticDemo;

  @override
  List<Object?> get props => [
    id,
    fileName,
    documentType,
    verdict,
    authority,
    confidence,
    scannedAt,
    checks,
    extractedSummary,
    explanation,
    popiaRedacted,
    certificationDate,
    isSyntheticDemo,
  ];
}
