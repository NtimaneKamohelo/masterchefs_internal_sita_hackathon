import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_event.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_state.dart';

/// Signs the user out after a period without input.
class SessionGuard extends StatefulWidget {
  const SessionGuard({
    required this.child,
    this.timeout = const Duration(minutes: 30),
    super.key,
  });

  final Widget child;
  final Duration timeout;

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  Timer? _timer;
  StreamSubscription<AuthState>? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= context.read<AuthBloc>().stream.listen((_) => _arm());
    _arm();
  }

  void _arm() {
    _timer?.cancel();
    if (!mounted) return;
    final status = context.read<AuthBloc>().state.status;
    final active =
        status == AuthStatus.authenticated || status == AuthStatus.unverified;
    if (!active) return;
    _timer = Timer(widget.timeout, () {
      if (!mounted) return;
      final current = context.read<AuthBloc>().state.status;
      if (current == AuthStatus.authenticated ||
          current == AuthStatus.unverified) {
        context.read<AuthBloc>().add(const AuthSignOutRequested());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _arm(),
      child: widget.child,
    );
  }
}
