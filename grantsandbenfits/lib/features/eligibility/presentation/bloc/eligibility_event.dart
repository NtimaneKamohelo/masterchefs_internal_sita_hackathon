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
