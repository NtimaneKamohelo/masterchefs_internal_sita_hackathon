import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:grantsandbenfits/core/storage/secure_store.dart';
import 'package:grantsandbenfits/core/storage/storage_keys.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';

/// Logs document verification outcomes for the PAJA/POPIA audit trail.
/// Never stores raw document bytes or unmasked personal information.
class DocumentAuditLogger {
  DocumentAuditLogger(this._store);

  static const _maxEvents = 50;

  final SecureStore _store;

  Future<void> log(DocumentVerificationResult result) async {
    final events = await _read();
    events.add({
      'id': result.id,
      'at': result.scannedAt.toUtc().toIso8601String(),
      'documentType': result.documentType.name,
      'verdict': result.verdict.name,
      'authority': result.authority.name,
      'confidence': result.confidence.toStringAsFixed(2),
      'popiaRedacted': '${result.popiaRedacted}',
    });
    final trimmed = events.length > _maxEvents
        ? events.sublist(events.length - _maxEvents)
        : events;
    await _store.write(StorageKeys.documentAudit, jsonEncode(trimmed));
  }

  Future<List<Map<String, String>>> _read() async {
    final raw = await _store.read(StorageKeys.documentAudit);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return [
      for (final item in decoded)
        if (item is Map)
          {
            for (final entry in item.entries)
              if (entry.value != null) '${entry.key}': '${entry.value}',
          },
    ];
  }
}

void reportDocumentAuditFailure() {
  debugPrint('Document audit log could not be written.');
}
