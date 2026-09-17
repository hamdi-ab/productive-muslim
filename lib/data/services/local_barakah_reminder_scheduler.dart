import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:productive_muslim/domain/models/barakah_reminder.dart';
import 'package:productive_muslim/domain/repositories/barakah_reminder_scheduler.dart';

class LocalBarakahReminderScheduler implements BarakahReminderScheduler {
  LocalBarakahReminderScheduler({
    required this.onTapped,
    FlutterLocalNotificationsPlugin? plugin,
    MethodChannel timezoneChannel = const MethodChannel(
      'productive_muslim/timezone',
    ),
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _timezoneChannel = timezoneChannel;

  static const notificationId = 20001;
  static const payload = '/barakah';
  final VoidCallback onTapped;
  final FlutterLocalNotificationsPlugin _plugin;
  final MethodChannel _timezoneChannel;
  bool _initialized = false;
  bool _launchChecked = false;

  @override
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<void> initialize() async {
    if (!supported) return;
    if (!_initialized) {
      final initialized = await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_barakah_reminder'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: _handleResponse,
      );
      if (initialized != true) throw StateError('Notifications unavailable');
      tz_data.initializeTimeZones();
      _initialized = true;
    }
    if (!_launchChecked) {
      final details = await _plugin.getNotificationAppLaunchDetails();
      _launchChecked = true;
      if (details?.didNotificationLaunchApp == true) {
        final response = details?.notificationResponse;
        if (response != null) _handleResponse(response);
      }
    }
    final zone = await _timezoneChannel.invokeMethod<String>(
      'getLocalTimezone',
    );
    if (zone == null) throw StateError('Local timezone unavailable');
    tz.setLocalLocation(tz.getLocation(zone));
  }

  void _handleResponse(NotificationResponse response) {
    if (response.id == notificationId && response.payload == payload) {
      onTapped();
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (!supported) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    return await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, sound: true) ??
        false;
  }

  @override
  Future<bool> hasPermission() async {
    if (!supported) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          false;
    }
    final permissions = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.checkPermissions();
    return permissions?.isEnabled == true &&
        permissions?.isAlertEnabled == true;
  }

  @override
  Future<void> schedule(
    BarakahReminder reminder,
    ReminderContent content,
  ) async {
    if (!supported) return;
    await _plugin.zonedSchedule(
      id: notificationId,
      title: content.title,
      body: content.body,
      scheduledDate: nextLocalOccurrence(
        tz.TZDateTime.now(tz.local),
        reminder.hour,
        reminder.minute,
      ),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'barakah_daily',
          content.title,
          icon: 'ic_barakah_reminder',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  @override
  Future<void> cancel() async {
    if (!supported) return;
    await _plugin.cancel(id: notificationId);
  }
}

tz.TZDateTime nextLocalOccurrence(tz.TZDateTime now, int hour, int minute) {
  RangeError.checkValueInInterval(hour, 0, 23, 'hour');
  RangeError.checkValueInInterval(minute, 0, 59, 'minute');
  for (var day = 0; ; day++) {
    final candidate = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day + day,
      hour,
      minute,
    );
    if (candidate.hour == hour &&
        candidate.minute == minute &&
        candidate.isAfter(now)) {
      return candidate;
    }
  }
}
