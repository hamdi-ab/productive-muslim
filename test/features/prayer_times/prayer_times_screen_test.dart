import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';

import 'package:productive_muslim/core/widgets/glass_container.dart';
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
  PrayerTimes? getPrayerTimes(Position position, {DateTime? date}) =>
      _prayerTimes;

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

  Widget buildScreen({String language = 'en'}) {
    return MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const PrayerTimesScreen(),
    );
  }

  PrayerTimes createPrayerTimes({DateTime? date}) {
    final params = CalculationMethodParameters.muslimWorldLeague();
    return PrayerTimes(
      date: date ?? DateTime.now(),
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
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.text('Open Settings'), findsOneWidget);
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

    expect(find.text('Prayer Times'), findsWidgets);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Sunrise'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

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

    expect(find.byType(GlassContainer), findsWidgets);
  });

  testWidgets('switches to Qibla Direction tab', (tester) async {
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

    expect(find.text('Qibla Direction'), findsOneWidget);
    await tester.tap(find.text('Qibla Direction'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.mosque_rounded), findsOneWidget);
  });

  testWidgets('highlights next prayer in Arabic locale', (tester) async {
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

    await tester.pumpWidget(buildScreen(language: 'ar'));
    await tester.pumpAndSettle();

    expect(find.text('الفجر'), findsOneWidget);
    expect(find.byType(GlassContainer), findsWidgets);
  });

  testWidgets(
    'post-Isha treats today prayers as Past and displays Tomorrow Fajr tile',
    (tester) async {
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
      // Simulate past prayer times (all before now)
      mockService.setPrayerTimes(
        createPrayerTimes(
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      await tester.pumpWidget(buildScreen(language: 'en'));
      await tester.pumpAndSettle();

      // Verify 'Past' badge exists and 'Completed' is not displayed
      expect(find.text('Past'), findsWidgets);
      expect(find.text('Completed'), findsNothing);

      // Scroll down to reveal Tomorrow's Fajr upcoming tile
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Verify Tomorrow's Fajr upcoming tile is displayed
      expect(find.text('Fajr (Tomorrow)'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
    },
  );

  testWidgets('post-Isha in Arabic shows انقضى and الفجر (غداً)', (
    tester,
  ) async {
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
    mockService.setPrayerTimes(
      createPrayerTimes(date: DateTime.now().subtract(const Duration(days: 1))),
    );

    await tester.pumpWidget(buildScreen(language: 'ar'));
    await tester.pumpAndSettle();

    expect(find.text('انقضى'), findsWidgets);
    expect(find.text('مكتمل'), findsNothing);

    // Scroll down to reveal Tomorrow's Fajr upcoming tile
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('الفجر (غداً)'), findsOneWidget);
    expect(find.text('غداً'), findsOneWidget);
  });
}
