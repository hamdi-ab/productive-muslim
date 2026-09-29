import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Adapter interface to decouple FlutterLocalNotificationsPlugin for testing.
abstract class NotificationPluginAdapter {
  bool get supported;
  Future<void> initialize();
  Future<void> cancel(int id);
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
    required String channelId,
    required String channelName,
  });
}

class LocalNotificationPluginAdapter implements NotificationPluginAdapter {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  LocalNotificationPluginAdapter({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<void> initialize() async {
    if (!supported || _initialized) return;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_barakah_reminder'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    tz_data.initializeTimeZones();
    _initialized = true;
  }

  @override
  Future<void> cancel(int id) async {
    if (!supported) return;
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
    required String channelId,
    required String channelName,
  }) async {
    if (!supported) return;

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'Smart context reminders for Productive Muslim',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}

/// Central scheduler service responsible for solar-anchored adhkar and Sunnah notifications.
class PrayerNotificationScheduler {
  static const int idMorningAdhkar = 40001;
  static const int idEveningAdhkar = 40002;
  static const int idSleepingAdhkar = 40003;
  static const int idSunnahFasting = 40004;
  static const int idQaylulah = 40005;

  static const String channelAdhkar = 'adhkar_reminders_channel';
  static const String channelSunnah = 'sunnah_reminders_channel';

  final SettingsService _settingsService;
  final NotificationPluginAdapter _plugin;

  PrayerNotificationScheduler({
    required SettingsService settingsService,
    NotificationPluginAdapter? plugin,
  }) : _settingsService = settingsService,
       _plugin = plugin ?? LocalNotificationPluginAdapter();

  Future<void> initialize() async {
    await _plugin.initialize();
  }

  DateTime calculateNextFastingReminder({DateTime? now}) {
    final current = now ?? DateTime.now();
    // Reminder at 8:30 PM (20:30) on Sunday or Wednesday
    for (int dayOffset = 0; dayOffset <= 7; dayOffset++) {
      final candidateDate = current.add(Duration(days: dayOffset));
      final candidateTarget = DateTime(
        candidateDate.year,
        candidateDate.month,
        candidateDate.day,
        20,
        30,
      );

      final weekday = candidateTarget.weekday;
      if (weekday == DateTime.sunday || weekday == DateTime.wednesday) {
        if (candidateTarget.isAfter(current)) {
          return candidateTarget;
        }
      }
    }

    // Default fallback
    return current.add(const Duration(days: 1));
  }

  Future<void> rescheduleAll({DateTime? now, PrayerTimes? prayerTimes}) async {
    final currentTime = now ?? DateTime.now();

    // 1. Morning Adhkar (Fajr + 15 min or 6:00 AM fallback)
    if (_settingsService.morningAdhkarNotificationEnabled) {
      DateTime morningTarget;
      if (prayerTimes != null) {
        morningTarget = prayerTimes.fajr.add(const Duration(minutes: 15));
      } else {
        morningTarget = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          6,
          0,
        );
      }
      if (morningTarget.isBefore(currentTime)) {
        morningTarget = morningTarget.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: idMorningAdhkar,
        title: '🌅 Morning Adhkar • Light & Protection',
        body: 'Start your day with divine remembrance and barakah.',
        scheduledDate: morningTarget,
        payload: '/adhkar?category=morning',
        channelId: channelAdhkar,
        channelName: 'Daily Adhkar Reminders',
      );
    } else {
      await _plugin.cancel(idMorningAdhkar);
    }

    // 2. Evening Adhkar (Asr + 10 min or 5:00 PM fallback)
    if (_settingsService.eveningAdhkarNotificationEnabled) {
      DateTime eveningTarget;
      if (prayerTimes != null) {
        eveningTarget = prayerTimes.asr.add(const Duration(minutes: 10));
      } else {
        eveningTarget = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          17,
          0,
        );
      }
      if (eveningTarget.isBefore(currentTime)) {
        eveningTarget = eveningTarget.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: idEveningAdhkar,
        title: '🌆 Evening Adhkar • Evening Shield',
        body: 'Fortify your evening with authentic remembrance before sunset.',
        scheduledDate: eveningTarget,
        payload: '/adhkar?category=evening',
        channelId: channelAdhkar,
        channelName: 'Daily Adhkar Reminders',
      );
    } else {
      await _plugin.cancel(idEveningAdhkar);
    }

    // 3. Bedtime Adhkar (configured hour/minute)
    if (_settingsService.sleepingAdhkarNotificationEnabled) {
      final hour = _settingsService.bedtimeReminderHour;
      final minute = _settingsService.bedtimeReminderMinute;
      var bedtimeTarget = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        hour,
        minute,
      );
      if (bedtimeTarget.isBefore(currentTime)) {
        bedtimeTarget = bedtimeTarget.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: idSleepingAdhkar,
        title: '🌙 Bedtime Adhkar & Sunnah',
        body: 'Wind down with Ayat al-Kursi, Surat Al-Ikhlas, and bedtime supplication.',
        scheduledDate: bedtimeTarget,
        payload: '/adhkar?category=sleeping',
        channelId: channelAdhkar,
        channelName: 'Daily Adhkar Reminders',
      );
    } else {
      await _plugin.cancel(idSleepingAdhkar);
    }

    // 4. Sunnah Fasting (Sunday & Wednesday evenings)
    if (_settingsService.sunnahFastingNotificationEnabled) {
      final nextFasting = calculateNextFastingReminder(now: currentTime);
      final isSunday = nextFasting.weekday == DateTime.sunday;
      final targetFastDay = isSunday ? 'Monday' : 'Thursday';

      await _plugin.zonedSchedule(
        id: idSunnahFasting,
        title: '🥣 Sunnah Fasting Reminder',
        body:
            'Tomorrow is $targetFastDay. Set your intention tonight for immense Barakah.',
        scheduledDate: nextFasting,
        payload: '/energy',
        channelId: channelSunnah,
        channelName: 'Sunnah Routine Reminders',
      );
    } else {
      await _plugin.cancel(idSunnahFasting);
    }

    // 5. Sunnah Qaylulah (Dhuhr - 30 min)
    if (_settingsService.qaylulahNotificationEnabled) {
      DateTime qaylulahTarget;
      if (prayerTimes != null) {
        qaylulahTarget = prayerTimes.dhuhr.subtract(
          const Duration(minutes: 30),
        );
      } else {
        qaylulahTarget = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          12,
          30,
        );
      }
      if (qaylulahTarget.isBefore(currentTime)) {
        qaylulahTarget = qaylulahTarget.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: idQaylulah,
        title: '😴 Sunnah Qaylulah Nap',
        body: 'Recharge your physical and mental focus with a 20-min Sunnah power nap.',
        scheduledDate: qaylulahTarget,
        payload: '/energy',
        channelId: channelSunnah,
        channelName: 'Sunnah Routine Reminders',
      );
    } else {
      await _plugin.cancel(idQaylulah);
    }
  }
}
