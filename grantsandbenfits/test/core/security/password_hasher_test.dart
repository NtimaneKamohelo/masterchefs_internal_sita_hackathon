import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/core/security/password_hasher.dart';

void main() {
  test('bcrypt hash matches the original password only', () {
    final hasher = PasswordHasher(logRounds: 4);
    final hashed = hasher.hash('Good-Pass1');
    expect(hashed, isNot(contains('Good-Pass1')));
    expect(hasher.verify('Good-Pass1', hashed), isTrue);
    expect(hasher.verify('Good-Pass2', hashed), isFalse);
  });
}
