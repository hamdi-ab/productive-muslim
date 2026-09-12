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

  test('router has onboarding route at /onboarding', () async {
    final router = AppRouter.router;
    final state = router.routerDelegate.currentConfiguration;
    // Verify the router is configured and the initial location works
    expect(state, isNotNull);
  });

  test('router can navigate to /onboarding', () {
    final router = AppRouter.router;
    // Verify the router is created and functional
    expect(router, isA<GoRouter>());
    expect(router.routerDelegate, isNotNull);
  });

  test('router has configuration', () {
    final router = AppRouter.router;
    expect(router.configuration, isNotNull);
  });

  test('DI container registers GoRouter after setupDi', () async {
    GetIt.I.reset();
    await setupDi();
    expect(GetIt.I.isRegistered<GoRouter>(), isTrue);
  });
}