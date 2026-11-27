import 'package:grantsandbenfits/core/error/failure.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/profile/data/datasources/profile_data_source.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';
import 'package:grantsandbenfits/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dataSource);

  final ProfileDataSource _dataSource;

  @override
  Future<Result<UserProfile?>> loadProfile(String userId) async {
    try {
      return Ok(await _dataSource.read(userId));
    } catch (_) {
      return const Err(
        ValidationFailure('Could not load your saved profile.'),
      );
    }
  }

  @override
  Future<Result<UserProfile>> saveProfile(UserProfile profile) async {
    try {
      return Ok(await _dataSource.write(profile));
    } catch (_) {
      return const Err(
        ValidationFailure('Could not save your profile. Please try again.'),
      );
    }
  }
}
