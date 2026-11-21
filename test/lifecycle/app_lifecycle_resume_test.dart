import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/prayer_notification_scheduler.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mocks.dart';

class SpyingPrayerTimeService extends PrayerTimeService {
  int getCurrentPositionCalls = 0;
  int getCachedOrSavedPositionCalls = 0;

  @override
  Future<Position?> getCurrentPosition() async {
    getCurrentPositionCalls++;
    return super.getCurrentPosition();
  }

  @override
  Position? getCachedOrSavedPosition() {
    getCachedOrSavedPositionCalls++;
    return super.getCachedOrSavedPosition();
  }
}

class MockNotificationPlugin extends Mock
    implements NotificationPluginAdapter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsService settingsService;
  late SpyingPrayerTimeService prayerTimeService;
  late MockNotificationPlugin mockNotificationPlugin;
  late PrayerNotificationScheduler scheduler;
  int geolocatorChannelCalls = 0;

  setUp(() async {
    await getIt.reset();
    geolocatorChannelCalls = 0;

    // Track any geolocator platform channel invocations (e.g. checkPermission, requestPermission, etc.)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          (call) async {
            geolocatorChannelCalls++;
            return null;
          },
        );

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);

    prayerTimeService = SpyingPrayerTimeService();
    mockNotificationPlugin = MockNotificationPlugin();

    when(() => mockNotificationPlugin.supported).thenReturn(true);
    when(() => mockNotificationPlugin.localTimezoneName).thenReturn('UTC');
    when(() => mockNotificationPlugin.updateLocalTimezone(any()))
        .thenAnswer((_) async {});
    when(
      () => mockNotificationPlugin.initialize(
        onNotificationTapped: any(named: 'onNotificationTapped'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockNotificationPlugin.requestPermission())
        .thenAnswer((_) async => true);
    when(() => mockNotificationPlugin.hasPermission())
        .thenAnswer((_) async => true);
    when(() => mockNotificationPlugin.cancel(any())).thenAnswer((_) async {});
    when(
      () => mockNotificationPlugin.zonedSchedule(
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
      plugin: mockNotificationPlugin,
    );

    // Register all dependencies expected by MyApp
    getIt.registerSingleton<SettingsService>(settingsService);
    getIt.registerSingleton<PrayerNotificationScheduler>(scheduler);
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);
    getIt.registerSingleton<BarakahRepository>(MockBarakahRepository());
    getIt.registerSingleton<HabitRepository>(MockHabitRepository());
    getIt.registerSingleton<TaskRepository>(MockTaskRepository());
    getIt.registerSingleton<IntentionRepository>(MockIntentionRepository());
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          null,
        );
    await getIt.reset();
  });

  group('App Resume Lifecycle Rescheduling', () {
    testWidgets(
      'resuming without cached or saved coordinates reschedules location-independent reminders without requesting location permission',
      (tester) async {
        await settingsService.setMorningAdhkarNotificationEnabled(true);
        await settingsService.setEveningAdhkarNotificationEnabled(true);

        expect(prayerTimeService.cachedPosition, isNull);
        expect(settingsService.lastCoordinates, isNull);

        await tester.pumpWidget(const MyApp());
        await tester.pump();

        // Simulate app pausing and resuming
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Proves that non-interactive getCachedOrSavedPosition was used
        expect(
          prayerTimeService.getCachedOrSavedPositionCalls,
          greaterThanOrEqualTo(1),
        );

        // CRITICAL: Proves getCurrentPosition was NEVER called on resume
        expect(prayerTimeService.getCurrentPositionCalls, equals(0));

        // CRITICAL: Proves NO geolocator platform channel permission requests were made
        expect(geolocatorChannelCalls, equals(0));

        // Verifies location-independent adhkar reminders were rescheduled
        verify(
          () => mockNotificationPlugin.zonedSchedule(
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

        verify(
          () => mockNotificationPlugin.zonedSchedule(
            id: PrayerNotificationScheduler.idEveningAdhkar,
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            payload: '/adhkar?category=evening',
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            matchTimeOnly: true,
          ),
        ).called(1);
      },
    );

    testWidgets(
      'resuming with previously saved coordinates reschedules all reminders without requesting location permission',
      (tester) async {
        // Seed saved coordinates in settings (e.g. Riyadh)
        await settingsService.setLastCoordinates(24.7136, 46.6753);
        await settingsService.setMorningAdhkarNotificationEnabled(true);
        await settingsService.setEveningAdhkarNotificationEnabled(true);
        await settingsService.setQaylulahNotificationEnabled(true);

        await tester.pumpWidget(const MyApp());
        await tester.pump();

        // Simulate app pausing and resuming
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Proves that non-interactive getCachedOrSavedPosition was used
        expect(
          prayerTimeService.getCachedOrSavedPositionCalls,
          greaterThanOrEqualTo(1),
        );

        // CRITICAL: Proves getCurrentPosition was NEVER called
        expect(prayerTimeService.getCurrentPositionCalls, equals(0));

        // CRITICAL: Proves NO geolocator platform channel permission requests were made
        expect(geolocatorChannelCalls, equals(0));

        // Verifies reminders including solar Qaylulah were rescheduled using saved coordinates
        verify(
          () => mockNotificationPlugin.zonedSchedule(
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

        verify(
          () => mockNotificationPlugin.zonedSchedule(
            id: PrayerNotificationScheduler.idQaylulah,
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            payload: '/energy',
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
          ),
        ).called(1);
      },
    );
  });
}
