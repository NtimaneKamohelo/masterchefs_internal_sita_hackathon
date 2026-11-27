import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/core/database/parameterized_query.dart';

void main() {
  test('accepts bound parameters and rejects embedded quotes', () {
    final query = ParameterizedQuery(
      statement: 'select id from users where email = ?',
      parameters: ['ada@example.com'],
    );
    expect(query.parameters, ['ada@example.com']);

    expect(
      () => ParameterizedQuery(
        statement: "select id from users where email = 'ada@example.com'",
        parameters: const [],
      ),
      throwsArgumentError,
    );
  });
}
