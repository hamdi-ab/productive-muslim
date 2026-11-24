import 'dart:ui';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/data/services/adhan_notification_service.dart';
import 'package:productive_muslim/data/services/prayer_notification_scheduler.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAdhanNotificationService extends Mock
    implements AdhanNotificationService {}

class MockPrayerNotificationScheduler extends Mock
    implements PrayerNotificationScheduler {}

class MockNotificationPluginAdapter extends Mock
    implements NotificationPluginAdapter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PrayerTimeService service;
  late SettingsService settingsService;

  setUp(() async {
    await GetIt.I.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);
    GetIt.I.registerSingleton<SettingsService>(settingsService);
    service = PrayerTimeService(settingsService: settingsService);
    GetIt.I.registerSingleton<PrayerTimeService>(service);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('PrayerTimeService tests', () {
    test('getCachedOrSavedPosition returns null when neither cached nor saved coordinates exist', () {
      expect(service.cachedPosition, isNull);
      expect(settingsService.lastCoordinates, isNull);
      expect(service.getCachedOrSavedPosition(), isNull);
    });

    test(
      'getCachedOrSavedPosition returns in-memory cached position when present',
      () {
        final mockPos = Position(
          latitude: 24.7136,
          longitude: 46.6753,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        service.setCachedPositionForTesting(mockPos);

        final result = service.getCachedOrSavedPosition();
        expect(result, isNotNull);
        expect(result!.latitude, equals(24.7136));
        expect(result.longitude, equals(46.6753));
      },
    );

    test('getCachedOrSavedPosition reconstructs position from settings without requesting GPS', () async {
      await settingsService.setLastCoordinates(21.4225, 39.8262);
      expect(service.cachedPosition, isNull);

      final result = service.getCachedOrSavedPosition();
      expect(result, isNotNull);
      expect(result!.latitude, equals(21.4225));
      expect(result.longitude, equals(39.8262));
      // Verifies it populated the in-memory cache
      expect(service.cachedPosition, isNotNull);
    });

    test('getCurrentPosition returns non-null position via fallback when geolocator is unavailable', () async {
      final position = await service.getCurrentPosition();
      expect(position, isNotNull);
      expect(position!.latitude, isNot(0));
      expect(position.longitude, isNot(0));
    });

    test(
      'getPrayerTimes calculates valid prayer times from position',
      () async {
        final position = await service.getCurrentPosition();
        expect(position, isNotNull);

        final prayerTimes = service.getPrayerTimes(position!);
        expect(prayerTimes, isNotNull);
        expect(prayerTimes!.fajr, isNotNull);
        expect(prayerTimes.sunrise, isNotNull);
        expect(prayerTimes.dhuhr, isNotNull);
        expect(prayerTimes.asr, isNotNull);
        expect(prayerTimes.maghrib, isNotNull);
        expect(prayerTimes.isha, isNotNull);
      },
    );

    test('getNextPrayerName returns a valid prayer name', () async {
      final position = await service.getCurrentPosition();
      final prayerTimes = service.getPrayerTimes(position!);
      final nextPrayer = service.getNextPrayerName(prayerTimes!);

      expect([
        'Fajr',
        'Sunrise',
        'Dhuhr',
        'Asr',
        'Maghrib',
        'Isha',
      ], contains(nextPrayer));
    });

    test('getTimeUntilNextPrayer returns non-negative duration', () async {
      final position = await service.getCurrentPosition();
      final prayerTimes = service.getPrayerTimes(position!);
      final duration = service.getTimeUntilNextPrayer(prayerTimes!);

      expect(duration, isNotNull);
      expect(duration!.isNegative, isFalse);
    });

    test('getLocationName returns a non-empty string', () async {
      final position = await service.getCurrentPosition();
      final name = service.getLocationName(position);

      expect(name.isNotEmpty, isTrue);
    });
  });

  group('Prayer Calculation Method and Madhab Preferences', () {
    final cairoPos = Position(
      latitude: 30.0444,
      longitude: 31.2357,
      timestamp: DateTime(2026, 9, 29, 12, 0),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

    final makkahPos = Position(
      latitude: 21.4225,
      longitude: 39.8262,
      timestamp: DateTime(2026, 9, 29, 12, 0),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

    test('defaults to Muslim World League and Shafi madhab', () {
      expect(
        settingsService.prayerCalculationMethod,
        equals(CalculationMethod.muslimWorldLeague),
      );
      expect(settingsService.prayerMadhab, equals(Madhab.shafi));
      expect(
        settingsService.calculationMethodNotifier.value,
        equals(CalculationMethod.muslimWorldLeague),
      );
      expect(settingsService.madhabNotifier.value, equals(Madhab.shafi));
    });

    test('persists selected calculation method and updates notifier', () async {
      await settingsService.setPrayerCalculationMethod(
        CalculationMethod.egyptian,
      );
      expect(
        settingsService.prayerCalculationMethod,
        equals(CalculationMethod.egyptian),
      );
      expect(
        settingsService.calculationMethodNotifier.value,
        equals(CalculationMethod.egyptian),
      );

      // Verify on freshly created SettingsService reading same SharedPreferences
      final reloaded = SettingsService(prefs: settingsService.prefs!);
      expect(
        reloaded.prayerCalculationMethod,
        equals(CalculationMethod.egyptian),
      );
    });

    test('persists selected Asr madhab and updates notifier', () async {
      await settingsService.setPrayerMadhab(Madhab.hanafi);
      expect(settingsService.prayerMadhab, equals(Madhab.hanafi));
      expect(settingsService.madhabNotifier.value, equals(Madhab.hanafi));

      final reloaded = SettingsService(prefs: settingsService.prefs!);
      expect(reloaded.prayerMadhab, equals(Madhab.hanafi));
    });

    test('calculation method change alters calculated prayer times', () async {
      final date = DateTime(2026, 9, 29);

      // Default MWL: Fajr angle is 18°
      await settingsService.setPrayerCalculationMethod(
        CalculationMethod.muslimWorldLeague,
      );
      final mwlTimes = service.getPrayerTimes(cairoPos, date: date)!;

      // Egyptian Survey Authority: Fajr angle is 19.5° (dawn is earlier)
      await settingsService.setPrayerCalculationMethod(
        CalculationMethod.egyptian,
      );
      final egyptianTimes = service.getPrayerTimes(cairoPos, date: date)!;

      expect(
        egyptianTimes.fajr.isBefore(mwlTimes.fajr),
        isTrue,
        reason: 'Egyptian 19.5° Fajr should start earlier than MWL 18°',
      );
    });

    test('Asr madhab change alters calculated Asr prayer time', () async {
      final date = DateTime(2026, 9, 29);

      // Standard (Shafi): shadow factor = 1
      await settingsService.setPrayerMadhab(Madhab.shafi);
      final shafiTimes = service.getPrayerTimes(makkahPos, date: date)!;

      // Hanafi: shadow factor = 2 (Asr begins later in afternoon)
      await settingsService.setPrayerMadhab(Madhab.hanafi);
      final hanafiTimes = service.getPrayerTimes(makkahPos, date: date)!;

      expect(
        hanafiTimes.asr.isAfter(shafiTimes.asr),
        isTrue,
        reason: 'Hanafi Asr must be later than Shafi Asr for the same location and date',
      );
    });

    test(
      'refreshPrayerTimesCache recomputes cached times with current settings',
      () async {
        service.setCachedPositionForTesting(makkahPos);

        await settingsService.setPrayerMadhab(Madhab.shafi);
        service.refreshPrayerTimesCache();
        final shafiAsr = service.cachedPrayerTimes!.asr;

        await settingsService.setPrayerMadhab(Madhab.hanafi);
        service.refreshPrayerTimesCache();
        final hanafiAsr = service.cachedPrayerTimes!.asr;

        expect(hanafiAsr.isAfter(shafiAsr), isTrue);
      },
    );

    test(
      'onPrayerCalculationSettingsChanged reschedules Adhan and reminders',
      () async {
        final mockAdhan = MockAdhanNotificationService();
        final mockScheduler = MockPrayerNotificationScheduler();

        when(() => mockAdhan.cancelAll()).thenAnswer((_) async {});
        when(
          () => mockAdhan.schedulePrayerNotifications(
            fajr: any(named: 'fajr'),
            dhuhr: any(named: 'dhuhr'),
            asr: any(named: 'asr'),
            maghrib: any(named: 'maghrib'),
            isha: any(named: 'isha'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => mockScheduler.rescheduleAll(
            prayerTimes: any(named: 'prayerTimes'),
            tomorrowPrayerTimes: any(named: 'tomorrowPrayerTimes'),
            locale: any(named: 'locale'),
            location: any(named: 'location'),
          ),
        ).thenAnswer((_) async {});

        GetIt.I.registerSingleton<AdhanNotificationService>(mockAdhan);
        GetIt.I.registerSingleton<PrayerNotificationScheduler>(mockScheduler);

        service.setCachedPositionForTesting(makkahPos);
        await settingsService.setAdhanNotificationsEnabled(true);
        await settingsService.setPrayerCalculationMethod(
          CalculationMethod.karachi,
        );

        await service.onPrayerCalculationSettingsChanged();

        verify(() => mockAdhan.cancelAll()).called(1);
        verify(
          () => mockAdhan.schedulePrayerNotifications(
            fajr: any(named: 'fajr'),
            dhuhr: any(named: 'dhuhr'),
            asr: any(named: 'asr'),
            maghrib: any(named: 'maghrib'),
            isha: any(named: 'isha'),
          ),
        ).called(1);
        verify(
          () => mockScheduler.rescheduleAll(
            prayerTimes: any(named: 'prayerTimes'),
            tomorrowPrayerTimes: any(named: 'tomorrowPrayerTimes'),
            locale: any(named: 'locale'),
          ),
        ).called(1);
      },
    );

    test('onPrayerCalculationSettingsChanged preserves Arabic locale when rescheduling reminders', () async {
      final mockAdhan = MockAdhanNotificationService();
      final mockScheduler = MockPrayerNotificationScheduler();

      when(() => mockAdhan.cancelAll()).thenAnswer((_) async {});
      when(
        () => mockScheduler.rescheduleAll(
          prayerTimes: any(named: 'prayerTimes'),
          tomorrowPrayerTimes: any(named: 'tomorrowPrayerTimes'),
          locale: any(named: 'locale'),
          location: any(named: 'location'),
        ),
      ).thenAnswer((_) async {});

      GetIt.I.registerSingleton<AdhanNotificationService>(mockAdhan);
      GetIt.I.registerSingleton<PrayerNotificationScheduler>(mockScheduler);

      service.setCachedPositionForTesting(makkahPos);
      await settingsService.setLocaleCode('ar');
      await settingsService.setPrayerCalculationMethod(
        CalculationMethod.ummAlQura,
      );

      await service.onPrayerCalculationSettingsChanged();

      verify(
        () => mockScheduler.rescheduleAll(
          prayerTimes: any(named: 'prayerTimes'),
          tomorrowPrayerTimes: any(named: 'tomorrowPrayerTimes'),
          locale: 'ar',
        ),
      ).called(1);
    });

    test('onPrayerCalculationSettingsChanged cancels Qaylulah and Adhans when no position is available', () async {
      final mockAdhan = MockAdhanNotificationService();
      final mockScheduler = MockPrayerNotificationScheduler();

      when(() => mockAdhan.cancelAll()).thenAnswer((_) async {});
      when(
        () => mockScheduler.rescheduleLocationIndependentReminders(
          now: any(named: 'now'),
          locale: any(named: 'locale'),
          location: any(named: 'location'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockScheduler.cancelQaylulah()).thenAnswer((_) async {});

      GetIt.I.registerSingleton<AdhanNotificationService>(mockAdhan);
      GetIt.I.registerSingleton<PrayerNotificationScheduler>(mockScheduler);

      // Ensure position is null
      service.setCachedPositionForTesting(null);
      await settingsService.setAdhanNotificationsEnabled(true);
      await settingsService.setLocaleCode('ar');

      await service.onPrayerCalculationSettingsChanged();

      verify(() => mockAdhan.cancelAll()).called(1);
      verify(
        () =>
            mockScheduler.rescheduleLocationIndependentReminders(locale: 'ar'),
      ).called(1);
      verify(() => mockScheduler.cancelQaylulah()).called(1);
      verifyNever(
        () => mockScheduler.rescheduleAll(
          prayerTimes: any(named: 'prayerTimes'),
          tomorrowPrayerTimes: any(named: 'tomorrowPrayerTimes'),
          locale: any(named: 'locale'),
          location: any(named: 'location'),
        ),
      );
    });

    test('onPrayerCalculationSettingsChanged schedules Arabic reminders with real scheduler', () async {
      final mockPlugin = MockNotificationPluginAdapter();
      when(() => mockPlugin.supported).thenReturn(true);
      when(() => mockPlugin.localTimezoneName).thenReturn('UTC');
      when(() => mockPlugin.updateLocalTimezone(any()))
          .thenAnswer((_) async {});
      when(
        () => mockPlugin.initialize(
          onNotificationTapped: any(named: 'onNotificationTapped'),
        ),
      ).thenAnswer((_) async {});
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

      final realScheduler = PrayerNotificationScheduler(
        settingsService: settingsService,
        plugin: mockPlugin,
      );
      GetIt.I.registerSingleton<PrayerNotificationScheduler>(realScheduler);

      service.setCachedPositionForTesting(makkahPos);
      await settingsService.setLocaleCode('ar');
      await settingsService.setMorningAdhkarNotificationEnabled(true);
      await settingsService.setPrayerCalculationMethod(
        CalculationMethod.karachi,
      );

      await service.onPrayerCalculationSettingsChanged();

      verify(
        () => mockPlugin.zonedSchedule(
          id: PrayerNotificationScheduler.idMorningAdhkar,
          title: 'أذكار الصباح',
          body: 'ابدأ يومك بذكر الله وحصّن يومك بالسكينة.',
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
          matchTimeOnly: true,
        ),
      ).called(1);
    });

    test('onPrayerCalculationSettingsChanged resolves system Arabic locale when app language preference is system', () async {
      final mockAdhan = MockAdhanNotificationService();
      final mockScheduler = MockPrayerNotificationScheduler();

      when(() => mockAdhan.cancelAll()).thenAnswer((_) async {});
      when(
        () => mockScheduler.rescheduleAll(
          prayerTimes: any(named: 'prayerTimes'),
          tomorrowPrayerTimes: any(named: 'tomorrowPrayerTimes'),
          locale: any(named: 'locale'),
          location: any(named: 'location'),
        ),
      ).thenAnswer((_) async {});

      GetIt.I.registerSingleton<AdhanNotificationService>(mockAdhan);
      GetIt.I.registerSingleton<PrayerNotificationScheduler>(mockScheduler);

      TestWidgetsFlutterBinding.instance.platformDispatcher.localeTestValue =
          const Locale('ar', 'SA');
      addTearDown(() {
        TestWidgetsFlutterBinding.instance.platformDispatcher
            .clearLocaleTestValue();
      });

      service.setCachedPositionForTesting(makkahPos);
      await settingsService.setLocaleCode('system');
      await settingsService.setPrayerCalculationMethod(
        CalculationMethod.ummAlQura,
      );

      await service.onPrayerCalculationSettingsChanged();

      verify(
        () => mockScheduler.rescheduleAll(
          prayerTimes: any(named: 'prayerTimes'),
          tomorrowPrayerTimes: any(named: 'tomorrowPrayerTimes'),
          locale: 'ar',
        ),
      ).called(1);
    });

    test('onPrayerCalculationSettingsChanged schedules Arabic reminders when app language is system on Arabic device with real scheduler', () async {
      final mockPlugin = MockNotificationPluginAdapter();
      when(() => mockPlugin.supported).thenReturn(true);
      when(() => mockPlugin.localTimezoneName).thenReturn('UTC');
      when(() => mockPlugin.updateLocalTimezone(any()))
          .thenAnswer((_) async {});
      when(
        () => mockPlugin.initialize(
          onNotificationTapped: any(named: 'onNotificationTapped'),
        ),
      ).thenAnswer((_) async {});
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

      final realScheduler = PrayerNotificationScheduler(
        settingsService: settingsService,
        plugin: mockPlugin,
      );
      GetIt.I.registerSingleton<PrayerNotificationScheduler>(realScheduler);

      TestWidgetsFlutterBinding.instance.platformDispatcher.localeTestValue =
          const Locale('ar');
      addTearDown(() {
        TestWidgetsFlutterBinding.instance.platformDispatcher
            .clearLocaleTestValue();
      });

      service.setCachedPositionForTesting(makkahPos);
      await settingsService.setLocaleCode('system');
      await settingsService.setMorningAdhkarNotificationEnabled(true);
      await settingsService.setPrayerCalculationMethod(
        CalculationMethod.karachi,
      );

      await service.onPrayerCalculationSettingsChanged();

      verify(
        () => mockPlugin.zonedSchedule(
          id: PrayerNotificationScheduler.idMorningAdhkar,
          title: 'أذكار الصباح',
          body: 'ابدأ يومك بذكر الله وحصّن يومك بالسكينة.',
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
          matchTimeOnly: true,
        ),
      ).called(1);
    });
  });
}
