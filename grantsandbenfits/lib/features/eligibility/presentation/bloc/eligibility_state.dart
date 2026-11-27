import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/eligibility/domain/entities/eligibility_assessment.dart';

class EligibilityState extends Equatable {
  const EligibilityState({
    this.isLoading = false,
    this.assessment,
    this.errorMessage,
  });

  final bool isLoading;
  final EligibilityAssessment? assessment;
  final String? errorMessage;

  EligibilityState copyWith({
    bool? isLoading,
    EligibilityAssessment? assessment,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EligibilityState(
      isLoading: isLoading ?? this.isLoading,
      assessment: assessment ?? this.assessment,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, assessment, errorMessage];
}
