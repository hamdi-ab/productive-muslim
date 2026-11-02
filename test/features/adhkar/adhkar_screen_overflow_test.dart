import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_screen.dart';

import '../../helpers/overflow_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(SettingsService(prefs: prefs));
    }
    if (!getIt.isRegistered<AdhkarService>()) {
      getIt.registerSingleton<AdhkarService>(
        AdhkarService(settingsService: getIt<SettingsService>()),
      );
    }
  });

  group('AdhkarScreen RTL and Text Scale Resilience', () {
    testWidgets('AdhkarScreen has zero overflow at 1.5x scale in Arabic RTL', (
      tester,
    ) async {
      await pumpAndCheckOverflow(
        tester,
        child: const SizedBox(
          height: 900,
          child: AdhkarScreen(initialCategory: DhikrCategory.morning),
        ),
        locale: const Locale('ar'),
        textScale: 1.5,
        isDark: true,
        screenSize: const Size(360, 780),
      );
    });

    testWidgets(
      'AdhkarScreen has zero overflow in light mode at 1.5x scale in English',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(
            height: 900,
            child: AdhkarScreen(initialCategory: DhikrCategory.wakingUp),
          ),
          locale: const Locale('en'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'AdhkarScreen with completed dhikr has zero overflow at 1.5x in Arabic',
      (tester) async {
        final adhkarService = getIt<AdhkarService>();
        await adhkarService.recordDhikrCompletion(dhikrId: 'wake_up_1');

        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(
            height: 900,
            child: AdhkarScreen(initialCategory: DhikrCategory.wakingUp),
          ),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );
  });
}
