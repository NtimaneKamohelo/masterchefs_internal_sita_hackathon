import 'dart:convert';

import 'package:grantsandbenfits/core/storage/secure_store.dart';

class _Attempt {
  const _Attempt({required this.count, this.lockedUntil});

  final int count;
  final DateTime? lockedUntil;
}

/// Locks a bucket after repeated failures. Counts are kept in secure storage
/// so a restart does not clear them.
class LoginRateLimiter {
  LoginRateLimiter(
    this._store, {
    DateTime Function()? clock,
    this.maxAttempts = 5,
    this.lockDuration = const Duration(minutes: 2),
  }) : _clock = clock ?? DateTime.now;

  final SecureStore _store;
  final DateTime Function() _clock;
  final int maxAttempts;
  final Duration lockDuration;

  Future<String?> rejectionReason(String bucket) async {
    final attempt = await _read(bucket);
    final lockedUntil = attempt?.lockedUntil;
    if (lockedUntil == null) return null;
    final now = _clock().toUtc();
    if (!now.isBefore(lockedUntil)) return null;
    final seconds = lockedUntil.difference(now).inSeconds.clamp(1, 86400);
    return 'Too many attempts. Try again in $seconds seconds.';
  }

  Future<void> recordFailure(String bucket) async {
    final now = _clock().toUtc();
    final current = await _read(bucket);
    final attempt = current;
    if (attempt?.lockedUntil != null && now.isBefore(attempt!.lockedUntil!)) {
      return;
    }

    late final int count;
    if (attempt == null ||
        (attempt.lockedUntil != null &&
            !now.isBefore(attempt.lockedUntil!))) {
      count = 1;
    } else {
      count = attempt.count + 1;
    }
    final lockedUntil = count >= maxAttempts ? now.add(lockDuration) : null;
    await _store.write(
      _key(bucket),
      jsonEncode({
        'count': count,
        'lockedUntil': lockedUntil?.toIso8601String(),
      }),
    );
  }

  Future<void> recordSuccess(String bucket) => _store.delete(_key(bucket));

  Future<_Attempt?> _read(String bucket) async {
    final raw = await _store.read(_key(bucket));
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final count = decoded['count'];
    final lockedRaw = decoded['lockedUntil'];
    if (count is! int) return null;
    return _Attempt(
      count: count,
      lockedUntil: lockedRaw is String ? DateTime.tryParse(lockedRaw) : null,
    );
  }

  String _key(String bucket) => 'gb.ratelimit.$bucket';
}
