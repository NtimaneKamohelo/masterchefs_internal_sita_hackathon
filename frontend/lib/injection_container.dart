import 'package:get_it/get_it.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//import 'features/authentication/data/datasources/auth_remote_data_source.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Supabase client
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // Authentication data source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      client: sl(),
    ),
  );

  // Authentication repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Authentication BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      repository: sl(),
    ),
  );
}