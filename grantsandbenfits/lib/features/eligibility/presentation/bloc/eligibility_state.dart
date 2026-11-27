import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/eligibility/data/official_decision_logger.dart';
import 'package:grantsandbenfits/features/eligibility/domain/entities/eligibility_assessment.dart';

class EligibilityState extends Equatable {
  const EligibilityState({
    this.isLoading = false,
    this.assessment,
    this.auditTrail = const [],
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoading;
  final EligibilityAssessment? assessment;
  final List<OfficialDecisionRecord> auditTrail;
  final String? errorMessage;
  final String? infoMessage;

  EligibilityState copyWith({
    bool? isLoading,
    EligibilityAssessment? assessment,
    List<OfficialDecisionRecord>? auditTrail,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
  }) {
    return EligibilityState(
      isLoading: isLoading ?? this.isLoading,
      assessment: assessment ?? this.assessment,
      auditTrail: auditTrail ?? this.auditTrail,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    assessment,
    auditTrail,
    errorMessage,
    infoMessage,
  ];
}
