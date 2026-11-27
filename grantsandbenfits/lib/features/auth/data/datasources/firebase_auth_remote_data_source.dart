import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grantsandbenfits/core/security/content_sanitizer.dart';
import 'package:grantsandbenfits/features/auth/data/auth_exception.dart';
import 'package:grantsandbenfits/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/app_user.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/auth_session.dart';

class GoogleAuthConfig {
  const GoogleAuthConfig({this.serverClientId = '', this.iosClientId = ''});

  final String serverClientId;
  final String iosClientId;
}

/// Firebase Auth keeps the password, salts it, and hashes it on the server.
/// This class never stores the password and never hashes it first.
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource({
    FirebaseAuth? auth,
    this.googleConfig = const GoogleAuthConfig(),
  }) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  final GoogleAuthConfig googleConfig;
  bool _googleReady = false;

  @override
  bool get issuesOutOfBandCodes => false;

  @override
  Stream<AppUser?> watch() {
    return _auth.authStateChanges().map((user) => user == null ? null : _map(user));
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw _invalidCredentials;
      return _map(user);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error));
    }
  }

  @override
  Future<AuthSession> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required bool popiaConsent,
  }) async {
    if (!popiaConsent) {
      throw const AuthException(
        'Consent is required before we can process an application.',
      );
    }
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('The account could not be created.');
      }
      await user.updateDisplayName(name);
      await user.sendEmailVerification();
      return AuthSession(user: _map(user, fallbackName: name));
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error));
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final credential = await _auth.signInWithPopup(GoogleAuthProvider());
        final user = credential.user;
        if (user == null) {
          throw const AuthException('Google sign-in could not be completed.');
        }
        return _map(user);
      }
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw const AuthException(
          'Google sign-in is available on Android, iOS, and web.',
        );
      }
      await _ensureGoogleReady();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException(
          'Google did not return an identity token. Check GOOGLE_SERVER_CLIENT_ID.',
        );
      }
      final credential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Google sign-in could not be completed.');
      }
      return _map(user);
    } on AuthException {
      rethrow;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      if (error.code == GoogleSignInExceptionCode.clientConfigurationError) {
        throw const AuthException(
          'Google sign-in is not configured. Add the OAuth client IDs to env/env.json.',
        );
      }
      throw const AuthException('Google sign-in could not be completed.');
    } on FirebaseAuthException catch (error) {
      if (error.code == 'popup-closed-by-user' ||
          error.code == 'cancelled-popup-request') {
        throw const AuthCancelledException();
      }
      throw AuthException(_messageFor(error));
    }
  }

  @override
  Future<String?> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') return null;
      throw AuthException(_messageFor(error));
    }
    return null;
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) {
    throw const AuthException(
      'Open the reset link in your email to choose a new password.',
    );
  }

  @override
  Future<String?> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('Sign in again before verifying.');
    }
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error));
    }
    return null;
  }

  @override
  Future<AppUser> confirmEmailVerification({required String code}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('Sign in again before verifying.');
    }
    try {
      await user.reload();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error));
    }
    final refreshed = _auth.currentUser;
    if (refreshed == null) {
      throw const AuthException('Sign in again before verifying.');
    }
    final mapped = _map(refreshed);
    if (!mapped.emailVerified) {
      throw const AuthException(
        'Email is not verified yet. Open the link in your inbox, then try again.',
      );
    }
    return mapped;
  }

  @override
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Google Sign-In may not be initialized on this platform.
    }
    await _auth.signOut();
  }

  Future<void> _ensureGoogleReady() async {
    if (_googleReady) return;
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        googleConfig.serverClientId.isEmpty) {
      throw const AuthException(
        'Google sign-in needs GOOGLE_SERVER_CLIENT_ID. Use the Firebase web client ID.',
      );
    }
    await GoogleSignIn.instance.initialize(
      clientId: googleConfig.iosClientId.isEmpty
          ? null
          : googleConfig.iosClientId,
      serverClientId: googleConfig.serverClientId.isEmpty
          ? null
          : googleConfig.serverClientId,
    );
    _googleReady = true;
  }

  AppUser _map(User user, {String? fallbackName}) {
    final rawName = (user.displayName == null || user.displayName!.isEmpty)
        ? (fallbackName ?? 'Account')
        : user.displayName!;
    final usesGoogle = user.providerData.any(
      (provider) => provider.providerId == 'google.com',
    );
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: ContentSanitizer.sanitizePlainText(rawName),
      emailVerified: user.emailVerified || usesGoogle,
      provider: usesGoogle ? AuthProviderKind.google : AuthProviderKind.email,
      isSynthetic: false,
    );
  }

  static const _invalidCredentials = AuthException(
    'Email or password is incorrect.',
  );

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return _invalidCredentials.message;
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Use a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a few minutes and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase Auth.';
      default:
        return 'Authentication could not be completed.';
    }
  }
}
