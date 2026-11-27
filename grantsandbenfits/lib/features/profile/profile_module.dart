/// Next: name, South African ID number, and address for the signed-in person.
/// Encrypt the record at rest and allow only that person to read it.
abstract final class ProfileModule {
  static const boundary = 'profile';
}
