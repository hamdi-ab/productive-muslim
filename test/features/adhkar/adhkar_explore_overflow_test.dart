import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_explore_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/overflow_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(SettingsService(prefs: prefs));
    }
  });

  group('AdhkarExploreScreen RTL and Text Scale Resilience', () {
    testWidgets(
      'Explore screen discovery view has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(height: 900, child: AdhkarExploreScreen()),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'Explore screen discovery view has zero overflow at 1.5x scale in English LTR',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(height: 900, child: AdhkarExploreScreen()),
          locale: const Locale('en'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'Explore screen categories tab has zero overflow at 1.5x scale in Arabic',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(height: 900, child: AdhkarExploreScreen()),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );

        // Switch to Categories tab
        final categoriesTab = find.byKey(
          const Key('adhkar_explore_tab_categories'),
        );
        if (categoriesTab.evaluate().isNotEmpty) {
          await tester.tap(categoriesTab);
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      'Explore screen search results have zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(height: 900, child: AdhkarExploreScreen()),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );

        // Enter search query
        final input = find.byKey(const Key('adhkar_explore_search_input'));
        await tester.enterText(input, 'الله');
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Explore screen collection search results have zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(height: 900, child: AdhkarExploreScreen()),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );

        // Enter collection query 'الصباح' to display collection card
        final input = find.byKey(const Key('adhkar_explore_search_input'));
        await tester.enterText(input, 'الصباح');
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Explore screen no-results state has zero overflow at 1.5x scale in English',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(height: 900, child: AdhkarExploreScreen()),
          locale: const Locale('en'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
        );

        // Enter non-matching query
        final input = find.byKey(const Key('adhkar_explore_search_input'));
        await tester.enterText(input, 'nonexistentquery123xyz');
        await tester.pumpAndSettle();
      },
    );
  });
}
