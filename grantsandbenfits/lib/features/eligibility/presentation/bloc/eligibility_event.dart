import 'package:equatable/equatable.dart';

sealed class EligibilityEvent extends Equatable {
  const EligibilityEvent();

  @override
  List<Object?> get props => [];
}

final class EligibilityLoadRequested extends EligibilityEvent {
  const EligibilityLoadRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

final class OfficialDecisionSubmitted extends EligibilityEvent {
  const OfficialDecisionSubmitted({
    required this.action,
    required this.reason,
  });

  final String action;
  final String reason;

  @override
  List<Object?> get props => [action, reason];
}
