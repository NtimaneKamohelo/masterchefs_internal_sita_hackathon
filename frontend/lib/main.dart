import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masterchefs_internal_sita_hackathon/app/router/app_routes.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/presentation/bloc/auth_event.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/presentation/pages/auth_gate.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/presentation/pages/register_page.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/presentation/pages/update_password_page.dart';
import 'package:masterchefs_internal_sita_hackathon/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = "https://xmjwggnuxrtmoozgusch.supabase.co";
  const supabaseKey = "sb_publishable_LsBCwR4r-XW2srTJTh6eCw_0pVMW2bb";

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw StateError('Supabase configuration is missing.');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseKey,
    //debug: true,
  );

  await initializeDependencies();

  runApp(const MasterChefsApp());
}

class MasterChefsApp extends StatelessWidget {
  const MasterChefsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(AuthSessionRequested()),
      child: MaterialApp(
        title: 'Bursary Portal',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          inputDecorationTheme: const InputDecorationTheme(filled: true),
        ),

        home: const AuthGate(),

        routes: {
          AppRoutes.register: (_) => const RegisterPage(),
          AppRoutes.forgotPassword: (_) => const ForgotPasswordPage(),
          AppRoutes.updatePassword: (_) => const UpdatePasswordPage(),
        },
      ),
    );
  }
}
