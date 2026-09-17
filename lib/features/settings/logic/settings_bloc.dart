import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/domain/models/barakah_reminder.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._service) : super(SettingsState(_service.status)) {
    on<SettingsLoaded>((event, emit) async {
      await _service.reconcile(event.content);
    });
    on<ReminderToggled>((event, emit) async {
      await _service.setEnabled(event.enabled, event.content);
    });
    on<ReminderTimeChanged>((event, emit) async {
      await _service.setTime(event.hour, event.minute, event.content);
    });
    on<ReminderStatusChanged>((event, emit) {
      emit(SettingsState(event.status));
    });
    _subscription = _service.changes.listen((status) {
      add(ReminderStatusChanged(status));
    });
  }

  final BarakahReminderService _service;
  late final StreamSubscription<ReminderStatus> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
