import 'dart:async';

import 'package:productive_muslim/domain/models/barakah_reminder.dart';
import 'package:productive_muslim/domain/repositories/barakah_reminder_scheduler.dart';

class FakeReminderScheduler implements BarakahReminderScheduler {
  @override
  bool supported = true;
  bool permitted = true;
  bool initializationFailed = false;
  bool scheduleFailed = false;
  bool cancellationFailed = false;
  Completer<bool>? permissionResult;
  final calls = <String>[];
  final reminders = <BarakahReminder>[];
  final contents = <ReminderContent>[];

  @override
  Future<void> initialize() async {
    calls.add('initialize');
    if (initializationFailed) throw StateError('initialize');
  }

  @override
  Future<bool> requestPermission() async {
    calls.add('request');
    return permissionResult?.future ?? permitted;
  }

  @override
  Future<bool> hasPermission() async {
    calls.add('check');
    return permitted;
  }

  @override
  Future<void> schedule(
    BarakahReminder reminder,
    ReminderContent content,
  ) async {
    calls.add('schedule');
    if (scheduleFailed) throw StateError('schedule');
    reminders.add(reminder);
    contents.add(content);
  }

  @override
  Future<void> cancel() async {
    calls.add('cancel');
    if (cancellationFailed) throw StateError('cancel');
  }
}

const reminderContent = ReminderContent(
  title: 'Daily Barakah reflection',
  body: 'Reflect',
);
