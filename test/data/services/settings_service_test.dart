import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('reminders default to opt-out at 20:00', () async {
    final settings = SettingsService(
      prefs: await SharedPreferences.getInstance(),
    );
    expect(settings.barakahReminder, (enabled: false, hour: 20, minute: 0));
    expect(SettingsService.empty().barakahReminder, settings.barakahReminder);
  });

  test(
    'enabled flag and time persist together across service instances',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await SettingsService(prefs: prefs)
          .setBarakahReminder(enabled: true, hour: 7, minute: 45);
      await prefs.reload();
      final restored = SettingsService(prefs: prefs);
      expect(restored.barakahReminder, (enabled: true, hour: 7, minute: 45));
      await restored.setBarakahReminder(enabled: false, hour: 7, minute: 45);
      await prefs.reload();
      expect(restored.barakahReminder, (enabled: false, hour: 7, minute: 45));
    },
  );

  test('invalid stored values fall back to safe defaults', () async {
    final prefs = await SharedPreferences.getInstance();
    for (final values in [
      ['true', '24', '0'],
      ['true', '20', '-1'],
      ['true', 'bad', '0'],
      ['maybe', '20', '0'],
      ['true'],
    ]) {
      await prefs.setStringList('barakah_reminder', values);
      expect(SettingsService(prefs: prefs).barakahReminder, (
        enabled: false,
        hour: 20,
        minute: 0,
      ));
    }
  });

  test(
    'invalid new times are rejected without replacing saved values',
    () async {
      final settings = SettingsService(
        prefs: await SharedPreferences.getInstance(),
      );
      await expectLater(
        settings.setBarakahReminder(enabled: true, hour: 24, minute: 0),
        throwsRangeError,
      );
      await expectLater(
        settings.setBarakahReminder(enabled: true, hour: 20, minute: 60),
        throwsRangeError,
      );
      expect(settings.barakahReminder, (enabled: false, hour: 20, minute: 0));
    },
  );

  test('missing persistence is an error rather than a false success', () async {
    await expectLater(
      SettingsService.empty().setBarakahReminder(
        enabled: true,
        hour: 20,
        minute: 0,
      ),
      throwsStateError,
    );
  });
}
