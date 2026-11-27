import 'package:grantsandbenfits/core/storage/secure_store.dart';

/// In-memory store used by tests. Production uses [FlutterSecureStore].
class MemorySecureStore implements SecureStore {
  final Map<String, String> _values = {};

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}
