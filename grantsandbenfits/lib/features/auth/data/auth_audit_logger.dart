import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:grantsandbenfits/core/storage/secure_store.dart';
import 'package:grantsandbenfits/core/storage/storage_keys.dart';

/// Stores sign-in, sign-out, and verification events without passwords,
/// codes, or document contents.
class AuthAuditLogger {
  AuthAuditLogger(this._store);

  static const _maxEvents = 50;

  final SecureStore _store;

  Future<void> log({required String action, String? userId}) async {
    final events = await _read();
    events.add({
      'at': DateTime.now().toUtc().toIso8601String(),
      'action': action,
      'userId': ?userId,
    });
    final trimmed = events.length > _maxEvents
        ? events.sublist(events.length - _maxEvents)
        : events;
    await _store.write(StorageKeys.authAudit, jsonEncode(trimmed));
  }

  Future<List<Map<String, String>>> _read() async {
    final raw = await _store.read(StorageKeys.authAudit);
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

void reportAuditFailure() {
  debugPrint('Auth audit log could not be written.');
}
