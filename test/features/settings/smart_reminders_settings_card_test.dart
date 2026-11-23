import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/data/services/prayer_notification_scheduler.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/settings/presentation/widgets/smart_reminders_settings_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;

class MockNotificationPlugin extends Mock
    implements NotificationPluginAdapter {}

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz_data.initializeTimeZones();
  });
  late SettingsService settingsService;
  late MockNotificationPlugin mockPlugin;
  late PrayerNotificationScheduler scheduler;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);

    mockPlugin = MockNotificationPlugin();
    when(() => mockPlugin.supported).thenReturn(true);
    when(() => mockPlugin.localTimezoneName).thenReturn('UTC');
    when(() => mockPlugin.updateLocalTimezone(any())).thenAnswer((_) async {});
    when(
      () => mockPlugin.initialize(
        onNotificationTapped: any(named: 'onNotificationTapped'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockPlugin.requestPermission()).thenAnswer((_) async => true);
    when(() => mockPlugin.hasPermission()).thenAnswer((_) async => true);
    when(() => mockPlugin.cancel(any())).thenAnswer((_) async {});
    when(
      () => mockPlugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        payload: any(named: 'payload'),
        channelId: any(named: 'channelId'),
        channelName: any(named: 'channelName'),
        matchTimeOnly: any(named: 'matchTimeOnly'),
      ),
    ).thenAnswer((_) async {});

    scheduler = PrayerNotificationScheduler(
      settingsService: settingsService,
      plugin: mockPlugin,
    );

    if (!GetIt.instance.isRegistered<SettingsService>()) {
      GetIt.instance.registerSingleton<SettingsService>(settingsService);
    }
    if (!GetIt.instance.isRegistered<PrayerNotificationScheduler>()) {
      GetIt.instance.registerSingleton<PrayerNotificationScheduler>(scheduler);
    }
  });

  tearDown(() {
    if (GetIt.instance.isRegistered<PrayerNotificationScheduler>()) {
      GetIt.instance.unregister<PrayerNotificationScheduler>();
    }
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

  testWidgets(
    'shows permission warning card when notification permission is denied',
    (tester) async {
      when(() => mockPlugin.hasPermission()).thenAnswer((_) async => false);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('smart_reminders_permission_warning')),
        findsOneWidget,
      );
      expect(find.text('Notification Permission Required'), findsOneWidget);

      final grantBtn = find.byKey(
        const Key('smart_reminders_grant_permission_button'),
      );
      expect(grantBtn, findsOneWidget);

      await tester.tap(grantBtn);
      await tester.pumpAndSettle();

      verify(() => mockPlugin.requestPermission()).called(1);
    },
  );

  testWidgets(
    'toggling morning reminder when permission denied saves preference, displays toggle as true, shows snackbar and delivery pending badge',
    (tester) async {
      when(() => mockPlugin.hasPermission()).thenAnswer((_) async => false);
      when(() => mockPlugin.requestPermission()).thenAnswer((_) async => false);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final toggleFinder = find.byKey(
        const Key('setting_morning_adhkar_toggle'),
      );
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(settingsService.morningAdhkarNotificationEnabled, isTrue);
      final switchTile = tester.widget<SwitchListTile>(toggleFinder);
      expect(switchTile.value, isTrue);
      expect(
        find.byKey(const Key('smart_reminders_permission_snackbar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('setting_morning_delivery_pending_badge')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'when permission is denied, toggle displays true saved preference with delivery pending badge',
    (tester) async {
      await settingsService.setMorningAdhkarNotificationEnabled(true);
      when(() => mockPlugin.hasPermission()).thenAnswer((_) async => false);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final toggleFinder = find.byKey(
        const Key('setting_morning_adhkar_toggle'),
      );
      final switchTile = tester.widget<SwitchListTile>(toggleFinder);
      expect(switchTile.value, isTrue);
      expect(settingsService.morningAdhkarNotificationEnabled, isTrue);
      expect(
        find.byKey(const Key('setting_morning_delivery_pending_badge')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'when permission is later granted via button, saved preferences are rescheduled without re-entering',
    (tester) async {
      await settingsService.setMorningAdhkarNotificationEnabled(true);
      when(() => mockPlugin.hasPermission()).thenAnswer((_) async => false);
      when(() => mockPlugin.requestPermission()).thenAnswer((_) async => true);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('setting_morning_delivery_pending_badge')),
        findsOneWidget,
      );

      // Grant permission via the button
      when(() => mockPlugin.hasPermission()).thenAnswer((_) async => true);
      final grantBtn = find.byKey(
        const Key('smart_reminders_grant_permission_button'),
      );
      await tester.tap(grantBtn);
      await tester.pumpAndSettle();

      // Morning adhkar scheduled
      verify(
        () => mockPlugin.zonedSchedule(
          id: PrayerNotificationScheduler.idMorningAdhkar,
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: '/adhkar?category=morning',
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
          matchTimeOnly: true,
        ),
      ).called(1);

      // Delivery pending badge is removed
      expect(
        find.byKey(const Key('setting_morning_delivery_pending_badge')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'when permission is later granted in system settings and app resumed, saved preferences are rescheduled and delivery pending badge is cleared',
    (tester) async {
      await settingsService.setMorningAdhkarNotificationEnabled(true);
      when(() => mockPlugin.hasPermission()).thenAnswer((_) async => false);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('setting_morning_delivery_pending_badge')),
        findsOneWidget,
      );

      // User grants permission in system settings and returns to app
      when(() => mockPlugin.hasPermission()).thenAnswer((_) async => true);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      verify(
        () => mockPlugin.zonedSchedule(
          id: PrayerNotificationScheduler.idMorningAdhkar,
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: '/adhkar?category=morning',
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
          matchTimeOnly: true,
        ),
      ).called(1);

      expect(
        find.byKey(const Key('setting_morning_delivery_pending_badge')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'changing reminder settings with no saved coordinates reschedules location-independent reminders without requesting location',
    (tester) async {
      final mockPrayerService = MockPrayerTimeService();
      when(() => mockPrayerService.getCachedOrSavedPosition()).thenReturn(null);
      GetIt.instance.registerSingleton<PrayerTimeService>(mockPrayerService);
      addTearDown(() {
        if (GetIt.instance.isRegistered<PrayerTimeService>()) {
          GetIt.instance.unregister<PrayerTimeService>();
        }
      });

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final toggleFinder = find.byKey(
        const Key('setting_morning_adhkar_toggle'),
      );
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      verify(() => mockPrayerService.getCachedOrSavedPosition()).called(1);
      verifyNever(() => mockPrayerService.getCurrentPosition());
      verify(
        () => mockPlugin.zonedSchedule(
          id: PrayerNotificationScheduler.idMorningAdhkar,
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: '/adhkar?category=morning',
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
          matchTimeOnly: true,
        ),
      ).called(1);
    },
  );

  testWidgets(
    'no-coordinates and permission-denied path with bedtime and fasting preferences enabled does not schedule notifications, preserves preferences, and schedules after permission is granted',
    (tester) async {
      final mockPrayerService = MockPrayerTimeService();
      when(() => mockPrayerService.getCachedOrSavedPosition()).thenReturn(null);
      GetIt.instance.registerSingleton<PrayerTimeService>(mockPrayerService);
      addTearDown(() {
        if (GetIt.instance.isRegistered<PrayerTimeService>()) {
          GetIt.instance.unregister<PrayerTimeService>();
        }
      });

      // Explicitly enable bedtime and fasting preferences
      await settingsService.setSleepingAdhkarNotificationEnabled(true);
      await settingsService.setSunnahFastingNotificationEnabled(true);

      // Permission denied
      when(() => mockPlugin.hasPermission()).thenAnswer((_) async => false);
      when(() => mockPlugin.requestPermission()).thenAnswer((_) async => false);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Preferences preserved in settings
      expect(settingsService.sleepingAdhkarNotificationEnabled, isTrue);
      expect(settingsService.sunnahFastingNotificationEnabled, isTrue);

      // Delivery pending badges shown because preferences are enabled while permission is denied
      expect(
        find.byKey(const Key('setting_sleeping_delivery_pending_badge')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('setting_fasting_delivery_pending_badge')),
        findsOneWidget,
      );

      // Trigger a settings change to exercise _reschedule() with no coordinates and denied permission
      final morningToggle = find.byKey(
        const Key('setting_morning_adhkar_toggle'),
      );
      await tester.tap(morningToggle);
      await tester.pumpAndSettle();

      // Non-interactive check was used, no location requested
      verify(() => mockPrayerService.getCachedOrSavedPosition())
          .called(greaterThanOrEqualTo(1));
      verifyNever(() => mockPrayerService.getCurrentPosition());

      // Preferences still preserved
      expect(settingsService.sleepingAdhkarNotificationEnabled, isTrue);
      expect(settingsService.sunnahFastingNotificationEnabled, isTrue);

      // NO notifications scheduled while permission is denied
      verifyNever(
        () => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
          matchTimeOnly: any(named: 'matchTimeOnly'),
        ),
      );

      // Now permission is granted via button
      when(() => mockPlugin.hasPermission()).thenAnswer((_) async => true);
      when(() => mockPlugin.requestPermission()).thenAnswer((_) async => true);
      final grantBtn = find.byKey(
        const Key('smart_reminders_grant_permission_button'),
      );
      await tester.tap(grantBtn);
      await tester.pumpAndSettle();

      // Both bedtime and fasting notifications are now scheduled
      verify(
        () => mockPlugin.zonedSchedule(
          id: PrayerNotificationScheduler.idSleepingAdhkar,
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: '/adhkar?category=sleeping',
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
          matchTimeOnly: true,
        ),
      ).called(1);

      verify(
        () => mockPlugin.zonedSchedule(
          id: PrayerNotificationScheduler.idSunnahFasting,
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: '/energy',
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
        ),
      ).called(1);

      // Badges cleared
      expect(
        find.byKey(const Key('setting_sleeping_delivery_pending_badge')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('setting_fasting_delivery_pending_badge')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'scheduling error reverts toggle state and displays error snackbar',
    (tester) async {
      when(
        () => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
          matchTimeOnly: any(named: 'matchTimeOnly'),
        ),
      ).thenThrow(Exception('Platform scheduler error'));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final toggleFinder = find.byKey(
        const Key('setting_morning_adhkar_toggle'),
      );
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(settingsService.morningAdhkarNotificationEnabled, isFalse);
      final switchTile = tester.widget<SwitchListTile>(toggleFinder);
      expect(switchTile.value, isFalse);
      expect(
        find.byKey(const Key('smart_reminders_error_snackbar')),
        findsOneWidget,
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
