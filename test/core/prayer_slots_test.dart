import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/constants/app_life_areas.dart';
import 'package:productive_muslim/core/constants/app_prayer_slots.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';

void main() {
  group('3 Spheres and Life Areas', () {
    test('sphereOf correctly maps categories to the 3 Spheres', () {
      expect(AppLifeArea.sphereOf('spiritual'), 'spiritual');
      expect(AppLifeArea.sphereOf('islam'), 'spiritual');
      expect(AppLifeArea.sphereOf('physical'), 'physical');
      expect(AppLifeArea.sphereOf('personal_dev'), 'physical');
      expect(AppLifeArea.sphereOf('social'), 'social');
      expect(AppLifeArea.sphereOf('family'), 'social');
      expect(AppLifeArea.sphereOf('work'), 'social');
    });

    test('AppLifeArea contains colors for all primary spheres', () {
      expect(AppLifeArea.all.containsKey('spiritual'), isTrue);
      expect(AppLifeArea.all.containsKey('physical'), isTrue);
      expect(AppLifeArea.all.containsKey('social'), isTrue);
    });
  });

  group('BarakahSlot & Prayer Time Scheduling', () {
    test('contains all 6 essential Barakah time windows', () {
      expect(BarakahSlot.all.length, 6);
      expect(BarakahSlot.fromId('early_morning'), isNotNull);
      expect(BarakahSlot.fromId('duha'), isNotNull);
      expect(BarakahSlot.fromId('dhuhr'), isNotNull);
      expect(BarakahSlot.fromId('asr'), isNotNull);
      expect(BarakahSlot.fromId('maghrib'), isNotNull);
      expect(BarakahSlot.fromId('isha'), isNotNull);
      expect(BarakahSlot.fromId('invalid'), isNull);
    });

    test('PrayerTimeService returns valid fallback slot minutes when prayerTimes is null', () {
      final service = PrayerTimeService();
      final slot = service.getSlotMinutes('early_morning', null);
      expect(slot.startMinutes, 330);
      expect(slot.endMinutes, 420);
      expect(slot.endMinutes > slot.startMinutes, isTrue);
    });
  });
}
