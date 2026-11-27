import 'package:grantsandbenfits/core/error/failure.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/core/security/content_sanitizer.dart';
import 'package:grantsandbenfits/core/security/input_validator.dart';
import 'package:grantsandbenfits/features/profile/domain/entities/user_profile.dart';
import 'package:grantsandbenfits/features/profile/domain/repositories/profile_repository.dart';

class LoadUserProfile {
  const LoadUserProfile(this._repository);

  final ProfileRepository _repository;

  Future<Result<UserProfile?>> call(String userId) {
    if (userId.trim().isEmpty) {
      return Future.value(
        const Err(ValidationFailure('Sign in again before loading your profile.')),
      );
    }
    return _repository.loadProfile(userId);
  }
}

class SaveUserProfile {
  const SaveUserProfile(this._repository);

  final ProfileRepository _repository;

  Future<Result<UserProfile>> call(UserProfile profile) async {
    if (profile.userId.trim().isEmpty) {
      return const Err(
        ValidationFailure('Sign in again before saving your profile.'),
      );
    }

    final cleanName = ContentSanitizer.sanitizePlainText(profile.fullName);
    final nameError = InputValidator.name(cleanName);
    if (nameError != null) return Err(ValidationFailure(nameError));

    final cleanId = profile.idNumber.trim();
    final idError = InputValidator.southAfricanId(cleanId);
    if (idError != null) return Err(ValidationFailure(idError));

    final cleanStreet = ContentSanitizer.sanitizePlainText(
      profile.streetAddress,
      maxLength: 160,
    );
    final streetError = InputValidator.streetAddress(cleanStreet);
    if (streetError != null) return Err(ValidationFailure(streetError));

    final cleanCity = ContentSanitizer.sanitizePlainText(
      profile.city,
      maxLength: 80,
    );
    final cityError = InputValidator.city(cleanCity);
    if (cityError != null) return Err(ValidationFailure(cityError));

    if (!southAfricanProvinces.contains(profile.province)) {
      return const Err(ValidationFailure('Select a valid South African province.'));
    }

    final cleanPostal = profile.postalCode.trim();
    final postalError = InputValidator.postalCode(cleanPostal);
    if (postalError != null) return Err(ValidationFailure(postalError));

    final cleanPhone = profile.phoneNumber.trim();
    final phoneError = InputValidator.phoneNumber(cleanPhone);
    if (phoneError != null) return Err(ValidationFailure(phoneError));

    return _repository.saveProfile(
      UserProfile(
        userId: profile.userId,
        fullName: cleanName,
        idNumber: cleanId,
        streetAddress: cleanStreet,
        city: cleanCity,
        province: profile.province,
        postalCode: cleanPostal,
        phoneNumber: cleanPhone,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
