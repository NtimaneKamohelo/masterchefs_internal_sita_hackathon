import 'dart:convert';

import 'package:grantsandbenfits/core/storage/secure_store.dart';
import 'package:grantsandbenfits/core/storage/storage_keys.dart';
import 'package:grantsandbenfits/features/profile/data/datasources/profile_data_source.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';

/// Stores each user's profile in encrypted platform storage keyed by userId,
/// enforcing record-level isolation on the device.
class LocalProfileDataSource implements ProfileDataSource {
  LocalProfileDataSource(this._store);

  final SecureStore _store;

  @override
  Future<UserProfile?> read(String userId) async {
    final raw = await _store.read(StorageKeys.profile(userId));
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;

    final updatedRaw = decoded['updatedAt'];
    return UserProfile(
      userId: userId,
      fullName: decoded['fullName'] as String? ?? '',
      idNumber: decoded['idNumber'] as String? ?? '',
      streetAddress: decoded['streetAddress'] as String? ?? '',
      city: decoded['city'] as String? ?? '',
      province: decoded['province'] as String? ?? southAfricanProvinces.first,
      postalCode: decoded['postalCode'] as String? ?? '',
      phoneNumber: decoded['phoneNumber'] as String? ?? '',
      updatedAt: updatedRaw is String ? DateTime.tryParse(updatedRaw) : null,
    );
  }

  @override
  Future<UserProfile> write(UserProfile profile) async {
    final saved = UserProfile(
      userId: profile.userId,
      fullName: profile.fullName,
      idNumber: profile.idNumber,
      streetAddress: profile.streetAddress,
      city: profile.city,
      province: profile.province,
      postalCode: profile.postalCode,
      phoneNumber: profile.phoneNumber,
      updatedAt: profile.updatedAt ?? DateTime.now().toUtc(),
    );
    await _store.write(
      StorageKeys.profile(saved.userId),
      jsonEncode({
        'fullName': saved.fullName,
        'idNumber': saved.idNumber,
        'streetAddress': saved.streetAddress,
        'city': saved.city,
        'province': saved.province,
        'postalCode': saved.postalCode,
        'phoneNumber': saved.phoneNumber,
        'updatedAt': saved.updatedAt?.toIso8601String(),
      }),
    );
    return saved;
  }
}
