import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'package:productive_muslim/core/router/app_router.dart';
import 'package:productive_muslim/core/di/di.dart';

void main() {
  setUp(() {
    if (!GetIt.I.isRegistered<GoRouter>()) {
      setupDi();
    }
  });

  tearDown(() {
    GetIt.I.reset();
  });

  test('router initial location is /onboarding', () {
    final router = AppRouter.router;
    expect(router, isA<GoRouter>());
  });

  test('router has onboarding route at /onboarding', () {
    final routes = AppRouter.router.routes;
    final hasOnboarding = routes.any((route) {
      if (route is GoRoute) {
        return route.path == '/onboarding';
      }
      return false;
    });
    expect(hasOnboarding, isTrue,
        reason: 'Router must define a GoRoute at /onboarding');
  });

  test('router has home shell route with 5 child routes', () {
    final routes = AppRouter.router.routes;
    final hasShell = routes.any((route) {
      if (route is ShellRoute) {
        final childPaths = route.routes
            .whereType<GoRoute>()
            .map((r) => r.path)
            .toList();
        return childPaths.contains('/') &&
            childPaths.contains('/tasks') &&
            childPaths.contains('/habits') &&
            childPaths.contains('/barakah') &&
            childPaths.contains('/journal');
      }
      return false;
    });
    expect(hasShell, isTrue,
        reason: 'Router must define a ShellRoute with 5 child routes');
  });

  test('router has error builder', () {
    expect(AppRouter.router.errorBuilder, isNotNull,
        reason: 'Router must define an errorBuilder');
  });

  test('DI container registers GoRouter after setupDi', () async {
    GetIt.I.reset();
    await setupDi();
    expect(GetIt.I.isRegistered<GoRouter>(), isTrue);
  });
}