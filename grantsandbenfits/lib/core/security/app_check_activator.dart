import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:grantsandbenfits/core/config/app_config.dart';

/// Activates Firebase App Check. A failure is reported and does not block
/// email sign-in during the hackathon setup.
abstract final class AppCheckActivator {
  static Future<void> activate(AppConfig config) async {
    final siteKey = config.appCheckRecaptchaSiteKey;
    final debugToken = config.appCheckDebugToken;
    try {
      await FirebaseAppCheck.instance.activate(
        providerWeb: siteKey.isEmpty
            ? null
            : (kDebugMode
                  ? WebDebugProvider()
                  : ReCaptchaV3Provider(siteKey)),
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : AppleAppAttestWithDeviceCheckFallbackProvider(),
        providerWindows: WindowsDebugProvider(
          debugToken: debugToken.isEmpty ? null : debugToken,
        ),
      );
    } catch (error) {
      debugPrint('App Check was not activated: $error');
    }
  }
}
