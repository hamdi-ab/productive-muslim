import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/data/services/prayer_notification_scheduler.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNotificationPlugin extends Mock
    implements NotificationPluginAdapter {}

void main() {
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
    test('schedules morning, evening, bedtime, and fasting when enabled (English)', () async {
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

      // Verify Morning Adhkar scheduled with English copy
      verify(
        () => mockPlugin.zonedSchedule(
          id: PrayerNotificationScheduler.idMorningAdhkar,
          title: '🌅 Morning Adhkar • Light & Protection',
          body: 'Start your day with divine remembrance and barakah.',
          scheduledDate: any(named: 'scheduledDate'),
          payload: '/adhkar?category=morning',
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
          matchTimeOnly: any(named: 'matchTimeOnly'),
        ),
      ).called(1);

      // Verify Evening Adhkar scheduled with English copy
      verify(
        () => mockPlugin.zonedSchedule(
          id: PrayerNotificationScheduler.idEveningAdhkar,
          title: '🌆 Evening Adhkar • Evening Shield',
          body:
              'Fortify your evening with authentic remembrance before sunset.',
          scheduledDate: any(named: 'scheduledDate'),
          payload: '/adhkar?category=evening',
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
          matchTimeOnly: any(named: 'matchTimeOnly'),
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
    });

    test('schedules notifications in Arabic when locale is ar', () async {
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
          title: '🌅 أذكار الصباح • نور وحفظ',
          body: 'ابدأ يومك بذكر الله وحصن نفسك بالبركة.',
          scheduledDate: any(named: 'scheduledDate'),
          payload: '/adhkar?category=morning',
          channelId: any(named: 'channelId'),
          channelName: 'أذكار اليوم',
          matchTimeOnly: any(named: 'matchTimeOnly'),
        ),
      ).called(1);

      verify(
        () => mockPlugin.zonedSchedule(
          id: PrayerNotificationScheduler.idEveningAdhkar,
          title: '🌆 أذكار المساء • حصن المسلم',
          body: 'حصّن مسائك بالأذكار المأثورة قبل غروب الشمس.',
          scheduledDate: any(named: 'scheduledDate'),
          payload: '/adhkar?category=evening',
          channelId: any(named: 'channelId'),
          channelName: 'أذكار اليوم',
          matchTimeOnly: any(named: 'matchTimeOnly'),
        ),
      ).called(1);
    });

    test(
      'recalculates tomorrow prayer times when today prayer has passed',
      () async {
        final now = DateTime(2026, 9, 29, 14, 0); // 2:00 PM (Fajr has passed)
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

        final expectedTomorrowFajr = prayerTimesTomorrow.fajr.add(
          const Duration(minutes: 15),
        );

        verify(
          () => mockPlugin.zonedSchedule(
            id: PrayerNotificationScheduler.idMorningAdhkar,
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: expectedTomorrowFajr,
            payload: '/adhkar?category=morning',
            channelId: any(named: 'channelId'),
            channelName: any(named: 'channelName'),
            matchTimeOnly: any(named: 'matchTimeOnly'),
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
  });
}
