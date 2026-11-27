import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/bursaries/domain/usecases/bursary_use_cases.dart';
import 'package:grantsandbenfits/features/bursaries/presentation/bloc/bursaries_event.dart';
import 'package:grantsandbenfits/features/bursaries/presentation/bloc/bursaries_state.dart';

class BursariesBloc extends Bloc<BursariesEvent, BursariesState> {
  BursariesBloc({
    required LoadBursariesDashboard loadDashboard,
    required SubmitBursaryApplication submitApplication,
  }) : _loadDashboard = loadDashboard,
       _submitApplication = submitApplication,
       super(const BursariesState()) {
    on<BursariesLoadRequested>(_onLoad);
    on<BursaryApplyRequested>(_onApply);
  }

  final LoadBursariesDashboard _loadDashboard;
  final SubmitBursaryApplication _submitApplication;

  Future<void> _onLoad(
    BursariesLoadRequested event,
    Emitter<BursariesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearInfo: true));
    final result = await _loadDashboard(event.userId);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            isLoading: false,
            bursaries: value.bursaries,
            applications: value.applications,
            approvedDocuments: value.approvedDocuments,
            profile: value.profile,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }

  Future<void> _onApply(
    BursaryApplyRequested event,
    Emitter<BursariesState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, clearInfo: true));
    final result = await _submitApplication(
      bursary: event.bursary,
      profile: state.profile,
      approvedDocuments: state.approvedDocuments,
    );
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        final updated = [
          value,
          ...state.applications.where((a) => a.bursaryId != value.bursaryId),
        ];
        emit(
          state.copyWith(
            isSubmitting: false,
            applications: updated,
            infoMessage:
                'Application for ${value.bursaryName} submitted with ${value.attachedDocumentNames.length} pre-attached certified document(s). Pending official review.',
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(isSubmitting: false, errorMessage: failure.message));
    }
  }
}
