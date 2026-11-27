import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/core/security/input_validator.dart';

void main() {
  test('email accepts a normal address and rejects a fragment', () {
    expect(InputValidator.email('ada@example.com'), isNull);
    expect(InputValidator.email('not-an-email'), isNotNull);
    expect(InputValidator.normalizeEmail('  Ada@Example.com '), 'ada@example.com');
  });

  test('password requires length, case, a number, and a symbol', () {
    expect(InputValidator.password('short'), isNotNull);
    expect(InputValidator.password('Good-Pass1'), isNull);
    expect(
      InputValidator.password('ada-Secret1', email: 'ada@example.com'),
      isNotNull,
    );
  });

  test('name allows letters and rejects digits', () {
    expect(InputValidator.name('Ada Lovelace'), isNull);
    expect(InputValidator.name("O'Connor"), isNull);
    expect(InputValidator.name('Ada1'), isNotNull);
  });
}
