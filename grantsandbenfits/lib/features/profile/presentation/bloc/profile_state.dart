import 'package:equatable/equatable.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.profile,
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoading;
  final bool isSaving;
  final UserProfile? profile;
  final String? errorMessage;
  final String? infoMessage;

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    UserProfile? profile,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    profile,
    errorMessage,
    infoMessage,
  ];
}
