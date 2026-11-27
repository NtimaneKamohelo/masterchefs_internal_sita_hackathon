import 'package:get_it/get_it.dart';
import 'package:grantsandbenfits/core/config/app_config.dart';
import 'package:grantsandbenfits/core/security/bot_protection.dart';
import 'package:grantsandbenfits/core/security/login_rate_limiter.dart';
import 'package:grantsandbenfits/core/security/password_hasher.dart';
import 'package:grantsandbenfits/core/storage/flutter_secure_store.dart';
import 'package:grantsandbenfits/core/storage/secure_store.dart';
import 'package:grantsandbenfits/features/auth/data/auth_audit_logger.dart';
import 'package:grantsandbenfits/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:grantsandbenfits/features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import 'package:grantsandbenfits/features/auth/data/datasources/local_auth_remote_data_source.dart';
import 'package:grantsandbenfits/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:grantsandbenfits/features/auth/domain/repositories/auth_repository.dart';
import 'package:grantsandbenfits/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/documents/data/datasources/document_verification_data_source.dart';
import 'package:grantsandbenfits/features/documents/data/datasources/local_ai_document_agent_data_source.dart';
import 'package:grantsandbenfits/features/documents/data/document_audit_logger.dart';
import 'package:grantsandbenfits/features/documents/data/repositories/document_verification_repository_impl.dart';
import 'package:grantsandbenfits/features/documents/domain/repositories/document_verification_repository.dart';
import 'package:grantsandbenfits/features/documents/domain/usecases/verify_certified_document.dart';
import 'package:grantsandbenfits/features/documents/presentation/bloc/document_verification_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies(AppConfig config) async {
  if (getIt.isRegistered<AppConfig>()) return;

  getIt.registerSingleton<AppConfig>(config);
  getIt.registerLazySingleton<SecureStore>(FlutterSecureStore.new);
  getIt.registerLazySingleton<PasswordHasher>(PasswordHasher.new);
  getIt.registerLazySingleton<LoginRateLimiter>(
    () => LoginRateLimiter(getIt()),
  );
  getIt.registerLazySingleton<BotProtection>(BotProtection.new);
  getIt.registerLazySingleton<AuthAuditLogger>(
    () => AuthAuditLogger(getIt()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(() {
    if (config.useFirebase) {
      return FirebaseAuthRemoteDataSource(
        googleConfig: GoogleAuthConfig(
          serverClientId: config.googleServerClientId,
          iosClientId: config.googleIosClientId,
        ),
      );
    }
    return LocalAuthRemoteDataSource(
      store: getIt(),
      hasher: getIt(),
    );
  });
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: getIt(), audit: getIt()),
  );
  getIt.registerLazySingleton(() => WatchAuthState(getIt()));
  getIt.registerLazySingleton(
    () => SignInWithEmail(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton(
    () => SignUpWithEmail(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton(
    () => SignInWithGoogle(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton(
    () => SendPasswordReset(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => ConfirmPasswordReset(getIt(), getIt()));
  getIt.registerLazySingleton(() => SendEmailVerification(getIt()));
  getIt.registerLazySingleton(
    () => ConfirmEmailVerification(getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => SignOut(getIt()));
  getIt.registerLazySingleton(
    () => AuthBloc(
      watchAuthState: getIt(),
      signInWithEmail: getIt(),
      signUpWithEmail: getIt(),
      signInWithGoogle: getIt(),
      sendPasswordReset: getIt(),
      confirmPasswordReset: getIt(),
      sendEmailVerification: getIt(),
      confirmEmailVerification: getIt(),
      signOut: getIt(),
      issuesOutOfBandCodes: getIt<AuthRepository>().issuesOutOfBandCodes,
    ),
  );

  getIt.registerLazySingleton<DocumentAuditLogger>(
    () => DocumentAuditLogger(getIt()),
  );
  getIt.registerLazySingleton<DocumentVerificationDataSource>(
    LocalAiDocumentAgentDataSource.new,
  );
  getIt.registerLazySingleton<DocumentVerificationRepository>(
    () => DocumentVerificationRepositoryImpl(remote: getIt(), audit: getIt()),
  );
  getIt.registerLazySingleton(() => VerifyCertifiedDocument(getIt()));
  getIt.registerFactory(
    () => DocumentVerificationBloc(verifyCertifiedDocument: getIt()),
  );
}
