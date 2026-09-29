import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsService settingsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);
  });

  group('SettingsService Smart Notification Preferences', () {
    test('defaults are enabled for adhkar and sunnah fasting', () {
      expect(settingsService.morningAdhkarNotificationEnabled, isTrue);
      expect(settingsService.eveningAdhkarNotificationEnabled, isTrue);
      expect(settingsService.sleepingAdhkarNotificationEnabled, isTrue);
      expect(settingsService.sunnahFastingNotificationEnabled, isTrue);
      expect(settingsService.qaylulahNotificationEnabled, isFalse);
      expect(settingsService.bedtimeReminderHour, equals(22));
      expect(settingsService.bedtimeReminderMinute, equals(30));
    });

    test('can toggle preferences and persist', () async {
      await settingsService.setMorningAdhkarNotificationEnabled(false);
      expect(settingsService.morningAdhkarNotificationEnabled, isFalse);

      await settingsService.setEveningAdhkarNotificationEnabled(false);
      expect(settingsService.eveningAdhkarNotificationEnabled, isFalse);

      await settingsService.setSleepingAdhkarNotificationEnabled(false);
      expect(settingsService.sleepingAdhkarNotificationEnabled, isFalse);

      await settingsService.setSunnahFastingNotificationEnabled(false);
      expect(settingsService.sunnahFastingNotificationEnabled, isFalse);

      await settingsService.setQaylulahNotificationEnabled(true);
      expect(settingsService.qaylulahNotificationEnabled, isTrue);

      await settingsService.setBedtimeReminderTime(hour: 23, minute: 15);
      expect(settingsService.bedtimeReminderHour, equals(23));
      expect(settingsService.bedtimeReminderMinute, equals(15));
    });
  });
}
