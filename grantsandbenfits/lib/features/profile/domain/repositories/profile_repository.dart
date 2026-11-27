import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<Result<UserProfile?>> loadProfile(String userId);

  Future<Result<UserProfile>> saveProfile(UserProfile profile);
}
