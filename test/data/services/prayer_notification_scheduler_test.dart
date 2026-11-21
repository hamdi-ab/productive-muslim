import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/data/services/prayer_notification_scheduler.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class MockNotificationPlugin extends Mock
    implements NotificationPluginAdapter {}

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
  });

  group('PrayerNotificationScheduler', () {
    test(
      'schedules morning, evening, bedtime, and fasting when enabled (English)',
      () async {
        await settingsService.setMorningAdhkarNotificationEnabled(true);
        await settingsService.setEveningAdhkarNotificationEnabled(true);

        final now = DateTime(2026, 9, 29, 5, 0); // 5:00 AM on a Tuesday
        final coordinates = Coordinates(21.4225, 39.8262);
        final params = CalculationMethodParameters.muslimWorldLeague();
        final prayerTimes = PrayerTimes(
          date: now,
          coordinates: coordinates,
          calculationParameters: params,
        );

        await scheduler.rescheduleAll(
          now: now,
          prayerTimes: prayerTimes,
          locale: 'en',
        );

        // Verify Morning Adhkar scheduled with gentle English copy
        verify(
          () => mockPlugin.zonedSchedule(
            id: PrayerNotificationScheduler.idMorningAdhkar,
            title: 'Morning Adhkar',
            body: 'Start your day with peaceful remembrance.',
            scheduledDate: any(
              named: 'scheduledDate',
              that: predicate<DateTime>((d) => d.hour == 7 && d.minute == 0),
            ),
            payload: '/adhkar?category=morning',
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            matchTimeOnly: true,
          ),
        ).called(1);

        // Verify Evening Adhkar scheduled with gentle English copy
        verify(
          () => mockPlugin.zonedSchedule(
            id: PrayerNotificationScheduler.idEveningAdhkar,
            title: 'Evening Adhkar',
            body: 'Wind down your day with peaceful remembrance.',
            scheduledDate: any(
              named: 'scheduledDate',
              that: predicate<DateTime>((d) => d.hour == 18 && d.minute == 0),
            ),
            payload: '/adhkar?category=evening',
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            matchTimeOnly: true,
          ),
        ).called(1);

        // Verify Bedtime Adhkar scheduled with English copy
        verify(
          () => mockPlugin.zonedSchedule(
            id: PrayerNotificationScheduler.idSleepingAdhkar,
            title: '🌙 Bedtime Adhkar & Sunnah',
            body: 'Wind down with Ayat al-Kursi, Surat Al-Ikhlas, and bedtime supplication.',
            scheduledDate: any(named: 'scheduledDate'),
            payload: '/adhkar?category=sleeping',
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            matchTimeOnly: true,
          ),
        ).called(1);
      },
    );

    test('schedules notifications in Arabic when locale is ar', () async {
      await settingsService.setMorningAdhkarNotificationEnabled(true);
      await settingsService.setEveningAdhkarNotificationEnabled(true);

      final now = DateTime(2026, 9, 29, 5, 0);
      final coordinates = Coordinates(21.4225, 39.8262);
      final params = CalculationMethodParameters.muslimWorldLeague();
      final prayerTimes = PrayerTimes(
        date: now,
        coordinates: coordinates,
        calculationParameters: params,
      );

      await scheduler.rescheduleAll(
        now: now,
        prayerTimes: prayerTimes,
        locale: 'ar',
      );

      verify(
        () => mockPlugin.zonedSchedule(
          id: PrayerNotificationScheduler.idMorningAdhkar,
          title: 'أذكار الصباح',
          body: 'ابدأ يومك بذكر الله وحصّن يومك بالسكينة.',
          scheduledDate: any(named: 'scheduledDate'),
          payload: '/adhkar?category=morning',
          channelId: any(named: 'channelId'),
          channelName: 'أذكار اليوم',
          matchTimeOnly: true,
        ),
      ).called(1);

      verify(
        () => mockPlugin.zonedSchedule(
          id: PrayerNotificationScheduler.idEveningAdhkar,
          title: 'أذكار المساء',
          body: 'اختم يومك بذكر الله والسكينة.',
          scheduledDate: any(named: 'scheduledDate'),
          payload: '/adhkar?category=evening',
          channelId: any(named: 'channelId'),
          channelName: 'أذكار اليوم',
          matchTimeOnly: true,
        ),
      ).called(1);
    });

    test(
      'recalculates tomorrow morning reminder when today time has passed',
      () async {
        await settingsService.setMorningAdhkarNotificationEnabled(true);
        final now = DateTime(
          2026,
          9,
          29,
          14,
          0,
        ); // 2:00 PM (7:00 AM has passed)
        final tomorrow = now.add(const Duration(days: 1));
        final coordinates = Coordinates(21.4225, 39.8262);
        final params = CalculationMethodParameters.muslimWorldLeague();
        final prayerTimesToday = PrayerTimes(
          date: now,
          coordinates: coordinates,
          calculationParameters: params,
        );
        final prayerTimesTomorrow = PrayerTimes(
          date: tomorrow,
          coordinates: coordinates,
          calculationParameters: params,
        );

        await scheduler.rescheduleAll(
          now: now,
          prayerTimes: prayerTimesToday,
          tomorrowPrayerTimes: prayerTimesTomorrow,
        );

        verify(
          () => mockPlugin.zonedSchedule(
            id: PrayerNotificationScheduler.idMorningAdhkar,
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(
              named: 'scheduledDate',
              that: predicate<DateTime>(
                (d) => d.day == 30 && d.hour == 7 && d.minute == 0,
              ),
            ),
            payload: '/adhkar?category=morning',
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            matchTimeOnly: true,
          ),
        ).called(1);
      },
    );

    test('cancels notifications when disabled in settings', () async {
      await settingsService.setMorningAdhkarNotificationEnabled(false);
      await settingsService.setEveningAdhkarNotificationEnabled(false);
      await settingsService.setSleepingAdhkarNotificationEnabled(false);
      await settingsService.setSunnahFastingNotificationEnabled(false);

      final now = DateTime(2026, 9, 29, 5, 0);
      await scheduler.rescheduleAll(now: now);

      verify(
        () => mockPlugin.cancel(PrayerNotificationScheduler.idMorningAdhkar),
      ).called(1);
      verify(
        () => mockPlugin.cancel(PrayerNotificationScheduler.idEveningAdhkar),
      ).called(1);
      verify(
        () => mockPlugin.cancel(PrayerNotificationScheduler.idSleepingAdhkar),
      ).called(1);
      verify(
        () => mockPlugin.cancel(PrayerNotificationScheduler.idSunnahFasting),
      ).called(1);
    });

    test('calculates next Sunnah Fasting reminder on Sunday and Wednesday evenings', () {
      // Tuesday 10 AM -> Next is Wednesday 8:30 PM (for Thursday fast)
      final tuesday = DateTime(2026, 9, 29, 10, 0);
      final nextFastingReminder = scheduler.calculateNextFastingReminder(
        now: tuesday,
      );

      expect(nextFastingReminder.weekday, equals(DateTime.wednesday));
      expect(nextFastingReminder.hour, equals(20));
      expect(nextFastingReminder.minute, equals(30));

      // Thursday 10 AM -> Next is Sunday 8:30 PM (for Monday fast)
      final thursday = DateTime(2026, 10, 1, 10, 0);
      final sundayReminder = scheduler.calculateNextFastingReminder(
        now: thursday,
      );

      expect(sundayReminder.weekday, equals(DateTime.sunday));
      expect(sundayReminder.hour, equals(20));
      expect(sundayReminder.minute, equals(30));
    });

    test('permission checking and requesting delegates to plugin', () async {
      expect(await scheduler.hasPermission(), isTrue);
      expect(await scheduler.requestPermission(), isTrue);
      verify(() => mockPlugin.hasPermission()).called(1);
      verify(() => mockPlugin.requestPermission()).called(1);
    });

    test('calculateNextAdhkarOccurrence preserves wall-clock time in non-UTC timezone', () {
      final loc = tz.getLocation('Asia/Riyadh');
      // 5:00 AM in Riyadh -> next 7:00 AM is today
      final refBefore = tz.TZDateTime(loc, 2026, 9, 29, 5, 0);
      final occurrence = scheduler.calculateNextAdhkarOccurrence(
        hour: 7,
        minute: 0,
        referenceTime: refBefore,
        location: loc,
      );

      expect(occurrence.year, equals(2026));
      expect(occurrence.month, equals(9));
      expect(occurrence.day, equals(29));
      expect(occurrence.hour, equals(7));
      expect(occurrence.minute, equals(0));
      expect(occurrence.location.name, equals('Asia/Riyadh'));

      // 8:00 AM in Riyadh (7:00 AM has passed) -> next 7:00 AM is tomorrow
      final refAfter = tz.TZDateTime(loc, 2026, 9, 29, 8, 0);
      final nextOccurrence = scheduler.calculateNextAdhkarOccurrence(
        hour: 7,
        minute: 0,
        referenceTime: refAfter,
        location: loc,
      );

      expect(nextOccurrence.year, equals(2026));
      expect(nextOccurrence.month, equals(9));
      expect(nextOccurrence.day, equals(30));
      expect(nextOccurrence.hour, equals(7));
      expect(nextOccurrence.minute, equals(0));
      expect(nextOccurrence.location.name, equals('Asia/Riyadh'));
    });

    test('timezone change recalculates occurrences aligned to new wall-clock local time', () {
      final nyLoc = tz.getLocation('America/New_York');
      final riyadhLoc = tz.getLocation('Asia/Riyadh');

      // New York 5:00 AM -> occurrence at 7:00 AM New York wall-clock
      final nyTime = tz.TZDateTime(nyLoc, 2026, 9, 29, 5, 0);
      final nyOccurrence = scheduler.calculateNextAdhkarOccurrence(
        hour: 7,
        minute: 0,
        referenceTime: nyTime,
        location: nyLoc,
      );
      expect(nyOccurrence.hour, equals(7));
      expect(nyOccurrence.minute, equals(0));
      expect(nyOccurrence.location.name, equals('America/New_York'));

      // Device changes timezone to Riyadh -> occurrence at 7:00 AM Riyadh wall-clock
      final riyadhTime = tz.TZDateTime(riyadhLoc, 2026, 9, 29, 5, 0);
      final riyadhOccurrence = scheduler.calculateNextAdhkarOccurrence(
        hour: 7,
        minute: 0,
        referenceTime: riyadhTime,
        location: riyadhLoc,
      );
      expect(riyadhOccurrence.hour, equals(7));
      expect(riyadhOccurrence.minute, equals(0));
      expect(riyadhOccurrence.location.name, equals('Asia/Riyadh'));
    });

    test('LocalNotificationPluginAdapter updates local timezone from native channel', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('productive_muslim/timezone'),
            (methodCall) async {
              if (methodCall.method == 'getLocalTimezone') {
                return 'Asia/Riyadh';
              }
              return null;
            },
          );

      final adapter = LocalNotificationPluginAdapter();
      await adapter.updateLocalTimezone();

      expect(adapter.localTimezoneName, equals('Asia/Riyadh'));
      expect(tz.local.name, equals('Asia/Riyadh'));
    });
  });
}
