import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/barakah_reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_reminder_scheduler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SettingsService settings;
  late FakeReminderScheduler scheduler;
  late BarakahReminderService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = SettingsService(prefs: await SharedPreferences.getInstance());
    scheduler = FakeReminderScheduler();
    service = BarakahReminderService(settings: settings, scheduler: scheduler);
  });
  tearDown(() => service.dispose());

  test(
    'initialization never requests permission and cancels when opted out',
    () async {
      await service.reconcile(reminderContent);
      expect(scheduler.calls, ['initialize', 'cancel']);
      expect(settings.barakahReminder.enabled, isFalse);
    },
  );

  test(
    'explicit enable requests permission then schedules and persists',
    () async {
      await service.setEnabled(true, reminderContent);
      expect(scheduler.calls, ['initialize', 'request', 'schedule']);
      expect(settings.barakahReminder, (enabled: true, hour: 20, minute: 0));
      expect(service.status.reminder.enabled, isTrue);
      expect(service.status.pending, isFalse);
      expect(scheduler.contents.single, reminderContent);
    },
  );

  test('denial cancels and never persists enabled', () async {
    scheduler.permitted = false;
    await service.setEnabled(true, reminderContent);
    expect(scheduler.calls, ['initialize', 'request', 'cancel']);
    expect(service.status.failure, ReminderFailure.permissionDenied);
    expect(settings.barakahReminder.enabled, isFalse);
  });

  test(
    'disable retains selected time and does not initialize or ask permission',
    () async {
      await service.setTime(8, 15, reminderContent);
      await service.setEnabled(true, reminderContent);
      scheduler.calls.clear();
      await service.setEnabled(false, reminderContent);
      expect(scheduler.calls, ['cancel']);
      expect(settings.barakahReminder, (enabled: false, hour: 8, minute: 15));
    },
  );

  test(
    'time changes replace enabled schedule without requesting permission',
    () async {
      await service.setEnabled(true, reminderContent);
      scheduler.calls.clear();
      await service.setTime(21, 30, reminderContent);
      expect(scheduler.calls, ['initialize', 'check', 'schedule']);
      expect(settings.barakahReminder, (enabled: true, hour: 21, minute: 30));
      expect(scheduler.reminders.last.hour, 21);
      expect(scheduler.reminders.last.minute, 30);
    },
  );

  test(
    'time changes while disabled do not schedule or ask permission',
    () async {
      await service.setTime(6, 45, reminderContent);
      expect(scheduler.calls, ['initialize', 'cancel']);
      expect(settings.barakahReminder, (enabled: false, hour: 6, minute: 45));
    },
  );

  test('saved enabled reminder reconciles and refreshes on each resume without prompting', () async {
    await settings.setBarakahReminder(enabled: true, hour: 19, minute: 5);
    await service.dispose();
    service = BarakahReminderService(settings: settings, scheduler: scheduler);
    await service.reconcile(reminderContent);
    await service.reconcile(reminderContent);
    expect(scheduler.calls, [
      'initialize',
      'check',
      'schedule',
      'initialize',
      'check',
      'schedule',
    ]);
    expect(scheduler.reminders.last.hour, 19);
    scheduler.permitted = false;
    await service.reconcile(reminderContent);
    expect(service.status.failure, ReminderFailure.permissionDenied);
    expect(settings.barakahReminder.enabled, isFalse);
    expect(scheduler.calls, isNot(contains('request')));
  });

  for (final failure in ['initialize', 'schedule', 'cancel']) {
    test(
      '$failure errors are contained and leave no persisted enabled state',
      () async {
        await service.setEnabled(true, reminderContent);
        scheduler.initializationFailed = failure == 'initialize';
        scheduler.scheduleFailed = failure == 'schedule';
        scheduler.cancellationFailed = failure == 'cancel';
        if (failure == 'cancel') {
          await service.setEnabled(false, reminderContent);
        } else {
          await service.setTime(9, 30, reminderContent);
        }
        expect(service.status.failure, ReminderFailure.operationFailed);
        expect(service.status.pending, isFalse);
        expect(service.status.reminder.enabled, isFalse);
        expect(settings.barakahReminder, (enabled: false, hour: 20, minute: 0));
      },
    );
  }

  test('initialization failure never escapes launch reconciliation', () async {
    scheduler.initializationFailed = true;
    await service.reconcile(reminderContent);
    expect(service.status.failure, ReminderFailure.operationFailed);
    scheduler.initializationFailed = false;
    await service.setEnabled(true, reminderContent);
    expect(service.status.reminder.enabled, isTrue);
  });

  test('unsupported platforms make zero scheduler calls', () async {
    scheduler.supported = false;
    await service.dispose();
    service = BarakahReminderService(settings: settings, scheduler: scheduler);
    await service.reconcile(reminderContent);
    await service.setEnabled(true, reminderContent);
    await service.setTime(8, 30, reminderContent);
    await service.setEnabled(false, reminderContent);
    expect(scheduler.calls, isEmpty);
    expect(service.status.supported, isFalse);
    expect(service.status.failure, ReminderFailure.unavailable);
    expect(settings.barakahReminder, (enabled: false, hour: 20, minute: 0));
  });

  test('enable, time change, resume and disable are serialized', () async {
    scheduler.permissionResult = Completer<bool>();
    final enabled = service.setEnabled(true, reminderContent);
    await Future<void>.delayed(Duration.zero);
    final time = service.setTime(22, 10, reminderContent);
    final resume = service.reconcile(reminderContent);
    final disabled = service.setEnabled(false, reminderContent);
    expect(service.status.pending, isTrue);
    expect(settings.barakahReminder.enabled, isFalse);
    expect(scheduler.calls, ['initialize', 'request']);
    scheduler.permissionResult!.complete(true);
    await Future.wait([enabled, time, resume, disabled]);
    expect(scheduler.calls, [
      'initialize',
      'request',
      'schedule',
      'initialize',
      'check',
      'schedule',
      'initialize',
      'check',
      'schedule',
      'cancel',
    ]);
    expect(settings.barakahReminder, (enabled: false, hour: 22, minute: 10));
  });

  test(
    'persistence failure is surfaced and scheduling is not attempted',
    () async {
      await service.dispose();
      service = BarakahReminderService(
        settings: SettingsService.empty(),
        scheduler: scheduler,
      );
      await service.setEnabled(true, reminderContent);
      expect(service.status.failure, ReminderFailure.operationFailed);
      expect(service.status.reminder.enabled, isFalse);
      expect(scheduler.calls, ['initialize', 'cancel']);
    },
  );
}
