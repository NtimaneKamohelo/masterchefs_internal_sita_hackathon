import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:masterchefs_internal_sita_hackathon/features/authentication/presentation/bloc/auth_event.dart';
import 'package:masterchefs_internal_sita_hackathon/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY',);

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw StateError(
      'Supabase configuration is missing.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseKey,
    debug: false,
  );

  await initializeDependencies();

  runApp(const MasterChefsApp());
}

class MasterChefsApp extends StatelessWidget {
  const MasterChefsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()
        ..add(AuthSessionRequested()),
      child: MaterialApp(
        title: 'Bursary Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
        ),
        home: const Scaffold(
          body: Center(
            child: Text(
              'Bursary Assistant',
            ),
          ),
        ),
      ),
    );
  }
}