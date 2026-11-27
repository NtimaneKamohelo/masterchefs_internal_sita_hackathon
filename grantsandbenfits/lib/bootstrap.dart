import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:grantsandbenfits/app.dart';
import 'package:grantsandbenfits/core/config/app_config.dart';
import 'package:grantsandbenfits/core/config/firebase_options_loader.dart';
import 'package:grantsandbenfits/core/di/injection.dart';
import 'package:grantsandbenfits/core/security/app_check_activator.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_event.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  try {
    config.assertSafe();
    if (config.useFirebase) {
      await Firebase.initializeApp(
        options: FirebaseOptionsLoader.fromConfig(config),
      );
      if (kIsWeb) {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      }
      await AppCheckActivator.activate(config);
    }
    await configureDependencies(config);
    final authBloc = getIt<AuthBloc>()..add(const AuthStarted());
    runApp(GrantsApp(authBloc: authBloc));
  } on StateError catch (error) {
    runApp(ConfigurationErrorApp(message: error.message));
  } on FirebaseException catch (error) {
    runApp(
      ConfigurationErrorApp(
        message:
            'Firebase could not start (${error.code}). Check env/env.json and the Firebase console.',
      ),
    );
  }
}
