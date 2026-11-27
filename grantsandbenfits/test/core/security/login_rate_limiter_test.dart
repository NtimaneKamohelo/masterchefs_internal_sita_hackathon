import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/core/security/login_rate_limiter.dart';
import 'package:grantsandbenfits/core/storage/memory_secure_store.dart';

void main() {
  test('locks a bucket after the attempt limit', () async {
    final now = DateTime.utc(2026, 11, 27, 12);
    final limiter = LoginRateLimiter(
      MemorySecureStore(),
      clock: () => now,
      maxAttempts: 3,
      lockDuration: const Duration(minutes: 2),
    );

    expect(await limiter.rejectionReason('signin:ada@example.com'), isNull);
    await limiter.recordFailure('signin:ada@example.com');
    await limiter.recordFailure('signin:ada@example.com');
    expect(await limiter.rejectionReason('signin:ada@example.com'), isNull);

    await limiter.recordFailure('signin:ada@example.com');
    expect(
      await limiter.rejectionReason('signin:ada@example.com'),
      contains('Too many attempts'),
    );

    await limiter.recordSuccess('signin:ada@example.com');
    expect(await limiter.rejectionReason('signin:ada@example.com'), isNull);
  });
}
