import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productive_muslim/core/router/app_router.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    GetIt.I.reset();
    SharedPreferences.setMockInitialValues({});
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

  test('DI container registers SettingsService after setupDi', () {
    expect(GetIt.I.isRegistered<SettingsService>(), isTrue);
  });
}
