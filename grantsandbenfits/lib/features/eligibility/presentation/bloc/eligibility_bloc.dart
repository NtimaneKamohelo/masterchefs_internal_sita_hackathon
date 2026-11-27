import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/eligibility/domain/usecases/evaluate_eligibility.dart';
import 'package:grantsandbenfits/features/eligibility/presentation/bloc/eligibility_event.dart';
import 'package:grantsandbenfits/features/eligibility/presentation/bloc/eligibility_state.dart';

class EligibilityBloc extends Bloc<EligibilityEvent, EligibilityState> {
  EligibilityBloc({required EvaluateEligibility evaluateEligibility})
    : _evaluate = evaluateEligibility,
      super(const EligibilityState()) {
    on<EligibilityLoadRequested>(_onLoad);
  }

  final EvaluateEligibility _evaluate;

  Future<void> _onLoad(
    EligibilityLoadRequested event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _evaluate(event.userId);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(isLoading: false, assessment: value));
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }
}
