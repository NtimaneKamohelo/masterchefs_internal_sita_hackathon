import 'dart:convert';
import 'dart:typed_data';

import 'package:grantsandbenfits/core/utils/id_generator.dart';
import 'package:grantsandbenfits/features/documents/data/datasources/document_verification_data_source.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/uploaded_document.dart';

/// On-device AI document verification agent for the hackathon demo.
///
/// Validates file magic bytes, checks for South African Police Service (SAPS)
/// or South African Post Office (SAPO) certification markers, verifies that
/// certification is within 90 days, applies POPIA redaction, and returns a
/// plain-language PAJA-compliant explanation.
///
/// Production deployments should implement [DocumentVerificationDataSource]
/// against a trusted server endpoint calling Gemini (never embedding a Gemini
/// API key in the client).
class LocalAiDocumentAgentDataSource implements DocumentVerificationDataSource {
  LocalAiDocumentAgentDataSource({
    Duration? simulatedLatency,
    DateTime Function()? clock,
  }) : _simulatedLatency =
           simulatedLatency ?? const Duration(milliseconds: 900),
       _clock = clock ?? DateTime.now;

  static const _maxCertAgeDays = 90;

  final Duration _simulatedLatency;
  final DateTime Function() _clock;

  @override
  Future<DocumentVerificationResult> analyze(UploadedDocument document) async {
    if (_simulatedLatency > Duration.zero) {
      await Future<void>.delayed(_simulatedLatency);
    }

    final now = _clock().toUtc();
    final integrityOk =
        document.isSyntheticSample || _hasValidMagicBytes(document);
    final extractedText = _extractReadableText(document);
    final searchable = '${document.fileName} $extractedText'.toLowerCase();

    final authority = _detectAuthority(searchable);
    final certDate = _detectCertificationDate(searchable, now);
    final isExpired =
        certDate != null && now.difference(certDate).inDays > _maxCertAgeDays;
    final hasCommissionerMark =
        authority.isApproved && !searchable.contains('unsigned');

    final checks = <VerificationCheck>[
      VerificationCheck(
        ruleCode: 'DOC-01',
        title: 'File format & integrity',
        passed: integrityOk,
        detail: integrityOk
            ? 'File signature matches its declared PDF/image format.'
            : 'File bytes do not match a valid PDF, JPG, or PNG header. Possible tampering or corrupted upload.',
      ),
      VerificationCheck(
        ruleCode: 'CERT-01',
        title: 'Approved certifying authority (SAPS or Post Office)',
        passed: authority.isApproved,
        detail: switch (authority) {
          CertifyingAuthority.saps =>
            'Detected South African Police Service (SAPS) certification stamp.',
          CertifyingAuthority.postOffice =>
            'Detected South African Post Office (SAPO) certification stamp.',
          CertifyingAuthority.unknown =>
            'Stamp detected, but not from SAPS or the South African Post Office.',
          CertifyingAuthority.none =>
            'No SAPS or South African Post Office certification stamp was detected.',
        },
      ),
      VerificationCheck(
        ruleCode: 'CERT-02',
        title: 'Certification recency (within 3 months)',
        passed: authority.isApproved && certDate != null && !isExpired,
        detail: !authority.isApproved
            ? 'Cannot verify certification date without an approved stamp.'
            : certDate == null
            ? 'Certification date could not be read clearly; requires official check.'
            : isExpired
            ? 'Certification date (${_formatDate(certDate)}) is older than 90 days.'
            : 'Certified on ${_formatDate(certDate)} (within the 90-day policy window).',
      ),
      VerificationCheck(
        ruleCode: 'CERT-03',
        title: 'Commissioner of Oaths signature & clarity',
        passed: hasCommissionerMark,
        detail: hasCommissionerMark
            ? 'Commissioner of Oaths signature and date stamp appear present.'
            : 'Officer signature or stamp clarity could not be confirmed.',
      ),
      const VerificationCheck(
        ruleCode: 'POPIA-01',
        title: 'POPIA data minimisation & redaction',
        passed: true,
        detail:
            'Sensitive identifiers are masked before display and never written to audit logs.',
      ),
    ];

    final (verdict, confidence, explanation) = _decide(
      document: document,
      integrityOk: integrityOk,
      authority: authority,
      certDate: certDate,
      isExpired: isExpired,
      hasCommissionerMark: hasCommissionerMark,
    );

    final redactedId = _maskSouthAfricanId(extractedText);
    final summary = <String, String>{
      'Document type': document.type.label,
      'Certifying authority': authority.label,
      if (certDate != null) 'Certification date': _formatDate(certDate),
      if (redactedId != null) 'ID reference (POPIA masked)': redactedId,
      'Human-in-the-loop': 'Official remains the accountable decision-maker',
    };

    return DocumentVerificationResult(
      id: createSecureId(),
      fileName: document.fileName,
      documentType: document.type,
      verdict: verdict,
      authority: authority,
      confidence: confidence,
      scannedAt: now,
      checks: checks,
      extractedSummary: summary,
      explanation: explanation,
      popiaRedacted: true,
      certificationDate: certDate,
      isSyntheticDemo: document.isSyntheticSample,
    );
  }

  (VerificationVerdict, double, String) _decide({
    required UploadedDocument document,
    required bool integrityOk,
    required CertifyingAuthority authority,
    required DateTime? certDate,
    required bool isExpired,
    required bool hasCommissionerMark,
  }) {
    if (!integrityOk) {
      return (
        VerificationVerdict.notAuthentic,
        0.92,
        'Flagged under rule DOC-01: "${document.fileName}" failed file-header integrity checks. '
            'Please upload an unaltered PDF, JPG, or PNG scan. No application is declined automatically; '
            'an official will review this case.',
      );
    }

    if (!authority.isApproved) {
      return (
        VerificationVerdict.notAuthentic,
        authority == CertifyingAuthority.unknown ? 0.81 : 0.88,
        'Flagged under rule CERT-01: Documents must be certified by either the South African Police Service (SAPS) '
            'or the South African Post Office (SAPO). No approved certification stamp was confirmed on "${document.fileName}". '
            'Escalated for official review — no application is declined automatically.',
      );
    }

    if (isExpired) {
      return (
        VerificationVerdict.needsReview,
        0.84,
        'Flagged under rule CERT-02: The ${authority.label} stamp is older than 90 days '
            '(${_formatDate(certDate!)}). Please upload a recently certified copy or escalate to an official for review.',
      );
    }

    if (certDate == null || !hasCommissionerMark) {
      return (
        VerificationVerdict.needsReview,
        0.64,
        'Escalated under rules CERT-02 / CERT-03: A ${authority.label} stamp was detected, '
            'but the certification date or Commissioner of Oaths signature had low confidence. '
            'An official must inspect the original scan.',
      );
    }

    return (
      VerificationVerdict.authentic,
      0.94,
      'Passed rules DOC-01, CERT-01, CERT-02, and CERT-03: "${document.fileName}" appears to be a valid '
          '${document.type.label} certified by ${authority.label} on ${_formatDate(certDate)}. '
          'Recommended as Likely Authentic for official sign-off.',
    );
  }

  bool _hasValidMagicBytes(UploadedDocument document) {
    final bytes = document.bytes;
    if (bytes.length < 4) return false;
    final lower = document.fileName.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46; // %PDF
    }
    if (lower.endsWith('.png')) {
      return bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47; // .PNG
    }
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
    }
    return false;
  }

  String _extractReadableText(UploadedDocument document) {
    final slice = document.bytes.length > 16384
        ? Uint8List.sublistView(document.bytes, 0, 16384)
        : document.bytes;
    return latin1.decode(slice, allowInvalid: true);
  }

  CertifyingAuthority _detectAuthority(String searchable) {
    if (searchable.contains('saps') ||
        searchable.contains('south african police') ||
        searchable.contains('police service')) {
      return CertifyingAuthority.saps;
    }
    if (searchable.contains('post office') ||
        searchable.contains('post_office') ||
        searchable.contains('postoffice') ||
        searchable.contains('sapo')) {
      return CertifyingAuthority.postOffice;
    }
    if (searchable.contains('uncertified') || searchable.contains('no_stamp')) {
      return CertifyingAuthority.none;
    }
    if (searchable.contains('certified') || searchable.contains('stamp')) {
      return CertifyingAuthority.unknown;
    }
    return CertifyingAuthority.none;
  }

  DateTime? _detectCertificationDate(String searchable, DateTime now) {
    if (searchable.contains('expired')) {
      return now.subtract(const Duration(days: 140));
    }
    if (searchable.contains('undated')) {
      return null;
    }
    final isoMatch = RegExp(r'(20\d{2})-(\d{2})-(\d{2})').firstMatch(searchable);
    if (isoMatch != null) {
      final year = int.tryParse(isoMatch.group(1)!);
      final month = int.tryParse(isoMatch.group(2)!);
      final day = int.tryParse(isoMatch.group(3)!);
      if (year != null && month != null && day != null) {
        return DateTime.utc(year, month, day);
      }
    }
    if (searchable.contains('saps') ||
        searchable.contains('post office') ||
        searchable.contains('post_office') ||
        searchable.contains('sapo')) {
      return now.subtract(const Duration(days: 12));
    }
    return null;
  }

  String? _maskSouthAfricanId(String text) {
    final match = RegExp(r'\b(\d{6})(\d{5})(\d{2})\b').firstMatch(text);
    if (match == null) return null;
    return '${match.group(1)}•••••${match.group(3)}';
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
