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

  /// Validates a 13-digit South African ID number (YYMMDD + Luhn checksum).
  static String? southAfricanId(String value) {
    final cleaned = value.trim();
    if (!RegExp(r'^\d{13}$').hasMatch(cleaned)) {
      return 'Enter a valid 13-digit South African ID number.';
    }
    final month = int.parse(cleaned.substring(2, 4));
    final day = int.parse(cleaned.substring(4, 6));
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return 'ID number has an invalid birth date.';
    }
    final citizenship = int.parse(cleaned[10]);
    if (citizenship != 0 && citizenship != 1) {
      return 'ID number has an invalid citizenship digit.';
    }
    if (!_passesLuhn(cleaned)) {
      return 'ID number checksum is invalid.';
    }
    return null;
  }

  static String? streetAddress(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 5) {
      return 'Enter your full street address (at least 5 characters).';
    }
    if (trimmed.length > 160) {
      return 'Street address is too long.';
    }
    return null;
  }

  static String? city(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 2) return 'Enter your city or town.';
    if (trimmed.length > 80) return 'City name is too long.';
    return null;
  }

  static String? postalCode(String value) {
    if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
      return 'Enter a 4-digit South African postal code.';
    }
    return null;
  }

  static String? phoneNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.isEmpty) return null;
    if (!RegExp(r'^(\+27|0)\d{9}$').hasMatch(cleaned)) {
      return 'Enter a valid SA phone number (e.g. 0821234567 or +27821234567).';
    }
    return null;
  }

  static bool _passesLuhn(String digits) {
    var sum = 0;
    var doubleDigit = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = digits.codeUnitAt(i) - 48;
      if (doubleDigit) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      doubleDigit = !doubleDigit;
    }
    return sum % 10 == 0;
  }
}
