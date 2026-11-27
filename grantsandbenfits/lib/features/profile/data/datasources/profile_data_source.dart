import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';

abstract interface class ProfileDataSource {
  Future<UserProfile?> read(String userId);

  Future<UserProfile> write(UserProfile profile);
}
