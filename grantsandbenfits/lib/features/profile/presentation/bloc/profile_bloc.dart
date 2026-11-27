import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/profile/domain/usecases/profile_use_cases.dart';
import 'package:grantsandbenfits/features/profile/presentation/bloc/profile_event.dart';
import 'package:grantsandbenfits/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required LoadUserProfile loadProfile,
    required SaveUserProfile saveProfile,
  }) : _loadProfile = loadProfile,
       _saveProfile = saveProfile,
       super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileSaveRequested>(_onSave);
  }

  final LoadUserProfile _loadProfile;
  final SaveUserProfile _saveProfile;

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearInfo: true));
    final result = await _loadProfile(event.userId);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(isLoading: false, profile: value));
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }

  Future<void> _onSave(
    ProfileSaveRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearInfo: true));
    final result = await _saveProfile(event.profile);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            isSaving: false,
            profile: value,
            infoMessage:
                'Profile saved securely. Your details will be cross-checked against your uploaded documents.',
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
    }
  }
}
