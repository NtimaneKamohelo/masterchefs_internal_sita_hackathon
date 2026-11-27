import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:grantsandbenfits/core/security/content_sanitizer.dart';
import 'package:grantsandbenfits/core/security/input_validator.dart';
import 'package:grantsandbenfits/core/security/password_hasher.dart';
import 'package:grantsandbenfits/core/storage/secure_store.dart';
import 'package:grantsandbenfits/core/storage/storage_keys.dart';
import 'package:grantsandbenfits/core/utils/id_generator.dart';
import 'package:grantsandbenfits/features/auth/data/auth_exception.dart';
import 'package:grantsandbenfits/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/app_user.dart';
import 'package:grantsandbenfits/features/auth/domain/entities/auth_session.dart';

class _StoredUser {
  const _StoredUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.passwordHash,
    required this.emailVerified,
    required this.provider,
    required this.isSynthetic,
    required this.popiaConsent,
  });

  final String id;
  final String email;
  final String displayName;
  final String? passwordHash;
  final bool emailVerified;
  final AuthProviderKind provider;
  final bool isSynthetic;
  final bool popiaConsent;

  AppUser toEntity() {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName,
      emailVerified: emailVerified,
      provider: provider,
      isSynthetic: isSynthetic,
    );
  }

  _StoredUser copyWith({
    String? displayName,
    String? passwordHash,
    bool? emailVerified,
  }) {
    return _StoredUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      passwordHash: passwordHash ?? this.passwordHash,
      emailVerified: emailVerified ?? this.emailVerified,
      provider: provider,
      isSynthetic: isSynthetic,
      popiaConsent: popiaConsent,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'passwordHash': passwordHash,
      'emailVerified': emailVerified,
      'provider': provider.name,
      'isSynthetic': isSynthetic,
      'popiaConsent': popiaConsent,
    };
  }

  factory _StoredUser.fromJson(Map<dynamic, dynamic> json) {
    final providerName = json['provider'];
    return _StoredUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      passwordHash: json['passwordHash'] as String?,
      emailVerified: json['emailVerified'] == true,
      provider: providerName == AuthProviderKind.google.name
          ? AuthProviderKind.google
          : AuthProviderKind.email,
      isSynthetic: json['isSynthetic'] == true,
      popiaConsent: json['popiaConsent'] == true,
    );
  }
}

/// On-device accounts for the hackathon demo. Passwords are bcrypt hashes.
/// Nothing in this store is sent to a server.
class LocalAuthRemoteDataSource implements AuthRemoteDataSource {
  LocalAuthRemoteDataSource({
    required SecureStore store,
    required PasswordHasher hasher,
    Random? random,
  }) : _store = store,
       _hasher = hasher,
       _random = random ?? Random.secure();

  static const _challengeTtl = Duration(minutes: 15);
  static const _demoGoogleId = 'synthetic-google-demo-official';
  static const _demoGoogleEmail = 'demo.official@example.com';
  static const _invalidCredentials = AuthException(
    'Email or password is incorrect.',
  );
  static const _invalidCode = AuthException(
    'That code is incorrect or has expired.',
  );

  final SecureStore _store;
  final PasswordHasher _hasher;
  final Random _random;
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  Future<void> _tail = Future<void>.value();
  AppUser? _current;

  @override
  bool get issuesOutOfBandCodes => true;

  @override
  Stream<AppUser?> watch() {
    return Stream<AppUser?>.multi((listener) {
      StreamSubscription<AppUser?>? subscription;
      final ready = _sync(() async {
        await _restoreSession();
        listener.add(_current);
        subscription = _controller.stream.listen(
          listener.add,
          onError: listener.addError,
          onDone: listener.close,
        );
      });
      listener.onCancel = () async {
        await ready;
        await subscription?.cancel();
      };
    });
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _sync(() async {
      final normalized = InputValidator.normalizeEmail(email);
      final users = await _readUsers();
      final stored = users[normalized];
      final hash = stored?.passwordHash;
      if (stored == null || hash == null) {
        _hasher.verify(password, PasswordHasher.dummyHash);
        throw _invalidCredentials;
      }
      if (!_hasher.verify(password, hash)) throw _invalidCredentials;
      await _persistSession(stored);
      return stored.toEntity();
    });
  }

  @override
  Future<AuthSession> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required bool popiaConsent,
  }) {
    return _sync(() async {
      if (!popiaConsent) {
        throw const AuthException(
          'Consent is required before we can process an application.',
        );
      }
      final normalized = InputValidator.normalizeEmail(email);
      final cleanName = ContentSanitizer.sanitizePlainText(name);
      final nameError = InputValidator.name(cleanName);
      final emailError = InputValidator.email(normalized);
      final passwordError = InputValidator.password(
        password,
        email: normalized,
      );
      if (nameError != null) throw AuthException(nameError);
      if (emailError != null) throw AuthException(emailError);
      if (passwordError != null) throw AuthException(passwordError);

      final passwordHash = _hasher.hash(password);
      final users = await _readUsers();
      if (users.containsKey(normalized)) {
        throw const AuthException(
          'An account with this email already exists.',
        );
      }
      final stored = _StoredUser(
        id: createSecureId(),
        email: normalized,
        displayName: cleanName,
        passwordHash: passwordHash,
        emailVerified: false,
        provider: AuthProviderKind.email,
        isSynthetic: false,
        popiaConsent: true,
      );
      users[normalized] = stored;
      await _writeUsers(users);
      final demoCode = await _issueChallenge(
        StorageKeys.verifyChallenge(normalized),
      );
      await _persistSession(stored);
      return AuthSession(user: stored.toEntity(), demoCode: demoCode);
    });
  }

  @override
  Future<AppUser> signInWithGoogle() {
    return _sync(() async {
      final users = await _readUsers();
      final existing = users[_demoGoogleEmail];
      if (existing != null && existing.provider != AuthProviderKind.google) {
        throw const AuthException(
          'This email is already registered with a password. Sign in with email instead.',
        );
      }
      final stored =
          existing ??
          const _StoredUser(
            id: _demoGoogleId,
            email: _demoGoogleEmail,
            displayName: 'Demo Official',
            passwordHash: null,
            emailVerified: true,
            provider: AuthProviderKind.google,
            isSynthetic: true,
            popiaConsent: true,
          );
      users[_demoGoogleEmail] = stored;
      await _writeUsers(users);
      await _persistSession(stored);
      return stored.toEntity();
    });
  }

  @override
  Future<String?> sendPasswordReset({required String email}) {
    return _sync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final normalized = InputValidator.normalizeEmail(email);
      final stored = (await _readUsers())[normalized];
      if (stored == null || stored.passwordHash == null) return null;
      return _issueChallenge(StorageKeys.resetChallenge(normalized));
    });
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _sync(() async {
      final normalized = InputValidator.normalizeEmail(email);
      final passwordError = InputValidator.password(
        newPassword,
        email: normalized,
      );
      if (passwordError != null) throw AuthException(passwordError);
      final users = await _readUsers();
      final stored = users[normalized];
      if (stored == null || stored.passwordHash == null) {
        _hasher.verify(code, PasswordHasher.dummyHash);
        throw _invalidCode;
      }
      await _consumeChallenge(StorageKeys.resetChallenge(normalized), code);
      users[normalized] = stored.copyWith(passwordHash: _hasher.hash(newPassword));
      await _writeUsers(users);
      await _clearSession();
    });
  }

  @override
  Future<String?> sendEmailVerification() {
    return _sync(() async {
      final current = await _currentStored();
      if (current == null) {
        throw const AuthException('Sign in again before verifying.');
      }
      if (current.emailVerified) return null;
      return _issueChallenge(StorageKeys.verifyChallenge(current.email));
    });
  }

  @override
  Future<AppUser> confirmEmailVerification({required String code}) {
    return _sync(() async {
      final current = await _currentStored();
      if (current == null) {
        throw const AuthException('Sign in again before verifying.');
      }
      await _consumeChallenge(
        StorageKeys.verifyChallenge(current.email),
        code,
      );
      final users = await _readUsers();
      final updated = current.copyWith(emailVerified: true);
      users[current.email] = updated;
      await _writeUsers(users);
      await _persistSession(updated);
      return updated.toEntity();
    });
  }

  @override
  Future<void> signOut() {
    return _sync(_clearSession);
  }

  Future<T> _sync<T>(Future<T> Function() action) {
    final next = _tail.then((_) => action());
    _tail = next.then((_) {}, onError: (_) {});
    return next;
  }

  Future<void> _restoreSession() async {
    final userId = await _store.read(StorageKeys.sessionUserId);
    if (userId == null || userId.isEmpty) {
      _current = null;
      return;
    }
    final stored = _findById(await _readUsers(), userId);
    _current = stored?.toEntity();
    if (stored == null) await _store.delete(StorageKeys.sessionUserId);
  }

  Future<void> _persistSession(_StoredUser user) async {
    await _store.write(StorageKeys.sessionUserId, user.id);
    _publish(user.toEntity());
  }

  Future<void> _clearSession() async {
    await _store.delete(StorageKeys.sessionUserId);
    _publish(null);
  }

  void _publish(AppUser? user) {
    _current = user;
    if (!_controller.isClosed) _controller.add(user);
  }

  Future<_StoredUser?> _currentStored() async {
    final userId = _current?.id ?? await _store.read(StorageKeys.sessionUserId);
    if (userId == null) return null;
    return _findById(await _readUsers(), userId);
  }

  _StoredUser? _findById(Map<String, _StoredUser> users, String id) {
    for (final user in users.values) {
      if (user.id == id) return user;
    }
    return null;
  }

  Future<Map<String, _StoredUser>> _readUsers() async {
    final raw = await _store.read(StorageKeys.users);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    return {
      for (final entry in decoded.entries)
        if (entry.value is Map)
          '${entry.key}': _StoredUser.fromJson(
            entry.value as Map<dynamic, dynamic>,
          ),
    };
  }

  Future<void> _writeUsers(Map<String, _StoredUser> users) {
    return _store.write(
      StorageKeys.users,
      jsonEncode({
        for (final entry in users.entries) entry.key: entry.value.toJson(),
      }),
    );
  }

  Future<String> _issueChallenge(String key) async {
    final code = (_random.nextInt(900000) + 100000).toString();
    await _store.write(
      key,
      jsonEncode({
        'codeHash': _hasher.hash(code),
        'expiresAt': DateTime.now().toUtc().add(_challengeTtl).toIso8601String(),
      }),
    );
    return code;
  }

  Future<void> _consumeChallenge(String key, String code) async {
    final raw = await _store.read(key);
    if (raw == null || raw.isEmpty) throw _invalidCode;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) throw _invalidCode;
    final hash = decoded['codeHash'];
    final expiresRaw = decoded['expiresAt'];
    final expires = expiresRaw is String ? DateTime.tryParse(expiresRaw) : null;
    if (hash is! String ||
        expires == null ||
        DateTime.now().toUtc().isAfter(expires.toUtc())) {
      await _store.delete(key);
      throw _invalidCode;
    }
    if (!_hasher.verify(code.trim(), hash)) throw _invalidCode;
    await _store.delete(key);
  }
}
