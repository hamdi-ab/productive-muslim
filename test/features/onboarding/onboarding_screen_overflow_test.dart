import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/overflow_test_helper.dart';

void main() {
  late SettingsService settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settings = SettingsService(prefs: prefs);
  });

  Widget buildSubject() {
    return OnboardingScreen(settings: settings);
  }

  group('OnboardingScreen - Overflow & Text-Scale Resilience', () {
    testWidgets('no overflow at 1.0x text scale (LTR)', (tester) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('en'),
        textScale: 1.0,
        wrapInScrollView: false,
      );
    });

    testWidgets('no overflow at 1.5x text scale (LTR)', (tester) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('en'),
        textScale: 1.5,
        wrapInScrollView: false,
      );
    });

    testWidgets('no overflow at 1.5x text scale (RTL Arabic)', (tester) async {
      await pumpAndCheckOverflow(
        tester,
        child: buildSubject(),
        locale: const Locale('ar'),
        textScale: 1.5,
        wrapInScrollView: false,
      );
    });
  });
}
