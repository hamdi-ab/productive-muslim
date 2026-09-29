import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

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

  Widget buildSubject({DhikrCategory initialCategory = DhikrCategory.morning}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AdhkarScreen(initialCategory: initialCategory),
    );
  }

  testWidgets(
    'renders Adhkar screen with category tabs, Arabic card and counter',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(initialCategory: DhikrCategory.morning),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Adhkar & Remembrances'), findsOneWidget);
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);
      expect(
        find.text('Ayat al-Kursi (The Verse of the Throne)'),
        findsOneWidget,
      );
      expect(find.text('Tap anywhere to count'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping full-screen tap area increments count and records completion',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(initialCategory: DhikrCategory.wakingUp),
      );
      await tester.pumpAndSettle();

      expect(find.text('0 / 1'), findsOneWidget);

      final tapArea = find.text('Tap anywhere to count');
      expect(tapArea, findsOneWidget);

      // Tap once to complete the 1-count dhikr
      await tester.tap(tapArea);
      await tester.pump(); // immediate frame

      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.text('Completed! Alhamdulillah'), findsOneWidget);

      // After 600ms + animation, auto-advances to card 2
      await tester.pumpAndSettle();
      expect(getIt<AdhkarService>().isDhikrCompleted('wake_up_1'), isTrue);
      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.text('Affirmation of Tawheed upon Waking'), findsOneWidget);
    },
  );

  testWidgets('switching category tabs updates the dhikr list', (tester) async {
    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.morning),
    );
    await tester.pumpAndSettle();

    final eveningTab = find.text('Evening');
    expect(eveningTab, findsOneWidget);

    await tester.tap(eveningTab);
    await tester.pumpAndSettle();

    expect(find.text('Entering the Evening Supplication'), findsOneWidget);
  });
}
