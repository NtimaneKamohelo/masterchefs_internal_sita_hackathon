/// Next: certified document upload, completeness checks, and mismatch flags.
/// Reject files that fail the upload policy before they are stored.
abstract final class DocumentsModule {
  static const boundary = 'documents';
}
