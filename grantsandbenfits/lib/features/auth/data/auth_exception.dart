class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

class AuthCancelledException extends AuthException {
  const AuthCancelledException() : super('Sign-in was cancelled.');
}
