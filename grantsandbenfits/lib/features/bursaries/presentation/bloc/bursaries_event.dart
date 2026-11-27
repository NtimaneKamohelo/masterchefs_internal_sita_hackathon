import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_program.dart';

sealed class BursariesEvent extends Equatable {
  const BursariesEvent();

  @override
  List<Object?> get props => [];
}

final class BursariesLoadRequested extends BursariesEvent {
  const BursariesLoadRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

final class BursaryApplyRequested extends BursariesEvent {
  const BursaryApplyRequested(this.bursary);

  final BursaryProgram bursary;

  @override
  List<Object?> get props => [bursary];
}
