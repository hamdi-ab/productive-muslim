import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';

import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/qibla_compass_view.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/solar_prayer_dial.dart';

import '../../helpers/overflow_test_helper.dart';

class MockPrayerTimeService extends PrayerTimeService {
  Position? _position;
  PrayerTimes? _prayerTimes;

  void setPosition(Position? position) => _position = position;
  void setPrayerTimes(PrayerTimes? times) => _prayerTimes = times;

  @override
  Future<Position?> getCurrentPosition() async => _position;

  @override
  PrayerTimes? getPrayerTimes(Position position, {DateTime? date}) =>
      _prayerTimes;

  @override
  String? getNextPrayerName(PrayerTimes prayerTimes) => 'Asr';

  @override
  Duration? getTimeUntilNextPrayer(PrayerTimes prayerTimes) =>
      const Duration(minutes: 42);
}

void main() {
  late MockPrayerTimeService mockService;

  setUp(() {
    mockService = MockPrayerTimeService();
    GetIt.instance.registerLazySingleton<PrayerTimeService>(() => mockService);
  });

  tearDown(() {
    GetIt.instance.unregister<PrayerTimeService>();
  });

  PrayerTimes createPrayerTimes() {
    final params = CalculationMethodParameters.muslimWorldLeague();
    return PrayerTimes(
      date: DateTime.now(),
      coordinates: Coordinates(21.4225, 39.8262),
      calculationParameters: params,
    );
  }

  group('Prayer Times Screens Overflow Verification', () {
    testWidgets(
      'PrayerTimesScreen has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        final position = Position(
          latitude: 21.4225,
          longitude: 39.8262,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        mockService.setPosition(position);
        mockService.setPrayerTimes(createPrayerTimes());

        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(height: 1200, child: PrayerTimesScreen()),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'SolarPrayerDial has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        final prayerTimes = createPrayerTimes();
        await pumpAndCheckOverflow(
          tester,
          child: SolarPrayerDial(prayerTimes: prayerTimes, nextPrayer: 'Asr'),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 600),
        );
      },
    );

    testWidgets(
      'QiblaCompassView has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const QiblaCompassView(
            latitude: 21.4225,
            longitude: 39.8262,
            initialHeading: 45.0,
          ),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 800),
        );
      },
    );
  });
}
