import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('SettingsService - Physical Anchors & Muhasabah Audit', () {
    test('physical anchors default to empty and persist on toggle', () async {
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsService(prefs: prefs);
      const date = '2026-11-11';

      expect(settings.getPhysicalAnchors(date), isEmpty);

      await settings.togglePhysicalAnchor(date, 'sleep');
      expect(settings.getPhysicalAnchors(date), contains('sleep'));

      await settings.togglePhysicalAnchor(date, 'nutrition');
      expect(
        settings.getPhysicalAnchors(date),
        containsAll(['sleep', 'nutrition']),
      );

      // Toggle off
      await settings.togglePhysicalAnchor(date, 'sleep');
      expect(settings.getPhysicalAnchors(date), isNot(contains('sleep')));
      expect(settings.getPhysicalAnchors(date), contains('nutrition'));
    });

    test('muhasabah rating and checkpoints persist correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsService(prefs: prefs);
      const date = '2026-11-11';

      // Default rating is 4
      expect(settings.getMuhasabahRating(date), 4);

      await settings.setMuhasabahRating(date, 5);
      expect(settings.getMuhasabahRating(date), 5);

      // Default checkpoints have 4 items
      final initialCheckpoints = settings.getMuhasabahCheckpoints(date);
      expect(initialCheckpoints, contains('fajr'));

      await settings.toggleMuhasabahCheckpoint(date, 'quran_tadabbur');
      expect(
        settings.getMuhasabahCheckpoints(date),
        contains('quran_tadabbur'),
      );

      await settings.toggleMuhasabahCheckpoint(date, 'fajr');
      expect(settings.getMuhasabahCheckpoints(date), isNot(contains('fajr')));
    });
  });
}
