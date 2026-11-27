import 'package:flutter/foundation.dart';

/// Client configuration loaded from `--dart-define-from-file`.
///
/// The Firebase apiKey is a public client identifier. Access is enforced by
/// Auth, App Check, and security rules, not by hiding that key in source.
/// A Gemini key must never be compiled into this app.
class AppConfig {
  const AppConfig({
    required this.useFirebaseRequested,
    required this.firebaseApiKey,
    required this.firebaseProjectId,
    required this.firebaseMessagingSenderId,
    required this.firebaseAuthDomain,
    required this.firebaseStorageBucket,
    required this.androidAppId,
    required this.iosAppId,
    required this.webAppId,
    required this.windowsAppId,
    required this.fallbackAppId,
    required this.googleServerClientId,
    required this.googleIosClientId,
    required this.appCheckRecaptchaSiteKey,
    required this.appCheckDebugToken,
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      useFirebaseRequested: bool.fromEnvironment('USE_FIREBASE'),
      firebaseApiKey: String.fromEnvironment('FIREBASE_API_KEY'),
      firebaseProjectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
      firebaseMessagingSenderId: String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID',
      ),
      firebaseAuthDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      firebaseStorageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      androidAppId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
      iosAppId: String.fromEnvironment('FIREBASE_IOS_APP_ID'),
      webAppId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
      windowsAppId: String.fromEnvironment('FIREBASE_WINDOWS_APP_ID'),
      fallbackAppId: String.fromEnvironment('FIREBASE_APP_ID'),
      googleServerClientId: String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
      googleIosClientId: String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
      appCheckRecaptchaSiteKey: String.fromEnvironment(
        'APP_CHECK_RECAPTCHA_SITE_KEY',
      ),
      appCheckDebugToken: String.fromEnvironment('APP_CHECK_DEBUG_TOKEN'),
    );
  }

  final bool useFirebaseRequested;
  final String firebaseApiKey;
  final String firebaseProjectId;
  final String firebaseMessagingSenderId;
  final String firebaseAuthDomain;
  final String firebaseStorageBucket;
  final String androidAppId;
  final String iosAppId;
  final String webAppId;
  final String windowsAppId;
  final String fallbackAppId;
  final String googleServerClientId;
  final String googleIosClientId;
  final String appCheckRecaptchaSiteKey;
  final String appCheckDebugToken;

  bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty &&
      firebaseProjectId.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty &&
      appIdForCurrentPlatform().isNotEmpty;

  bool get useFirebase => useFirebaseRequested && isFirebaseConfigured;

  String appIdForCurrentPlatform() {
    if (kIsWeb) return _firstNonEmpty(webAppId, fallbackAppId);
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _firstNonEmpty(androidAppId, fallbackAppId),
      TargetPlatform.iOS ||
      TargetPlatform.macOS => _firstNonEmpty(iosAppId, fallbackAppId),
      TargetPlatform.windows => _firstNonEmpty(windowsAppId, fallbackAppId),
      TargetPlatform.linux ||
      TargetPlatform.fuchsia => _firstNonEmpty(fallbackAppId, webAppId),
    };
  }

  void assertSafe() {
    const geminiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (geminiKey.isNotEmpty) {
      throw StateError(
        'GEMINI_API_KEY was passed into the app. Remove it. '
        'Call Gemini only from a trusted server.',
      );
    }
    if (useFirebaseRequested && !isFirebaseConfigured) {
      throw StateError(
        'USE_FIREBASE is true, but the Firebase client config is incomplete. '
        'Copy env/env.json.example to env/env.json and fill the public Firebase fields.',
      );
    }
  }

  static String _firstNonEmpty(String preferred, String fallback) {
    return preferred.isNotEmpty ? preferred : fallback;
  }
}
