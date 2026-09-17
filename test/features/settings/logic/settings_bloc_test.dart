import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/barakah_reminder.dart';
import 'package:productive_muslim/features/settings/logic/settings_bloc.dart';
import 'package:productive_muslim/features/settings/logic/settings_event.dart';
import 'package:productive_muslim/features/settings/logic/settings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_reminder_scheduler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeReminderScheduler scheduler;
  late BarakahReminderService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    scheduler = FakeReminderScheduler();
    service = BarakahReminderService(
      settings: SettingsService(prefs: await SharedPreferences.getInstance()),
      scheduler: scheduler,
    );
  });
  tearDown(() => service.dispose());

  blocTest<SettingsBloc, SettingsState>(
    'loads settings without requesting permission',
    build: () => SettingsBloc(service),
    act: (bloc) => bloc.add(const SettingsLoaded(reminderContent)),
    expect: () => [
      isA<SettingsState>().having((s) => s.pending, 'pending', true),
      isA<SettingsState>()
          .having((s) => s.pending, 'pending', false)
          .having((s) => s.enabled, 'enabled', false)
          .having((s) => s.hour, 'hour', 20),
    ],
    verify: (_) => expect(scheduler.calls, ['initialize', 'cancel']),
  );

  blocTest<SettingsBloc, SettingsState>(
    'toggle emits pending then enabled',
    build: () => SettingsBloc(service),
    act: (bloc) => bloc.add(const ReminderToggled(true, reminderContent)),
    expect: () => [
      isA<SettingsState>().having((s) => s.pending, 'pending', true),
      isA<SettingsState>()
          .having((s) => s.enabled, 'enabled', true)
          .having((s) => s.pending, 'pending', false),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'denial is exposed as a localized UI message key',
    build: () {
      scheduler.permitted = false;
      return SettingsBloc(service);
    },
    act: (bloc) => bloc.add(const ReminderToggled(true, reminderContent)),
    expect: () => [
      isA<SettingsState>().having((s) => s.pending, 'pending', true),
      isA<SettingsState>()
          .having((s) => s.enabled, 'enabled', false)
          .having(
            (s) => s.failure,
            'failure',
            ReminderFailure.permissionDenied,
          ),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'selected time is reflected through the shared service',
    build: () => SettingsBloc(service),
    act: (bloc) => bloc.add(const ReminderTimeChanged(9, 25, reminderContent)),
    expect: () => [
      isA<SettingsState>().having((s) => s.pending, 'pending', true),
      isA<SettingsState>()
          .having((s) => s.hour, 'hour', 9)
          .having((s) => s.minute, 'minute', 25),
    ],
  );

  test(
    'closed screen does not dispose shared reconciliation service',
    () async {
      final bloc = SettingsBloc(service);
      await bloc.close();
      await service.setEnabled(true, reminderContent);
      expect(service.status.reminder.enabled, isTrue);
    },
  );
}
