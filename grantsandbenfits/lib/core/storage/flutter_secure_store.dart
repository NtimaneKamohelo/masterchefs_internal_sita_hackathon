import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grantsandbenfits/core/storage/secure_store.dart';

/// Platform secure storage: Android Keystore, iOS Keychain, and Windows DPAPI.
class FlutterSecureStore implements SecureStore {
  FlutterSecureStore({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
