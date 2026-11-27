import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/core/storage/memory_secure_store.dart';
import 'package:grantsandbenfits/features/profile/data/datasources/local_profile_data_source.dart';
import 'package:grantsandbenfits/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';
import 'package:grantsandbenfits/features/profile/domain/usecases/profile_use_cases.dart';

void main() {
  test('saves and loads a valid profile isolated per userId', () async {
    final store = MemorySecureStore();
    final repo = ProfileRepositoryImpl(LocalProfileDataSource(store));
    final save = SaveUserProfile(repo);
    final load = LoadUserProfile(repo);

    final saveResult = await save(
      const UserProfile(
        userId: 'user-1',
        fullName: 'Thabo Mokoena',
        idNumber: '9901015009087',
        streetAddress: '459 Tsitsa Street',
        city: 'Pretoria',
        province: 'Gauteng',
        postalCode: '0048',
        phoneNumber: '0821234567',
      ),
    );
    expect(saveResult, isA<Ok<UserProfile>>());

    final loaded = await load('user-1');
    expect(loaded, isA<Ok<UserProfile?>>());
    final profile = (loaded as Ok<UserProfile?>).value!;
    expect(profile.fullName, 'Thabo Mokoena');
    expect(profile.maskedIdNumber, '990101•••••87');

    // Another user cannot see user-1's profile.
    final other = await load('user-2');
    expect((other as Ok<UserProfile?>).value, isNull);
  });

  test('rejects invalid South African ID checksum', () async {
    final repo = ProfileRepositoryImpl(
      LocalProfileDataSource(MemorySecureStore()),
    );
    final save = SaveUserProfile(repo);

    final result = await save(
      const UserProfile(
        userId: 'user-1',
        fullName: 'Thabo Mokoena',
        idNumber: '9901015009088',
        streetAddress: '459 Tsitsa Street',
        city: 'Pretoria',
        province: 'Gauteng',
        postalCode: '0048',
      ),
    );
    expect(result, isA<Err<UserProfile>>());
  });
}
