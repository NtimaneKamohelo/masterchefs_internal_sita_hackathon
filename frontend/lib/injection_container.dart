import 'package:get_it/get_it.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//import 'features/authentication/data/datasources/auth_remote_data_source.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/domain/usecases/register_user.dart';
import 'features/authentication/domain/usecases/login_user.dart';
import 'features/authentication/domain/usecases/logout_user.dart';
import 'features/authentication/domain/usecases/reset_password.dart';
import 'features/authentication/domain/usecases/resend_verification_email.dart';
import 'features/authentication/domain/usecases/update_password.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => ResendVerificationEmail(sl()));
  sl.registerLazySingleton(() => UpdatePassword(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      registerUser: sl(),
      loginUser: sl(),
      logoutUser: sl(),
      resetPassword: sl(),
      resendVerificationEmail: sl(),
      updatePassword: sl(),
      repository: sl(),
    ),
  );
}
