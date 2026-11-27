import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grantsandbenfits/core/constants/route_paths.dart';
import 'package:grantsandbenfits/core/di/injection.dart';
import 'package:grantsandbenfits/core/router/go_router_refresh.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_state.dart';
import 'package:grantsandbenfits/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:grantsandbenfits/features/auth/presentation/pages/login_page.dart';
import 'package:grantsandbenfits/features/auth/presentation/pages/register_page.dart';
import 'package:grantsandbenfits/features/auth/presentation/pages/reset_password_page.dart';
import 'package:grantsandbenfits/features/auth/presentation/pages/splash_page.dart';
import 'package:grantsandbenfits/features/auth/presentation/pages/verify_email_page.dart';
import 'package:grantsandbenfits/features/documents/presentation/bloc/document_verification_bloc.dart';
import 'package:grantsandbenfits/features/documents/presentation/pages/documents_page.dart';
import 'package:grantsandbenfits/features/home/presentation/pages/home_page.dart';

String? authRedirect({
  required AuthStatus status,
  required String location,
}) {
  const publicRoutes = {
    RoutePaths.login,
    RoutePaths.register,
    RoutePaths.forgotPassword,
    RoutePaths.resetPassword,
  };
  const authenticatedRoutes = {RoutePaths.home, RoutePaths.documents};

  if (status == AuthStatus.unknown) {
    return location == RoutePaths.splash ? null : RoutePaths.splash;
  }
  if (status == AuthStatus.unauthenticated) {
    return publicRoutes.contains(location) ? null : RoutePaths.login;
  }
  if (status == AuthStatus.unverified) {
    return location == RoutePaths.verifyEmail ? null : RoutePaths.verifyEmail;
  }
  return authenticatedRoutes.contains(location) ? null : RoutePaths.home;
}

GoRouter createRouter({
  required AuthBloc authBloc,
  required GoRouterRefreshStream refresh,
}) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      return authRedirect(
        status: authBloc.state.status,
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: RoutePaths.verifyEmail,
        builder: (context, state) => const VerifyEmailPage(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RoutePaths.documents,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<DocumentVerificationBloc>(),
          child: const DocumentsPage(),
        ),
      ),
    ],
  );
}
