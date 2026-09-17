import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/local_barakah_reminder_scheduler.dart';
import 'package:productive_muslim/domain/models/barakah_reminder.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../helpers/fake_reminder_scheduler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const notifications = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  const timezone = MethodChannel('productive_muslim/timezone');
  final calls = <MethodCall>[];
  var zone = 'America/New_York';
  var taps = 0;
  var coldLaunch = false;
  var permission = true;
  late LocalBarakahReminderScheduler scheduler;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();
    zone = 'America/New_York';
    taps = 0;
    coldLaunch = false;
    permission = true;
    scheduler = LocalBarakahReminderScheduler(onTapped: () => taps++);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezone, (call) async {
          calls.add(call);
          return zone;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notifications, (call) async {
          calls.add(call);
          return switch (call.method) {
            'initialize' => true,
            'getNotificationAppLaunchDetails' => {
              'notificationLaunchedApp': coldLaunch,
              'notificationResponse': {
                'notificationId': LocalBarakahReminderScheduler.notificationId,
                'payload': '/barakah',
                'notificationResponseType': 0,
              },
            },
            'requestNotificationsPermission' ||
            'areNotificationsEnabled' ||
            'requestPermissions' => permission,
            'checkPermissions' => {
              'isEnabled': permission,
              'isAlertEnabled': permission,
            },
            _ => null,
          };
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notifications, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezone, null);
  });

  test('Android uses named API, stable ID, daily inexact local schedule and targeted cancellation', () async {
    await scheduler.initialize();
    expect(
      calls.map((c) => c.method),
      isNot(contains('requestNotificationsPermission')),
    );
    expect(await scheduler.requestPermission(), isTrue);
    await scheduler.schedule(
      const BarakahReminder(enabled: true),
      reminderContent,
    );
    final arguments =
        calls.singleWhere((c) => c.method == 'zonedSchedule').arguments as Map;
    expect(arguments['id'], LocalBarakahReminderScheduler.notificationId);
    expect(arguments['payload'], '/barakah');
    expect(arguments['timeZoneName'], 'America/New_York');
    expect(arguments['matchDateTimeComponents'], DateTimeComponents.time.index);
    expect(
      (arguments['platformSpecifics'] as Map)['scheduleMode'],
      'inexactAllowWhileIdle',
    );
    await scheduler.cancel();
    expect(calls.last.method, 'cancel');
    expect(
      calls.last.arguments['id'],
      LocalBarakahReminderScheduler.notificationId,
    );
    expect(calls.map((c) => c.method), isNot(contains('cancelAll')));
  });

  test(
    'reinitialization refreshes timezone without reinitializing plugin',
    () async {
      await scheduler.initialize();
      zone = 'Asia/Riyadh';
      await scheduler.initialize();
      expect(tz.local.name, 'Asia/Riyadh');
      expect(calls.where((c) => c.method == 'initialize'), hasLength(1));
      expect(calls.where((c) => c.method == 'getLocalTimezone'), hasLength(2));
    },
  );

  test(
    'timezone discovery errors fail rather than silently using UTC',
    () async {
      zone = 'Not/AZone';
      await expectLater(
        scheduler.initialize(),
        throwsA(isA<tz.LocationNotFoundException>()),
      );
      zone = 'Asia/Riyadh';
      await scheduler.initialize();
      expect(tz.local.name, 'Asia/Riyadh');
    },
  );

  test(
    'iOS initialization does not request permissions and checks are silent',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      IOSFlutterLocalNotificationsPlugin.registerWith();
      await scheduler.initialize();
      final arguments = calls.first.arguments as Map;
      expect(arguments['requestAlertPermission'], isFalse);
      expect(arguments['requestSoundPermission'], isFalse);
      expect(arguments['requestBadgePermission'], isFalse);
      expect(await scheduler.hasPermission(), isTrue);
      expect(calls.map((c) => c.method), isNot(contains('requestPermissions')));
      expect(await scheduler.requestPermission(), isTrue);
      expect(calls.last.arguments['alert'], isTrue);
      expect(calls.last.arguments['sound'], isTrue);
      permission = false;
      expect(await scheduler.hasPermission(), isFalse);
    },
  );

  test('cold notification launch routes once', () async {
    coldLaunch = true;
    await scheduler.initialize();
    await scheduler.initialize();
    expect(taps, 1);
  });

  test('warm tap only routes matching reminder ID and payload', () async {
    await scheduler.initialize();
    Future<void> tap(int id, String payload) async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            notifications.name,
            const StandardMethodCodec().encodeMethodCall(
              MethodCall('didReceiveNotificationResponse', {
                'notificationId': id,
                'payload': payload,
                'notificationResponseType': 0,
              }),
            ),
            (_) {},
          );
    }

    await tap(99, '/barakah');
    await tap(LocalBarakahReminderScheduler.notificationId, '/other');
    expect(taps, 0);
    await tap(LocalBarakahReminderScheduler.notificationId, '/barakah');
    expect(taps, 1);
  });

  for (final platform in [
    TargetPlatform.linux,
    TargetPlatform.macOS,
    TargetPlatform.windows,
  ]) {
    test('$platform performs no plugin or timezone calls', () async {
      debugDefaultTargetPlatformOverride = platform;
      expect(scheduler.supported, isFalse);
      await scheduler.initialize();
      expect(await scheduler.requestPermission(), isFalse);
      expect(await scheduler.hasPermission(), isFalse);
      await scheduler.schedule(const BarakahReminder(), reminderContent);
      await scheduler.cancel();
      expect(calls, isEmpty);
    });
  }

  group('next local occurrence', () {
    setUp(tz_data.initializeTimeZones);

    test('before, at, and after chosen time', () {
      final location = tz.getLocation('Asia/Riyadh');
      expect(
        nextLocalOccurrence(tz.TZDateTime(location, 2026, 9, 17, 19), 20, 0),
        tz.TZDateTime(location, 2026, 9, 17, 20),
      );
      for (final hour in [20, 21]) {
        expect(
          nextLocalOccurrence(
            tz.TZDateTime(location, 2026, 9, 17, hour),
            20,
            0,
          ),
          tz.TZDateTime(location, 2026, 9, 18, 20),
        );
      }
    });

    test(
      'spring transition preserves wall clock instead of adding 24 hours',
      () {
        final location = tz.getLocation('America/New_York');
        final now = tz.TZDateTime(location, 2026, 3, 7, 20);
        final next = nextLocalOccurrence(now, 20, 0);
        expect(next, tz.TZDateTime(location, 2026, 3, 8, 20));
        expect(next.difference(now).inHours, 23);
      },
    );

    test('fall transition preserves wall clock instead of adding 24 hours', () {
      final location = tz.getLocation('America/New_York');
      final now = tz.TZDateTime(location, 2026, 10, 31, 20);
      final next = nextLocalOccurrence(now, 20, 0);
      expect(next, tz.TZDateTime(location, 2026, 11, 1, 20));
      expect(next.difference(now).inHours, 25);
    });

    test(
      'nonexistent spring time is skipped without changing daily selected time',
      () {
        final location = tz.getLocation('America/New_York');
        final now = tz.TZDateTime(location, 2026, 3, 8, 0);
        expect(
          nextLocalOccurrence(now, 2, 30),
          tz.TZDateTime(location, 2026, 3, 9, 2, 30),
        );
      },
    );

    test('ambiguous fall time chooses first occurrence and avoids a second reminder', () {
      final location = tz.getLocation('America/New_York');
      final first = nextLocalOccurrence(
        tz.TZDateTime(location, 2026, 11, 1),
        1,
        30,
      );
      expect(first.hour, 1);
      expect(first.minute, 30);
      final next = nextLocalOccurrence(first, 1, 30);
      expect(next.day, 2);
    });

    test('year boundary advances calendar date', () {
      final location = tz.getLocation('Asia/Riyadh');
      expect(
        nextLocalOccurrence(tz.TZDateTime(location, 2026, 12, 31, 23), 20, 0),
        tz.TZDateTime(location, 2027, 1, 1, 20),
      );
    });
  });
}
