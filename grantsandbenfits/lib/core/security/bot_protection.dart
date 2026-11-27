/// Client-side speed bump. Firebase App Check is the control that blocks
/// scripted clients once the project is configured.
class BotProtection {
  const BotProtection({this.minimumFormAge = const Duration(milliseconds: 300)});

  final Duration minimumFormAge;

  String? assess({
    required String honeypot,
    required DateTime formOpenedAt,
    DateTime Function()? clock,
  }) {
    if (honeypot.trim().isNotEmpty) {
      return 'We could not confirm this request. Try again.';
    }
    final now = (clock ?? DateTime.now)();
    if (now.difference(formOpenedAt) < minimumFormAge) {
      return 'We could not confirm this request. Try again.';
    }
    return null;
  }
}
