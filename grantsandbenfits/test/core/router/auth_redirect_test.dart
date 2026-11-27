import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/core/constants/route_paths.dart';
import 'package:grantsandbenfits/core/router/app_router.dart';
import 'package:grantsandbenfits/features/auth/presentation/bloc/auth_state.dart';

void main() {
  test('unknown sessions stay on the splash route', () {
    expect(
      authRedirect(status: AuthStatus.unknown, location: RoutePaths.login),
      RoutePaths.splash,
    );
    expect(
      authRedirect(status: AuthStatus.unknown, location: RoutePaths.splash),
      isNull,
    );
  });

  test('signed-out people can open the auth pages only', () {
    expect(
      authRedirect(status: AuthStatus.unauthenticated, location: RoutePaths.home),
      RoutePaths.login,
    );
    expect(
      authRedirect(
        status: AuthStatus.unauthenticated,
        location: RoutePaths.register,
      ),
      isNull,
    );
  });

  test('unverified accounts are kept on email verification', () {
    expect(
      authRedirect(status: AuthStatus.unverified, location: RoutePaths.home),
      RoutePaths.verifyEmail,
    );
    expect(
      authRedirect(
        status: AuthStatus.unverified,
        location: RoutePaths.verifyEmail,
      ),
      isNull,
    );
  });

  test('verified accounts land on home', () {
    expect(
      authRedirect(status: AuthStatus.authenticated, location: RoutePaths.login),
      RoutePaths.home,
    );
    expect(
      authRedirect(status: AuthStatus.authenticated, location: RoutePaths.home),
      isNull,
    );
  });
}
