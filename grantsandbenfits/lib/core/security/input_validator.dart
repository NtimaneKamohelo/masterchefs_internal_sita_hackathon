import 'dart:convert';

abstract final class InputValidator {
  static final RegExp _email = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _name = RegExp(
    r"^[\p{L}][\p{L} '\-]{1,79}$",
    unicode: true,
  );

  static String normalizeEmail(String value) => value.trim().toLowerCase();

  static String? email(String value) {
    final candidate = value.trim();
    if (candidate.isEmpty) return 'Enter your email address.';
    if (candidate.length > 254 || !_email.hasMatch(candidate)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? name(String value) {
    if (value.isEmpty) return 'Enter your full name.';
    if (!_name.hasMatch(value)) {
      return 'Use letters, spaces, hyphens, or apostrophes only.';
    }
    return null;
  }

  static String? password(String value, {String? email}) {
    if (value.length < 8) return 'Use at least 8 characters.';
    if (utf8.encode(value).length > 72) return 'Password is too long.';
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Include a lowercase letter.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include an uppercase letter.';
    }
    if (!RegExp(r'\d').hasMatch(value)) return 'Include a number.';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      return 'Include a symbol.';
    }
    if (email != null) {
      final localPart = email.split('@').first.toLowerCase();
      if (localPart.length >= 3 && value.toLowerCase().contains(localPart)) {
        return 'Password must not contain your email name.';
      }
    }
    return null;
  }

  static String? confirmation({
    required String password,
    required String confirmation,
  }) {
    if (password != confirmation) return 'Passwords do not match.';
    return null;
  }

  static String? verificationCode(String value) {
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter the 6-digit code.';
    }
    return null;
  }
}
