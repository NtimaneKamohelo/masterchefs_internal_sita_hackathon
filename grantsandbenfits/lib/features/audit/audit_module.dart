/// Next: recommendation, rule version, evidence, and human action log.
/// Auth events are already written by AuthAuditLogger.
abstract final class AuditModule {
  static const boundary = 'audit';
}
