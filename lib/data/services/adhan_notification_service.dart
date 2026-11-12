import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class AdhanNotificationService {
  AdhanNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    MethodChannel timezoneChannel = const MethodChannel(
      'productive_muslim/timezone',
    ),
    this.onNotificationTapped,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _timezoneChannel = timezoneChannel;

  static const _channelId = 'adhan_notifications';
  static const _channelName = 'Adhan Notifications';
  final int _notificationIdBase = 30000;

  final FlutterLocalNotificationsPlugin _plugin;
  final MethodChannel _timezoneChannel;
  final void Function(String payload)? onNotificationTapped;
  bool _initialized = false;

  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

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
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && onNotificationTapped != null) {
          onNotificationTapped!(payload);
        }
      },
    );

    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp == true) {
      final payload = details?.notificationResponse?.payload;
      if (payload != null && onNotificationTapped != null) {
        onNotificationTapped!(payload);
      }
    }

    tz_data.initializeTimeZones();
    final zone = await _timezoneChannel.invokeMethod<String>(
      'getLocalTimezone',
    );
    if (zone != null) {
      tz.setLocalLocation(tz.getLocation(zone));
    }

    _initialized = true;
  }

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

  Future<void> schedulePrayerNotifications({
    required DateTime fajr,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
  }) async {
    if (!supported) return;

    final prayers = [
      ('Fajr', fajr),
      ('Dhuhr', dhuhr),
      ('Asr', asr),
      ('Maghrib', maghrib),
      ('Isha', isha),
    ];

    for (var i = 0; i < prayers.length; i++) {
      final (name, time) = prayers[i];
      final id = _notificationIdBase + i;

      if (time.isBefore(DateTime.now())) continue;

      final tzDate = tz.TZDateTime.from(time, tz.local);

      await _plugin.zonedSchedule(
        id: id,
        title: 'Adhan - $name',
        body: 'It\'s time for $name prayer',
        scheduledDate: tzDate,
        payload: '/prayer-times',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            icon: 'ic_barakah_reminder',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelAll() async {
    if (!supported) return;
    for (var i = 0; i < 5; i++) {
      await _plugin.cancel(id: _notificationIdBase + i);
    }
  }
}
