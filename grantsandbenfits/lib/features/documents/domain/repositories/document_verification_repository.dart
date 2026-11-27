import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/uploaded_document.dart';

abstract interface class DocumentVerificationRepository {
  Future<Result<DocumentVerificationResult>> verifyDocument(
    UploadedDocument document,
  );

  Future<List<DocumentVerificationResult>> loadApprovedDocuments();

  Future<List<DocumentVerificationResult>> loadLatestDocuments();
}
