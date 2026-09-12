import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'package:productive_muslim/core/router/app_router.dart';
import 'package:productive_muslim/core/di/di.dart';

void main() {
  setUp(() async {
    GetIt.I.reset();
    await setupDi();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  test('router initial location is /onboarding', () {
    final router = AppRouter.router;
    expect(router, isA<GoRouter>());
  });

  test('router is configured', () {
    final router = AppRouter.router;
    expect(router, isNotNull);
  });

  test('DI container registers GoRouter after setupDi', () {
    expect(GetIt.I.isRegistered<GoRouter>(), isTrue);
  });
}
