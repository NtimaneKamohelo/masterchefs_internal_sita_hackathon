import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/documents/domain/usecases/verify_certified_document.dart';
import 'package:grantsandbenfits/features/documents/presentation/bloc/document_verification_event.dart';
import 'package:grantsandbenfits/features/documents/presentation/bloc/document_verification_state.dart';

class DocumentVerificationBloc
    extends Bloc<DocumentVerificationEvent, DocumentVerificationState> {
  DocumentVerificationBloc({
    required VerifyCertifiedDocument verifyCertifiedDocument,
  }) : _verify = verifyCertifiedDocument,
       super(const DocumentVerificationState()) {
    on<DocumentTypeSelected>(_onTypeSelected);
    on<DocumentScanRequested>(_onScanRequested);
    on<DocumentMessageCleared>(_onMessageCleared);
  }

  final VerifyCertifiedDocument _verify;

  void _onTypeSelected(
    DocumentTypeSelected event,
    Emitter<DocumentVerificationState> emit,
  ) {
    emit(state.copyWith(selectedType: event.type, clearError: true));
  }

  Future<void> _onScanRequested(
    DocumentScanRequested event,
    Emitter<DocumentVerificationState> emit,
  ) async {
    emit(state.copyWith(isScanning: true, clearError: true));
    final result = await _verify(event.document);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            isScanning: false,
            latestResult: value,
            history: [value, ...state.history],
            clearError: true,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            isScanning: false,
            errorMessage: failure.message,
          ),
        );
    }
  }

  void _onMessageCleared(
    DocumentMessageCleared event,
    Emitter<DocumentVerificationState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }
}
