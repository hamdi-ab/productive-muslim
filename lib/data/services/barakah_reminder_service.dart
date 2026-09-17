import 'dart:async';

import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/barakah_reminder.dart';
import 'package:productive_muslim/domain/repositories/barakah_reminder_scheduler.dart';

class BarakahReminderService {
  BarakahReminderService({
    required SettingsService settings,
    required BarakahReminderScheduler scheduler,
  }) : _settings = settings,
       _scheduler = scheduler {
    final saved = settings.barakahReminder;
    _status = ReminderStatus(
      reminder: BarakahReminder(
        enabled: scheduler.supported && saved.enabled,
        hour: saved.hour,
        minute: saved.minute,
      ),
      supported: scheduler.supported,
    );
  }

  final SettingsService _settings;
  final BarakahReminderScheduler _scheduler;
  final _changes = StreamController<ReminderStatus>.broadcast(sync: true);
  late ReminderStatus _status;
  Future<void>? _queue;

  ReminderStatus get status => _status;
  Stream<ReminderStatus> get changes => _changes.stream;

  Future<void> reconcile(ReminderContent content) => _enqueue(content: content);

  Future<void> setEnabled(bool enabled, ReminderContent content) =>
      _enqueue(enabled: enabled, content: content);

  Future<void> setTime(int hour, int minute, ReminderContent content) =>
      _enqueue(hour: hour, minute: minute, content: content);

  Future<void> _enqueue({
    bool? enabled,
    int? hour,
    int? minute,
    required ReminderContent content,
  }) {
    Future<void> apply() =>
        _apply(enabled: enabled, hour: hour, minute: minute, content: content);
    final operation = _queue?.then((_) => apply()) ?? apply();
    _queue = operation;
    return operation.whenComplete(() {
      if (identical(_queue, operation)) _queue = null;
    });
  }

  void _publish(
    BarakahReminder reminder, {
    bool pending = false,
    ReminderFailure? failure,
  }) {
    _status = ReminderStatus(
      reminder: reminder,
      supported: _scheduler.supported,
      pending: pending,
      failure: failure,
    );
    _changes.add(_status);
  }

  Future<void> _save(BarakahReminder reminder) => _settings.setBarakahReminder(
    enabled: reminder.enabled,
    hour: reminder.hour,
    minute: reminder.minute,
  );

  Future<void> _apply({
    bool? enabled,
    int? hour,
    int? minute,
    required ReminderContent content,
  }) async {
    final previous = _status.reminder;
    if (!_scheduler.supported) {
      _publish(previous, failure: ReminderFailure.unavailable);
      return;
    }
    _publish(previous, pending: true);
    final desired = BarakahReminder(
      enabled: enabled ?? previous.enabled,
      hour: hour ?? previous.hour,
      minute: minute ?? previous.minute,
    );
    final disabled = BarakahReminder(
      hour: previous.hour,
      minute: previous.minute,
    );
    try {
      if (enabled == false) {
        await _save(disabled);
        await _scheduler.cancel();
        _publish(disabled);
        return;
      }
      await _scheduler.initialize();
      if (desired.enabled) {
        await _save(disabled);
        final allowed = enabled == true
            ? await _scheduler.requestPermission()
            : await _scheduler.hasPermission();
        if (!allowed) {
          await _scheduler.cancel();
          _publish(disabled, failure: ReminderFailure.permissionDenied);
          return;
        }
        await _scheduler.schedule(desired, content);
      } else {
        await _scheduler.cancel();
      }
      await _save(desired);
      _publish(desired);
    } catch (_) {
      try {
        await _save(disabled);
      } catch (_) {}
      try {
        await _scheduler.cancel();
      } catch (_) {}
      _publish(disabled, failure: ReminderFailure.operationFailed);
    }
  }

  Future<void> dispose() async {
    await _queue;
    await _changes.close();
  }
}
