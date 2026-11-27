import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantsandbenfits/core/router/app_router.dart';
import 'package:grantsandbenfits/core/router/go_router_refresh.dart';
import 'package:grantsandbenfits/core/security/session_guard.dart';
import 'package:grantsandbenfits/core/theme/app_theme.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';

class GrantsApp extends StatefulWidget {
  const GrantsApp({required this.authBloc, super.key});

  final AuthBloc authBloc;

  @override
  State<GrantsApp> createState() => _GrantsAppState();
}

class _GrantsAppState extends State<GrantsApp> {
  late final GoRouterRefreshStream _refresh = GoRouterRefreshStream(
    widget.authBloc.stream,
  );
  late final _router = createRouter(
    authBloc: widget.authBloc,
    refresh: _refresh,
  );

  @override
  void dispose() {
    _refresh.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.authBloc,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Grants & Benefits',
        theme: AppTheme.light(),
        routerConfig: _router,
        builder: (context, child) {
          return SessionGuard(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}

class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(message),
          ),
        ),
      ),
    );
  }
}
