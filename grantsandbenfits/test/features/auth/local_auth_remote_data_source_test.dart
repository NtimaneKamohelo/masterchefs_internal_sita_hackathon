import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/core/security/password_hasher.dart';
import 'package:grantsandbenfits/core/storage/memory_secure_store.dart';
import 'package:grantsandbenfits/features/auth/data/auth_exception.dart';
import 'package:grantsandbenfits/features/auth/data/datasources/local_auth_remote_data_source.dart';

void main() {
  LocalAuthRemoteDataSource createSource() {
    return LocalAuthRemoteDataSource(
      store: MemorySecureStore(),
      hasher: PasswordHasher(logRounds: 4),
    );
  }

  test('sign up, sign in, verify, and reset stay on device', () async {
    final remote = createSource();
    const email = 'ada@example.com';
    final session = await remote.signUpWithEmail(
      name: 'Ada Lovelace',
      email: email,
      password: 'Correct-Horse-1',
      popiaConsent: true,
    );

    expect(session.user.emailVerified, isFalse);
    expect(session.demoCode, isNotNull);

    expect(
      () => remote.signInWithEmail(email: email, password: 'Wrong-Password-1'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Email or password is incorrect.',
        ),
      ),
    );
    expect(
      () => remote.signInWithEmail(
        email: 'missing@example.com',
        password: 'Wrong-Password-1',
      ),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Email or password is incorrect.',
        ),
      ),
    );

    await remote.signInWithEmail(email: email, password: 'Correct-Horse-1');
    expect(
      () => remote.confirmEmailVerification(code: '000000'),
      throwsA(isA<AuthException>()),
    );
    final verified = await remote.confirmEmailVerification(
      code: session.demoCode!,
    );
    expect(verified.emailVerified, isTrue);

    final resetCode = await remote.sendPasswordReset(email: email);
    expect(resetCode, isNotNull);
    await remote.confirmPasswordReset(
      email: email,
      code: resetCode!,
      newPassword: 'New-Password-2',
    );
    final signedIn = await remote.signInWithEmail(
      email: email,
      password: 'New-Password-2',
    );
    expect(signedIn.email, email);
  });

  test('google demo uses a synthetic verified identity', () async {
    final user = await createSource().signInWithGoogle();
    expect(user.isSynthetic, isTrue);
    expect(user.emailVerified, isTrue);
    expect(user.email, 'demo.official@example.com');
  });

  test('registration without POPIA consent is rejected', () async {
    expect(
      () => createSource().signUpWithEmail(
        name: 'Ada Lovelace',
        email: 'ada@example.com',
        password: 'Correct-Horse-1',
        popiaConsent: false,
      ),
      throwsA(isA<AuthException>()),
    );
  });
}
