import 'package:bcrypt/bcrypt.dart';

/// Bcrypt hasher for the on-device demo account store.
///
/// Firebase Auth salts and hashes passwords on the server. Do not hash a
/// password before passing it to Firebase, or the hash becomes the password.
class PasswordHasher {
  PasswordHasher({this.logRounds = 10});

  /// Burn time when an email is missing so the failure is not faster.
  static const dummyHash =
      r'$2a$10$Yh5aw8xmKr3TS1Gk2UX98Oz7PT.Qhz5nnmGBb4dnayrTitMIDTKhK';

  final int logRounds;

  String hash(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt(logRounds: logRounds));
  }

  bool verify(String password, String hashed) {
    try {
      return BCrypt.checkpw(password, hashed);
    } catch (_) {
      return false;
    }
  }
}
