import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Adapter interface to decouple FlutterLocalNotificationsPlugin for testing.
abstract class NotificationPluginAdapter {
  bool get supported;
  Future<void> initialize({
    void Function(String payload)? onNotificationTapped,
  });
  Future<bool> requestPermission();
  Future<bool> hasPermission();
  Future<void> cancel(int id);
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
    required String channelId,
    required String channelName,
    bool matchTimeOnly,
  });
}

class LocalNotificationPluginAdapter implements NotificationPluginAdapter {
  final FlutterLocalNotificationsPlugin _plugin;
  final void Function(String payload)? onNotificationTapped;
  bool _initialized = false;
  bool _launchChecked = false;

  LocalNotificationPluginAdapter({
    FlutterLocalNotificationsPlugin? plugin,
    this.onNotificationTapped,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<void> initialize({
    void Function(String payload)? onNotificationTapped,
  }) async {
    if (!supported) return;
    final callback = onNotificationTapped ?? this.onNotificationTapped;

    if (!_initialized) {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_barakah_reminder'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && callback != null) {
            callback(payload);
          }
        },
      );

      tz_data.initializeTimeZones();
      _initialized = true;
    }

    if (!_launchChecked) {
      _launchChecked = true;
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp == true) {
        final payload = details?.notificationResponse?.payload;
        if (payload != null && callback != null) {
          callback(payload);
        }
      }
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (!supported) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.requestNotificationsPermission() ?? false;
    }
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  @override
  Future<bool> hasPermission() async {
    if (!supported) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final perms = await iosPlugin?.checkPermissions();
    return perms?.isEnabled == true && perms?.isAlertEnabled == true;
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
    bool matchTimeOnly = false,
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: matchTimeOnly ? DateTimeComponents.time : null,
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
  bool _initialized = false;

  PrayerNotificationScheduler({
    required SettingsService settingsService,
    NotificationPluginAdapter? plugin,
  }) : _settingsService = settingsService,
       _plugin = plugin ?? LocalNotificationPluginAdapter();

  NotificationPluginAdapter get plugin => _plugin;

  Future<void> initialize({
    void Function(String payload)? onNotificationTapped,
  }) async {
    await _plugin.initialize(onNotificationTapped: onNotificationTapped);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    return await _plugin.requestPermission();
  }

  Future<bool> hasPermission() async {
    return await _plugin.hasPermission();
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

  Future<void> rescheduleAdhkarReminders({
    DateTime? now,
    String? locale,
  }) async {
    if (!_initialized) {
      await initialize();
    }
    final currentTime = now ?? DateTime.now();
    final isAr = (locale ?? 'en').toLowerCase().startsWith('ar');
    final globalEnabled = _settingsService.adhkarRemindersGlobalEnabled;

    // 1. Morning Adhkar Reminder (user-selected time, opt-in, gentle wording)
    if (globalEnabled && _settingsService.morningAdhkarNotificationEnabled) {
      final hour = _settingsService.morningAdhkarReminderHour;
      final minute = _settingsService.morningAdhkarReminderMinute;
      var morningTarget = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        hour,
        minute,
      );
      if (morningTarget.isBefore(currentTime)) {
        morningTarget = morningTarget.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: idMorningAdhkar,
        title: isAr ? 'أذكار الصباح' : 'Morning Adhkar',
        body: isAr
            ? 'ابدأ يومك بذكر الله وحصّن يومك بالسكينة.'
            : 'Start your day with peaceful remembrance.',
        scheduledDate: morningTarget,
        payload: '/adhkar?category=morning',
        channelId: channelAdhkar,
        channelName: isAr ? 'أذكار اليوم' : 'Daily Adhkar Reminders',
        matchTimeOnly: true,
      );
    } else {
      await _plugin.cancel(idMorningAdhkar);
    }

    // 2. Evening Adhkar Reminder (user-selected time, opt-in, gentle wording)
    if (globalEnabled && _settingsService.eveningAdhkarNotificationEnabled) {
      final hour = _settingsService.eveningAdhkarReminderHour;
      final minute = _settingsService.eveningAdhkarReminderMinute;
      var eveningTarget = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        hour,
        minute,
      );
      if (eveningTarget.isBefore(currentTime)) {
        eveningTarget = eveningTarget.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: idEveningAdhkar,
        title: isAr ? 'أذكار المساء' : 'Evening Adhkar',
        body: isAr
            ? 'اختم يومك بذكر الله والسكينة.'
            : 'Wind down your day with peaceful remembrance.',
        scheduledDate: eveningTarget,
        payload: '/adhkar?category=evening',
        channelId: channelAdhkar,
        channelName: isAr ? 'أذكار اليوم' : 'Daily Adhkar Reminders',
        matchTimeOnly: true,
      );
    } else {
      await _plugin.cancel(idEveningAdhkar);
    }
  }

  Future<void> rescheduleAll({
    DateTime? now,
    PrayerTimes? prayerTimes,
    PrayerTimes? tomorrowPrayerTimes,
    String? locale,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final currentTime = now ?? DateTime.now();
    final isAr = (locale ?? 'en').toLowerCase().startsWith('ar');

    // Morning and Evening Adhkar Reminders
    await rescheduleAdhkarReminders(now: currentTime, locale: locale);

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
        title: isAr
            ? '🌙 أذكار النوم وسنن ما قبل النوم'
            : '🌙 Bedtime Adhkar & Sunnah',
        body: isAr ? 'اختم يومك بآية الكرسي والمعوذات ودعاء النوم المأثور.' : 'Wind down with Ayat al-Kursi, Surat Al-Ikhlas, and bedtime supplication.',
        scheduledDate: bedtimeTarget,
        payload: '/adhkar?category=sleeping',
        channelId: channelAdhkar,
        channelName: isAr ? 'أذكار اليوم' : 'Daily Adhkar Reminders',
        matchTimeOnly: true,
      );
    } else {
      await _plugin.cancel(idSleepingAdhkar);
    }

    // 4. Sunnah Fasting (Sunday & Wednesday evenings)
    if (_settingsService.sunnahFastingNotificationEnabled) {
      final nextFasting = calculateNextFastingReminder(now: currentTime);
      final isSunday = nextFasting.weekday == DateTime.sunday;
      final targetFastDayEn = isSunday ? 'Monday' : 'Thursday';
      final targetFastDayAr = isSunday ? 'الإثنين' : 'الخميس';

      await _plugin.zonedSchedule(
        id: idSunnahFasting,
        title: isAr ? '🥣 تذكير صيام السنة' : '🥣 Sunnah Fasting Reminder',
        body: isAr
            ? 'غداً هو يوم $targetFastDayAr. اعقد النية الليلة لنيل الأجر والبركة.'
            : 'Tomorrow is $targetFastDayEn. Set your intention tonight for immense Barakah.',
        scheduledDate: nextFasting,
        payload: '/energy',
        channelId: channelSunnah,
        channelName: isAr ? 'سنن يومية' : 'Sunnah Routine Reminders',
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
        if (tomorrowPrayerTimes != null) {
          qaylulahTarget = tomorrowPrayerTimes.dhuhr.subtract(
            const Duration(minutes: 30),
          );
        } else {
          qaylulahTarget = qaylulahTarget.add(const Duration(days: 1));
        }
      }

      await _plugin.zonedSchedule(
        id: idQaylulah,
        title: isAr ? '😴 سنة القيلولة' : '😴 Sunnah Qaylulah Nap',
        body: isAr ? 'جدد نشاطك البدني والذهني بقيلولة السنة القصيرة.' : 'Recharge your physical and mental focus with a 20-min Sunnah power nap.',
        scheduledDate: qaylulahTarget,
        payload: '/energy',
        channelId: channelSunnah,
        channelName: isAr ? 'سنن يومية' : 'Sunnah Routine Reminders',
      );
    } else {
      await _plugin.cancel(idQaylulah);
    }
  }
}
