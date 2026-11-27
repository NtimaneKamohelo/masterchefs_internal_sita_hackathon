import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_type.dart';
import 'package:grantsandbenfits/features/documents/domain/entities/document_verification_result.dart';

class DocumentVerificationState extends Equatable {
  const DocumentVerificationState({
    this.selectedType = DocumentType.southAfricanId,
    this.isScanning = false,
    this.latestResult,
    this.history = const [],
    this.errorMessage,
  });

  final DocumentType selectedType;
  final bool isScanning;
  final DocumentVerificationResult? latestResult;
  final List<DocumentVerificationResult> history;
  final String? errorMessage;

  DocumentVerificationState copyWith({
    DocumentType? selectedType,
    bool? isScanning,
    DocumentVerificationResult? latestResult,
    List<DocumentVerificationResult>? history,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DocumentVerificationState(
      selectedType: selectedType ?? this.selectedType,
      isScanning: isScanning ?? this.isScanning,
      latestResult: latestResult ?? this.latestResult,
      history: history ?? this.history,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    selectedType,
    isScanning,
    latestResult,
    history,
    errorMessage,
  ];
}
