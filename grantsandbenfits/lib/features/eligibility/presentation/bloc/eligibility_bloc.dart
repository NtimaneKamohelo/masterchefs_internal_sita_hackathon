import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/core/security/content_sanitizer.dart';
import 'package:grantsandbenfits/features/eligibility/data/official_decision_logger.dart';
import 'package:grantsandbenfits/features/eligibility/domain/usecases/evaluate_eligibility.dart';
import 'package:grantsandbenfits/features/eligibility/presentation/bloc/eligibility_event.dart';
import 'package:grantsandbenfits/features/eligibility/presentation/bloc/eligibility_state.dart';

class EligibilityBloc extends Bloc<EligibilityEvent, EligibilityState> {
  EligibilityBloc({
    required EvaluateEligibility evaluateEligibility,
    required OfficialDecisionLogger decisionLogger,
  }) : _evaluate = evaluateEligibility,
       _decisionLogger = decisionLogger,
       super(const EligibilityState()) {
    on<EligibilityLoadRequested>(_onLoad);
    on<OfficialDecisionSubmitted>(_onDecisionSubmitted);
  }

  final EvaluateEligibility _evaluate;
  final OfficialDecisionLogger _decisionLogger;

  Future<void> _onLoad(
    EligibilityLoadRequested event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearInfo: true));
    final result = await _evaluate(event.userId);
    final auditTrail = await _decisionLogger.readAll();
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            isLoading: false,
            assessment: value,
            auditTrail: auditTrail,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            isLoading: false,
            auditTrail: auditTrail,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _onDecisionSubmitted(
    OfficialDecisionSubmitted event,
    Emitter<EligibilityState> emit,
  ) async {
    final cleanReason = ContentSanitizer.sanitizePlainText(
      event.reason,
      maxLength: 200,
    );
    if (cleanReason.length < 5) {
      emit(
        state.copyWith(
          errorMessage:
              'Enter a clear PAJA reason (at least 5 characters) before recording an official decision.',
          clearInfo: true,
        ),
      );
      return;
    }

    final updated = await _decisionLogger.record(
      action: event.action,
      reason: cleanReason,
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        auditTrail: updated,
        clearError: true,
        infoMessage: 'Official decision "${event.action}" logged to the audit trail.',
      ),
    );
  }
}
