import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

final class ProfileSaveRequested extends ProfileEvent {
  const ProfileSaveRequested(this.profile);

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}
