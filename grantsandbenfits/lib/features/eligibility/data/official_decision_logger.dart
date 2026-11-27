import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/core/storage/secure_store.dart';
import 'package:grantsandbenfits/core/storage/storage_keys.dart';

class OfficialDecisionRecord extends Equatable {
  const OfficialDecisionRecord({
    required this.action,
    required this.reason,
    required this.ruleVersion,
    required this.recordedAt,
  });

  final String action;
  final String reason;
  final String ruleVersion;
  final DateTime recordedAt;

  @override
  List<Object?> get props => [action, reason, ruleVersion, recordedAt];
}

/// Logs human-in-the-loop official decisions (Approve / Escalate / Override)
/// with mandatory reasons for the PAJA & POPIA audit trail.
class OfficialDecisionLogger {
  OfficialDecisionLogger(this._store);

  final SecureStore _store;

  Future<List<OfficialDecisionRecord>> readAll() async {
    final raw = await _store.read(StorageKeys.decisionAudit);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [
      for (final item in decoded)
        if (item is Map)
          OfficialDecisionRecord(
            action: item['action'] as String? ?? '',
            reason: item['reason'] as String? ?? '',
            ruleVersion: item['ruleVersion'] as String? ?? 'v1.0',
            recordedAt:
                DateTime.tryParse(item['recordedAt'] as String? ?? '') ??
                DateTime.now().toUtc(),
          ),
    ];
  }

  Future<List<OfficialDecisionRecord>> record({
    required String action,
    required String reason,
    String ruleVersion = 'NSFAS-2026.1',
  }) async {
    final existing = await readAll();
    final updated = [
      OfficialDecisionRecord(
        action: action,
        reason: reason.trim(),
        ruleVersion: ruleVersion,
        recordedAt: DateTime.now().toUtc(),
      ),
      ...existing,
    ];
    final trimmed = updated.length > 30 ? updated.sublist(0, 30) : updated;
    await _store.write(
      StorageKeys.decisionAudit,
      jsonEncode([
        for (final entry in trimmed)
          {
            'action': entry.action,
            'reason': entry.reason,
            'ruleVersion': entry.ruleVersion,
            'recordedAt': entry.recordedAt.toUtc().toIso8601String(),
          },
      ]),
    );
    return trimmed;
  }
}
