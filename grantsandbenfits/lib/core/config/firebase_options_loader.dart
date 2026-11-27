import 'package:firebase_core/firebase_core.dart';
import 'package:grantsandbenfits/core/config/app_config.dart';

/// Builds [FirebaseOptions] from compile-time defines so the project file
/// never contains a key.
class FirebaseOptionsLoader {
  const FirebaseOptionsLoader._();

  static FirebaseOptions fromConfig(AppConfig config) {
    final authDomain = config.firebaseAuthDomain;
    final storageBucket = config.firebaseStorageBucket;
    return FirebaseOptions(
      apiKey: config.firebaseApiKey,
      appId: config.appIdForCurrentPlatform(),
      messagingSenderId: config.firebaseMessagingSenderId,
      projectId: config.firebaseProjectId,
      authDomain: authDomain.isEmpty ? null : authDomain,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
    );
  }
}
