sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class RateLimitFailure extends Failure {
  const RateLimitFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class CancelledFailure extends Failure {
  const CancelledFailure() : super('');
}
