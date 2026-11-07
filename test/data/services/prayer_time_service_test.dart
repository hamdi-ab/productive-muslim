import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PrayerTimeService service;

  setUp(() {
    service = PrayerTimeService();
  });

  group('PrayerTimeService tests', () {
    test('getCurrentPosition returns non-null position via fallback when geolocator is unavailable', () async {
      final position = await service.getCurrentPosition();
      expect(position, isNotNull);
      expect(position!.latitude, isNot(0));
      expect(position.longitude, isNot(0));
    });

    test(
      'getPrayerTimes calculates valid prayer times from position',
      () async {
        final position = await service.getCurrentPosition();
        expect(position, isNotNull);

        final prayerTimes = service.getPrayerTimes(position!);
        expect(prayerTimes, isNotNull);
        expect(prayerTimes!.fajr, isNotNull);
        expect(prayerTimes.sunrise, isNotNull);
        expect(prayerTimes.dhuhr, isNotNull);
        expect(prayerTimes.asr, isNotNull);
        expect(prayerTimes.maghrib, isNotNull);
        expect(prayerTimes.isha, isNotNull);
      },
    );

    test('getNextPrayerName returns a valid prayer name', () async {
      final position = await service.getCurrentPosition();
      final prayerTimes = service.getPrayerTimes(position!);
      final nextPrayer = service.getNextPrayerName(prayerTimes!);

      expect([
        'Fajr',
        'Sunrise',
        'Dhuhr',
        'Asr',
        'Maghrib',
        'Isha',
      ], contains(nextPrayer));
    });

    test('getTimeUntilNextPrayer returns non-negative duration', () async {
      final position = await service.getCurrentPosition();
      final prayerTimes = service.getPrayerTimes(position!);
      final duration = service.getTimeUntilNextPrayer(prayerTimes!);

      expect(duration, isNotNull);
      expect(duration!.isNegative, isFalse);
    });

    test('getLocationName returns a non-empty string', () async {
      final position = await service.getCurrentPosition();
      final name = service.getLocationName(position);

      expect(name.isNotEmpty, isTrue);
    });
  });
}
