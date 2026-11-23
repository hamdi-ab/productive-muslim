import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

tz.Location _safeLocalLocation() {
  try {
    return tz.local;
  } catch (_) {
    try {
      tz_data.initializeTimeZones();
      return tz.local;
    } catch (_) {
      return tz.UTC;
    }
  }
}

/// Adapter interface to decouple FlutterLocalNotificationsPlugin for testing.
abstract class NotificationPluginAdapter {
  bool get supported;
  String get localTimezoneName;
  Future<void> initialize({
    void Function(String payload)? onNotificationTapped,
  });
  Future<void> updateLocalTimezone([String? timeZoneName]);
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
  final MethodChannel _timezoneChannel;
  final void Function(String payload)? onNotificationTapped;
  bool _initialized = false;
  bool _launchChecked = false;

  LocalNotificationPluginAdapter({
    FlutterLocalNotificationsPlugin? plugin,
    MethodChannel timezoneChannel = const MethodChannel(
      'productive_muslim/timezone',
    ),
    this.onNotificationTapped,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _timezoneChannel = timezoneChannel;

  @override
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  String get localTimezoneName => _safeLocalLocation().name;

  @override
  Future<void> updateLocalTimezone([String? timeZoneName]) async {
    try {
      tz_data.initializeTimeZones();
    } catch (_) {}
    try {
      final zone =
          timeZoneName ??
          (supported
              ? await _timezoneChannel.invokeMethod<String>('getLocalTimezone')
              : null);
      if (zone != null) {
        tz.setLocalLocation(tz.getLocation(zone));
      }
    } catch (_) {}
  }

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
      await updateLocalTimezone();
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

    final loc = _safeLocalLocation();
    final tz.TZDateTime tzDate = scheduledDate is tz.TZDateTime
        ? scheduledDate
        : tz.TZDateTime.from(scheduledDate, loc);
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
    try {
      tz_data.initializeTimeZones();
    } catch (_) {}
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

  Future<void> updateTimezone([String? timeZoneName]) async {
    if (!_initialized) {
      await initialize();
    }
    await _plugin.updateLocalTimezone(timeZoneName);
  }

  tz.Location _resolveLocation(DateTime? referenceTime, tz.Location? location) {
    if (location != null) return location;
    if (referenceTime is tz.TZDateTime) return referenceTime.location;
    return _safeLocalLocation();
  }

  tz.TZDateTime calculateNextAdhkarOccurrence({
    required int hour,
    required int minute,
    DateTime? referenceTime,
    tz.Location? location,
  }) {
    final loc = _resolveLocation(referenceTime, location);
    final ref = referenceTime != null
        ? (referenceTime is tz.TZDateTime
              ? referenceTime
              : tz.TZDateTime.from(referenceTime, loc))
        : tz.TZDateTime.now(loc);

    var target = tz.TZDateTime(loc, ref.year, ref.month, ref.day, hour, minute);

    if (!target.isAfter(ref)) {
      final nextDay = ref.add(const Duration(days: 1));
      target = tz.TZDateTime(
        loc,
        nextDay.year,
        nextDay.month,
        nextDay.day,
        hour,
        minute,
      );
    }
    return target;
  }

  Future<void> rescheduleAdhkarReminders({
    DateTime? now,
    String? locale,
    tz.Location? location,
  }) async {
    if (!_initialized) {
      await initialize();
    } else {
      await _plugin.updateLocalTimezone();
    }

    final permitted = await hasPermission();
    if (!permitted) {
      await _plugin.cancel(idMorningAdhkar);
      await _plugin.cancel(idEveningAdhkar);
      return;
    }

    final isAr = (locale ?? 'en').toLowerCase().startsWith('ar');
    final globalEnabled = _settingsService.adhkarRemindersGlobalEnabled;

    // 1. Morning Adhkar Reminder (user-selected time, opt-in, gentle wording)
    if (globalEnabled && _settingsService.morningAdhkarNotificationEnabled) {
      final hour = _settingsService.morningAdhkarReminderHour;
      final minute = _settingsService.morningAdhkarReminderMinute;
      final morningTarget = calculateNextAdhkarOccurrence(
        hour: hour,
        minute: minute,
        referenceTime: now,
        location: location,
      );

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
      final eveningTarget = calculateNextAdhkarOccurrence(
        hour: hour,
        minute: minute,
        referenceTime: now,
        location: location,
      );

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

  /// Reschedules all reminders that do not depend on solar calculation or GPS location:
  /// - Morning Adhkar
  /// - Evening Adhkar
  /// - Bedtime Adhkar
  /// - Sunnah Fasting
  ///
  /// This can be called safely during app resume or timezone adjustments when
  /// location or prayer times are unavailable, without triggering location permission prompts.
  Future<void> rescheduleLocationIndependentReminders({
    DateTime? now,
    String? locale,
    tz.Location? location,
  }) async {
    if (!_initialized) {
      await initialize();
    } else {
      await _plugin.updateLocalTimezone();
    }

    final permitted = await hasPermission();
    if (!permitted) {
      await _plugin.cancel(idMorningAdhkar);
      await _plugin.cancel(idEveningAdhkar);
      await _plugin.cancel(idSleepingAdhkar);
      await _plugin.cancel(idSunnahFasting);
      return;
    }

    final currentTime = now ?? DateTime.now();
    final isAr = (locale ?? 'en').toLowerCase().startsWith('ar');

    // 1 & 2. Morning and Evening Adhkar Reminders
    await rescheduleAdhkarReminders(
      now: currentTime,
      locale: locale,
      location: location,
    );

    // 3. Bedtime Adhkar (configured hour/minute)
    if (_settingsService.sleepingAdhkarNotificationEnabled) {
      final hour = _settingsService.bedtimeReminderHour;
      final minute = _settingsService.bedtimeReminderMinute;
      final bedtimeTarget = calculateNextAdhkarOccurrence(
        hour: hour,
        minute: minute,
        referenceTime: currentTime,
        location: location,
      );

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
  }

  Future<void> rescheduleAll({
    DateTime? now,
    PrayerTimes? prayerTimes,
    PrayerTimes? tomorrowPrayerTimes,
    String? locale,
    tz.Location? location,
  }) async {
    final permitted = await hasPermission();
    if (!permitted) {
      await _plugin.cancel(idMorningAdhkar);
      await _plugin.cancel(idEveningAdhkar);
      await _plugin.cancel(idSleepingAdhkar);
      await _plugin.cancel(idSunnahFasting);
      await _plugin.cancel(idQaylulah);
      return;
    }

    await rescheduleLocationIndependentReminders(
      now: now,
      locale: locale,
      location: location,
    );

    final currentTime = now ?? DateTime.now();
    final isAr = (locale ?? 'en').toLowerCase().startsWith('ar');

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
