import 'dart:convert';

import 'package:grantsandbenfits/core/error/failure.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/core/storage/secure_store.dart';
import 'package:grantsandbenfits/core/storage/storage_keys.dart';
import 'package:grantsandbenfits/features/documents/data/datasources/document_verification_data_source.dart';
import 'package:grantsandbenfits/features/documents/data/document_audit_logger.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/uploaded_document.dart';
import 'package:grantsandbenfits/features/documents/domain/repositories/document_verification_repository.dart';

class DocumentVerificationRepositoryImpl
    implements DocumentVerificationRepository {
  DocumentVerificationRepositoryImpl({
    required DocumentVerificationDataSource remote,
    required DocumentAuditLogger audit,
    required SecureStore store,
  }) : _remote = remote,
       _audit = audit,
       _store = store;

  final DocumentVerificationDataSource _remote;
  final DocumentAuditLogger _audit;
  final SecureStore _store;

  @override
  Future<Result<DocumentVerificationResult>> verifyDocument(
    UploadedDocument document,
  ) async {
    try {
      final result = await _remote.analyze(document);
      try {
        await _audit.log(result);
      } catch (_) {
        reportDocumentAuditFailure();
      }
      await _saveLatest(result);
      if (result.verdict == VerificationVerdict.authentic) {
        await _saveApproved(result);
      }
      return Ok(result);
    } catch (_) {
      return const Err(
        ValidationFailure(
          'The document could not be scanned. Please try again.',
        ),
      );
    }
  }

  @override
  Future<List<DocumentVerificationResult>> loadApprovedDocuments() async {
    return _readStoredList(StorageKeys.verifiedDocuments);
  }

  @override
  Future<List<DocumentVerificationResult>> loadLatestDocuments() async {
    return _readStoredList(StorageKeys.latestDocuments);
  }

  Future<List<DocumentVerificationResult>> _readStoredList(String key) async {
    final raw = await _store.read(key);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    final items = <DocumentVerificationResult>[];
    for (final entry in decoded) {
      if (entry is! Map) continue;
      final type = DocumentType.values.firstWhere(
        (t) => t.name == entry['documentType'],
        orElse: () => DocumentType.southAfricanId,
      );
      final verdict = VerificationVerdict.values.firstWhere(
        (v) => v.name == entry['verdict'],
        orElse: () => VerificationVerdict.authentic,
      );
      final authority = CertifyingAuthority.values.firstWhere(
        (a) => a.name == entry['authority'],
        orElse: () => CertifyingAuthority.none,
      );
      items.add(
        DocumentVerificationResult(
          id: entry['id'] as String? ?? '',
          fileName: entry['fileName'] as String? ?? '',
          documentType: type,
          verdict: verdict,
          authority: authority,
          confidence: (entry['confidence'] as num?)?.toDouble() ?? 0.9,
          scannedAt:
              DateTime.tryParse(entry['scannedAt'] as String? ?? '') ??
              DateTime.now().toUtc(),
          checks: const [],
          extractedSummary: const {},
          explanation: entry['explanation'] as String? ?? '',
          popiaRedacted: true,
        ),
      );
    }
    return items;
  }

  Future<void> _saveLatest(DocumentVerificationResult result) =>
      _upsertInList(StorageKeys.latestDocuments, result);

  Future<void> _saveApproved(DocumentVerificationResult result) =>
      _upsertInList(StorageKeys.verifiedDocuments, result);

  Future<void> _upsertInList(
    String key,
    DocumentVerificationResult result,
  ) async {
    final existing = await _readStoredList(key);
    final filtered = existing
        .where((item) => item.documentType != result.documentType)
        .toList();
    filtered.insert(0, result);
    await _store.write(
      key,
      jsonEncode([
        for (final item in filtered)
          {
            'id': item.id,
            'fileName': item.fileName,
            'documentType': item.documentType.name,
            'verdict': item.verdict.name,
            'authority': item.authority.name,
            'confidence': item.confidence,
            'scannedAt': item.scannedAt.toUtc().toIso8601String(),
            'explanation': item.explanation,
          },
      ]),
    );
  }
}
