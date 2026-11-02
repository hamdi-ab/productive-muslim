import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/energy/presentation/screens/energy_screen.dart';

import '../../helpers/overflow_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(SettingsService.empty());
    }
  });

  Widget buildSubject() {
    return const SizedBox(height: 850, child: EnergyScreen());
  }

  group('EnergyScreen RTL and Text Scale Resilience', () {
    testWidgets('EnergyScreen has zero overflow at 1.5x scale in Arabic RTL', (
      tester,
    ) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('ar'),
        textScale: 1.5,
        isDark: true,
        screenSize: const Size(360, 780),
      );
    });

    testWidgets(
      'EnergyScreen has zero overflow in light mode at 1.5x scale in English',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: buildSubject(),
          locale: const Locale('en'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'EnergyScreen has zero overflow in dark mode at 1.5x scale in English',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: buildSubject(),
          locale: const Locale('en'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );
  });
}
