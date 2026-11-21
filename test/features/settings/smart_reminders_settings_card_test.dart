import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/smart_reminders_settings_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsService settingsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);

    if (!GetIt.instance.isRegistered<SettingsService>()) {
      GetIt.instance.registerSingleton<SettingsService>(settingsService);
    }
  });

  tearDown(() {
    if (GetIt.instance.isRegistered<SettingsService>()) {
      GetIt.instance.unregister<SettingsService>();
    }
  });

  Widget buildSubject() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(child: SmartRemindersSettingsCard()),
      ),
    );
  }

  testWidgets('renders all smart reminder toggles with initial states', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('setting_morning_adhkar_toggle')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('setting_evening_adhkar_toggle')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('setting_sleeping_adhkar_toggle')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('setting_sunnah_fasting_toggle')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('setting_qaylulah_toggle')), findsOneWidget);
    expect(
      find.byKey(const Key('setting_bedtime_time_picker')),
      findsOneWidget,
    );
  });

  testWidgets(
    'toggling morning adhkar updates settings service and reveals time picker',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final toggleFinder = find.byKey(
        const Key('setting_morning_adhkar_toggle'),
      );
      expect(toggleFinder, findsOneWidget);

      // Initial default is false (opt-in)
      expect(settingsService.morningAdhkarNotificationEnabled, isFalse);
      expect(
        find.byKey(const Key('setting_morning_time_picker')),
        findsNothing,
      );

      // Tap toggle on
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(settingsService.morningAdhkarNotificationEnabled, isTrue);
      expect(
        find.byKey(const Key('setting_morning_time_picker')),
        findsOneWidget,
      );

      // Tap toggle off
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(settingsService.morningAdhkarNotificationEnabled, isFalse);
      expect(
        find.byKey(const Key('setting_morning_time_picker')),
        findsNothing,
      );
    },
  );

  testWidgets('toggling sunnah fasting updates settings service', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final toggleFinder = find.byKey(const Key('setting_sunnah_fasting_toggle'));
    expect(toggleFinder, findsOneWidget);

    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    expect(settingsService.sunnahFastingNotificationEnabled, isFalse);
  });
}
