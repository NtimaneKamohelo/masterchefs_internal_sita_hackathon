import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/uploaded_document.dart';

sealed class DocumentVerificationEvent extends Equatable {
  const DocumentVerificationEvent();

  @override
  List<Object?> get props => [];
}

final class DocumentTypeSelected extends DocumentVerificationEvent {
  const DocumentTypeSelected(this.type);

  final DocumentType type;

  @override
  List<Object?> get props => [type];
}

final class DocumentScanRequested extends DocumentVerificationEvent {
  const DocumentScanRequested(this.document);

  final UploadedDocument document;

  @override
  List<Object?> get props => [document];
}

final class DocumentMessageCleared extends DocumentVerificationEvent {
  const DocumentMessageCleared();
}
