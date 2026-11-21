import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/prayer_notification_scheduler.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_reminders_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/overflow_test_helper.dart';

class MockNotificationPlugin extends Mock
    implements NotificationPluginAdapter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsService settingsService;
  late MockNotificationPlugin mockPlugin;
  late PrayerNotificationScheduler scheduler;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);
    mockPlugin = MockNotificationPlugin();

    when(() => mockPlugin.supported).thenReturn(true);
    when(
      () => mockPlugin.initialize(
        onNotificationTapped: any(named: 'onNotificationTapped'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockPlugin.requestPermission()).thenAnswer((_) async => true);
    when(() => mockPlugin.hasPermission()).thenAnswer((_) async => true);
    when(() => mockPlugin.cancel(any())).thenAnswer((_) async {});

    scheduler = PrayerNotificationScheduler(
      settingsService: settingsService,
      plugin: mockPlugin,
    );

    if (getIt.isRegistered<SettingsService>()) {
      getIt.unregister<SettingsService>();
    }
    getIt.registerSingleton<SettingsService>(settingsService);

    if (getIt.isRegistered<PrayerNotificationScheduler>()) {
      getIt.unregister<PrayerNotificationScheduler>();
    }
    getIt.registerSingleton<PrayerNotificationScheduler>(scheduler);
  });

  tearDown(() {
    if (getIt.isRegistered<SettingsService>()) {
      getIt.unregister<SettingsService>();
    }
    if (getIt.isRegistered<PrayerNotificationScheduler>()) {
      getIt.unregister<PrayerNotificationScheduler>();
    }
  });

  group('AdhkarRemindersSheet RTL and Text Scale Resilience', () {
    testWidgets(
      'AdhkarRemindersSheet has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(height: 800, child: AdhkarRemindersSheet()),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'AdhkarRemindersSheet has zero overflow at 1.5x scale in English light mode',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(height: 800, child: AdhkarRemindersSheet()),
          locale: const Locale('en'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'AdhkarRemindersSheet with permission warning has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        when(() => mockPlugin.hasPermission()).thenAnswer((_) async => false);

        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(height: 800, child: AdhkarRemindersSheet()),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );
  });
}
