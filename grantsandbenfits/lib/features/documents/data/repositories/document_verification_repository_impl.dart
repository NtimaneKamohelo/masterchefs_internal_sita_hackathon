import 'package:grantsandbenfits/core/error/failure.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/documents/data/datasources/document_verification_data_source.dart';
import 'package:grantsandbenfits/features/documents/data/document_audit_logger.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/uploaded_document.dart';
import 'package:grantsandbenfits/features/documents/domain/repositories/document_verification_repository.dart';

class DocumentVerificationRepositoryImpl
    implements DocumentVerificationRepository {
  DocumentVerificationRepositoryImpl({
    required DocumentVerificationDataSource remote,
    required DocumentAuditLogger audit,
  }) : _remote = remote,
       _audit = audit;

  final DocumentVerificationDataSource _remote;
  final DocumentAuditLogger _audit;

  @override
  Future<Result<DocumentVerificationResult>> verifyDocument(
    UploadedDocument document,
  ) async {
    try {
      final result = await _remote.analyze(document);
      try {
        await _audit.log(result);
      } catch (_) {
        reportDocumentAuditFailure();
      }
      return Ok(result);
    } catch (_) {
      return const Err(
        ValidationFailure(
          'The document could not be scanned. Please try again.',
        ),
      );
    }
  }
}
