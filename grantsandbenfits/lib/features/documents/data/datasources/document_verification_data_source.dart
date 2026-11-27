import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/uploaded_document.dart';

abstract interface class DocumentVerificationDataSource {
  Future<DocumentVerificationResult> analyze(UploadedDocument document);
}
