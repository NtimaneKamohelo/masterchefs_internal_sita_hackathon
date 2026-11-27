import 'package:grantsandbenfits/core/error/failure.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/core/security/content_sanitizer.dart';
import 'package:grantsandbenfits/core/security/upload_policy.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/uploaded_document.dart';
import 'package:grantsandbenfits/features/documents/domain/repositories/document_verification_repository.dart';

class VerifyCertifiedDocument {
  const VerifyCertifiedDocument(this._repository);

  final DocumentVerificationRepository _repository;

  Future<Result<DocumentVerificationResult>> call(
    UploadedDocument document,
  ) async {
    final cleanName = ContentSanitizer.sanitizePlainText(
      document.fileName,
      maxLength: 120,
    );
    final policyError = UploadPolicy.validate(
      fileName: cleanName,
      sizeBytes: document.sizeBytes,
    );
    if (policyError != null) {
      return Err(ValidationFailure(policyError));
    }

    return _repository.verifyDocument(
      UploadedDocument(
        fileName: cleanName,
        sizeBytes: document.sizeBytes,
        type: document.type,
        bytes: document.bytes,
        isSyntheticSample: document.isSyntheticSample,
      ),
    );
  }
}
