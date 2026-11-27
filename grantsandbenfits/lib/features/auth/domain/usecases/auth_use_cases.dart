import 'package:grantsandbenfits/core/error/failure.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/core/security/bot_protection.dart';
import 'package:grantsandbenfits/core/security/content_sanitizer.dart';
import 'package:grantsandbenfits/core/security/input_validator.dart';
import 'package:grantsandbenfits/core/security/login_rate_limiter.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/app_user.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/auth_session.dart';
import 'package:grantsandbenfits/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  Stream<AppUser?> call() => _repository.watchAuthState();
}

class SignInWithEmail {
  const SignInWithEmail(this._repository, this._limiter, this._bots);

  final AuthRepository _repository;
  final LoginRateLimiter _limiter;
  final BotProtection _bots;

  Future<Result<AppUser>> call({
    required String email,
    required String password,
    required String honeypot,
    required DateTime formOpenedAt,
  }) async {
    final blocked = _bots.assess(honeypot: honeypot, formOpenedAt: formOpenedAt);
    if (blocked != null) return Err(ValidationFailure(blocked));

    final normalized = InputValidator.normalizeEmail(email);
    final emailError = InputValidator.email(normalized);
    if (emailError != null) return Err(ValidationFailure(emailError));
    final passwordError = InputValidator.password(password, email: normalized);
    if (passwordError != null) return Err(ValidationFailure(passwordError));

    final bucket = 'signin:$normalized';
    final limited = await _limiter.rejectionReason(bucket);
    if (limited != null) return Err(RateLimitFailure(limited));

    final result = await _repository.signInWithEmail(
      email: normalized,
      password: password,
    );
    switch (result) {
      case Ok():
        await _limiter.recordSuccess(bucket);
      case Err():
        await _limiter.recordFailure(bucket);
    }
    return result;
  }
}

class SignUpWithEmail {
  const SignUpWithEmail(this._repository, this._limiter, this._bots);

  final AuthRepository _repository;
  final LoginRateLimiter _limiter;
  final BotProtection _bots;

  Future<Result<AuthSession>> call({
    required String name,
    required String email,
    required String password,
    required String confirmation,
    required bool popiaConsent,
    required String honeypot,
    required DateTime formOpenedAt,
  }) async {
    final blocked = _bots.assess(honeypot: honeypot, formOpenedAt: formOpenedAt);
    if (blocked != null) return Err(ValidationFailure(blocked));
    if (!popiaConsent) {
      return const Err(
        ValidationFailure(
          'Consent is required before we can process an application.',
        ),
      );
    }

    final cleanName = ContentSanitizer.sanitizePlainText(name);
    final nameError = InputValidator.name(cleanName);
    if (nameError != null) return Err(ValidationFailure(nameError));

    final normalized = InputValidator.normalizeEmail(email);
    final emailError = InputValidator.email(normalized);
    if (emailError != null) return Err(ValidationFailure(emailError));
    final passwordError = InputValidator.password(password, email: normalized);
    if (passwordError != null) return Err(ValidationFailure(passwordError));
    final confirmationError = InputValidator.confirmation(
      password: password,
      confirmation: confirmation,
    );
    if (confirmationError != null) {
      return Err(ValidationFailure(confirmationError));
    }

    final bucket = 'signup:$normalized';
    final limited = await _limiter.rejectionReason(bucket);
    if (limited != null) return Err(RateLimitFailure(limited));

    final result = await _repository.signUpWithEmail(
      name: cleanName,
      email: normalized,
      password: password,
      popiaConsent: true,
    );
    switch (result) {
      case Ok():
        await _limiter.recordSuccess(bucket);
      case Err():
        await _limiter.recordFailure(bucket);
    }
    return result;
  }
}

class SignInWithGoogle {
  const SignInWithGoogle(this._repository, this._limiter, this._bots);

  final AuthRepository _repository;
  final LoginRateLimiter _limiter;
  final BotProtection _bots;

  Future<Result<AppUser>> call({
    required String honeypot,
    required DateTime formOpenedAt,
  }) async {
    final blocked = _bots.assess(honeypot: honeypot, formOpenedAt: formOpenedAt);
    if (blocked != null) return Err(ValidationFailure(blocked));

    const bucket = 'signin:google';
    final limited = await _limiter.rejectionReason(bucket);
    if (limited != null) return Err(RateLimitFailure(limited));

    final result = await _repository.signInWithGoogle();
    switch (result) {
      case Ok():
        await _limiter.recordSuccess(bucket);
      case Err(:final failure) when failure is! CancelledFailure:
        await _limiter.recordFailure(bucket);
      case Err():
        break;
    }
    return result;
  }
}

class SendPasswordReset {
  const SendPasswordReset(this._repository, this._limiter, this._bots);

  final AuthRepository _repository;
  final LoginRateLimiter _limiter;
  final BotProtection _bots;

  Future<Result<String?>> call({
    required String email,
    required String honeypot,
    required DateTime formOpenedAt,
  }) async {
    final blocked = _bots.assess(honeypot: honeypot, formOpenedAt: formOpenedAt);
    if (blocked != null) return Err(ValidationFailure(blocked));

    final normalized = InputValidator.normalizeEmail(email);
    final emailError = InputValidator.email(normalized);
    if (emailError != null) return Err(ValidationFailure(emailError));

    final bucket = 'reset:$normalized';
    final limited = await _limiter.rejectionReason(bucket);
    if (limited != null) return Err(RateLimitFailure(limited));

    final result = await _repository.sendPasswordReset(email: normalized);
    if (result is Ok<String?>) await _limiter.recordFailure(bucket);
    if (result is Err<String?>) await _limiter.recordFailure(bucket);
    return result;
  }
}

class ConfirmPasswordReset {
  const ConfirmPasswordReset(this._repository, this._limiter);

  final AuthRepository _repository;
  final LoginRateLimiter _limiter;

  Future<Result<Completed>> call({
    required String email,
    required String code,
    required String newPassword,
    required String confirmation,
  }) async {
    final normalized = InputValidator.normalizeEmail(email);
    final emailError = InputValidator.email(normalized);
    if (emailError != null) return Err(ValidationFailure(emailError));
    final codeError = InputValidator.verificationCode(code);
    if (codeError != null) return Err(ValidationFailure(codeError));
    final passwordError = InputValidator.password(
      newPassword,
      email: normalized,
    );
    if (passwordError != null) return Err(ValidationFailure(passwordError));
    final confirmationError = InputValidator.confirmation(
      password: newPassword,
      confirmation: confirmation,
    );
    if (confirmationError != null) {
      return Err(ValidationFailure(confirmationError));
    }

    final bucket = 'reset-confirm:$normalized';
    final limited = await _limiter.rejectionReason(bucket);
    if (limited != null) return Err(RateLimitFailure(limited));

    final result = await _repository.confirmPasswordReset(
      email: normalized,
      code: code.trim(),
      newPassword: newPassword,
    );
    switch (result) {
      case Ok():
        await _limiter.recordSuccess(bucket);
      case Err():
        await _limiter.recordFailure(bucket);
    }
    return result;
  }
}

class SendEmailVerification {
  const SendEmailVerification(this._repository);

  final AuthRepository _repository;

  Future<Result<String?>> call() => _repository.sendEmailVerification();
}

class ConfirmEmailVerification {
  const ConfirmEmailVerification(this._repository, this._limiter);

  final AuthRepository _repository;
  final LoginRateLimiter _limiter;

  Future<Result<AppUser>> call(String code) async {
    if (_repository.issuesOutOfBandCodes) {
      final codeError = InputValidator.verificationCode(code);
      if (codeError != null) return Err(ValidationFailure(codeError));
    }

    const bucket = 'verify:current';
    final limited = await _limiter.rejectionReason(bucket);
    if (limited != null) return Err(RateLimitFailure(limited));

    final result = await _repository.confirmEmailVerification(code: code.trim());
    switch (result) {
      case Ok():
        await _limiter.recordSuccess(bucket);
      case Err():
        await _limiter.recordFailure(bucket);
    }
    return result;
  }
}

class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<Result<Completed>> call() => _repository.signOut();
}
