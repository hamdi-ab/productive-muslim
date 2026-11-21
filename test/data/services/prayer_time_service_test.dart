import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PrayerTimeService service;
  late SettingsService settingsService;

  setUp(() async {
    await GetIt.I.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);
    GetIt.I.registerSingleton<SettingsService>(settingsService);
    service = PrayerTimeService();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('PrayerTimeService tests', () {
    test('getCachedOrSavedPosition returns null when neither cached nor saved coordinates exist', () {
      expect(service.cachedPosition, isNull);
      expect(settingsService.lastCoordinates, isNull);
      expect(service.getCachedOrSavedPosition(), isNull);
    });

    test(
      'getCachedOrSavedPosition returns in-memory cached position when present',
      () {
        final mockPos = Position(
          latitude: 24.7136,
          longitude: 46.6753,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        service.setCachedPositionForTesting(mockPos);

        final result = service.getCachedOrSavedPosition();
        expect(result, isNotNull);
        expect(result!.latitude, equals(24.7136));
        expect(result.longitude, equals(46.6753));
      },
    );

    test('getCachedOrSavedPosition reconstructs position from settings without requesting GPS', () async {
      await settingsService.setLastCoordinates(21.4225, 39.8262);
      expect(service.cachedPosition, isNull);

      final result = service.getCachedOrSavedPosition();
      expect(result, isNotNull);
      expect(result!.latitude, equals(21.4225));
      expect(result.longitude, equals(39.8262));
      // Verifies it populated the in-memory cache
      expect(service.cachedPosition, isNotNull);
    });

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
