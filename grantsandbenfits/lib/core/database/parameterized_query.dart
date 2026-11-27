/// A SQL statement that can only carry bound parameters.
///
/// The Flutter app does not open MySQL directly. When a Dart API is added,
/// it should accept this object and bind [parameters] on the server.
class ParameterizedQuery {
  ParameterizedQuery({required this.statement, required this.parameters}) {
    if (statement.contains("'") ||
        statement.contains('"') ||
        statement.contains(';')) {
      throw ArgumentError(
        'Query text must not include quotes or extra statements. Bind values as parameters.',
      );
    }
  }

  final String statement;
  final List<Object?> parameters;
}
