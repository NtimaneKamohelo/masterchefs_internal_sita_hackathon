/// Encrypted key-value store. Implementations must not keep passwords.
abstract interface class SecureStore {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);
}
