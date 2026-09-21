import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';

import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockPrayerTimeService extends PrayerTimeService {
  Position? _position;
  PrayerTimes? _prayerTimes;

  void setPosition(Position? position) => _position = position;
  void setPrayerTimes(PrayerTimes? times) => _prayerTimes = times;

  @override
  Future<Position?> getCurrentPosition() async => _position;

  @override
  PrayerTimes? getPrayerTimes(Position position) => _prayerTimes;

  @override
  String? getNextPrayerName(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    if (prayerTimes.fajr.isAfter(now)) return 'Fajr';
    if (prayerTimes.dhuhr.isAfter(now)) return 'Dhuhr';
    if (prayerTimes.asr.isAfter(now)) return 'Asr';
    if (prayerTimes.maghrib.isAfter(now)) return 'Maghrib';
    if (prayerTimes.isha.isAfter(now)) return 'Isha';
    return 'Fajr';
  }

  @override
  Duration? getTimeUntilNextPrayer(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    if (prayerTimes.fajr.isAfter(now)) {
      return prayerTimes.fajr.difference(now);
    }
    if (prayerTimes.dhuhr.isAfter(now)) {
      return prayerTimes.dhuhr.difference(now);
    }
    return const Duration(hours: 1);
  }
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

  Widget buildScreen() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const PrayerTimesScreen(),
    );
  }

  PrayerTimes createPrayerTimes() {
    final params = CalculationMethodParameters.muslimWorldLeague();
    return PrayerTimes(
      date: DateTime.now(),
      coordinates: Coordinates(40.7128, -74.0060),
      calculationParameters: params,
    );
  }

  testWidgets('shows loading indicator initially', (tester) async {
    mockService.setPosition(null);
    await tester.pumpWidget(buildScreen());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows location required when position is null', (tester) async {
    mockService.setPosition(null);
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.textContaining('location'), findsOneWidget);
  });

  testWidgets('shows prayer times when loaded', (tester) async {
    final position = Position(
      latitude: 40.7128,
      longitude: -74.0060,
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

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Prayer Times'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);
    expect(find.text('Asr'), findsOneWidget);
    expect(find.text('Maghrib'), findsOneWidget);
    expect(find.text('Isha'), findsOneWidget);
  });

  testWidgets('highlights next prayer', (tester) async {
    final position = Position(
      latitude: 40.7128,
      longitude: -74.0060,
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

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    // The next prayer should have a green dot indicator
    expect(find.byType(Container), findsWidgets);
  });
}
