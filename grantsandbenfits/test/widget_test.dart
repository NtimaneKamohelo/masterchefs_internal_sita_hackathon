import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/core/security/bot_protection.dart';
import 'package:grantsandbenfits/core/security/login_rate_limiter.dart';
import 'package:grantsandbenfits/core/security/password_hasher.dart';
import 'package:grantsandbenfits/core/storage/memory_secure_store.dart';
import 'package:grantsandbenfits/features/auth/data/auth_audit_logger.dart';
import 'package:grantsandbenfits/features/auth/data/datasources/local_auth_remote_data_source.dart';
import 'package:grantsandbenfits/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:grantsandbenfits/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_event.dart';
import 'package:grantsandbenfits/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('login page shows sign in', (tester) async {
    final store = MemorySecureStore();
    final remote = LocalAuthRemoteDataSource(
      store: store,
      hasher: PasswordHasher(logRounds: 4),
    );
    final repository = AuthRepositoryImpl(
      remote: remote,
      audit: AuthAuditLogger(store),
    );
    final limiter = LoginRateLimiter(store);
    const bots = BotProtection();
    final bloc = AuthBloc(
      watchAuthState: WatchAuthState(repository),
      signInWithEmail: SignInWithEmail(repository, limiter, bots),
      signUpWithEmail: SignUpWithEmail(repository, limiter, bots),
      signInWithGoogle: SignInWithGoogle(repository, limiter, bots),
      sendPasswordReset: SendPasswordReset(repository, limiter, bots),
      confirmPasswordReset: ConfirmPasswordReset(repository, limiter),
      sendEmailVerification: SendEmailVerification(repository),
      confirmEmailVerification: ConfirmEmailVerification(repository, limiter),
      signOut: SignOut(repository),
      issuesOutOfBandCodes: true,
    )..add(const AuthStarted());
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pump();

    expect(find.text('Grants & Benefits'), findsWidgets);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Create an account'), findsOneWidget);
  });
}
