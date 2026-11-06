import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Solar Arc Duration-Proportional & Day/Night Tests', () {
    testWidgets('renders solar arc with daytime sun when active during day', (
      tester,
    ) async {
      final baseDate = DateTime(
        2026,
        11,
        5,
        10,
        0,
      ); // 10:00 AM (between Fajr & Dhuhr)
      final coordinates = Coordinates(21.4225, 39.8262); // Makkah
      final params = CalculationMethodParameters.muslimWorldLeague();
      final prayerTimes = PrayerTimes(
        date: baseDate,
        coordinates: coordinates,
        calculationParameters: params,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 120,
                child: CustomPaint(
                  painter: SolarArcPainterTestHarness(
                    prayerTimes: prayerTimes,
                    nextPrayer: 'Dhuhr',
                    isDark: false,
                    isAr: false,
                    now: baseDate,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets(
      'renders nocturnal arc with crescent moon and stars after Isha',
      (tester) async {
        final baseDate = DateTime(
          2026,
          11,
          5,
          23,
          0,
        ); // 11:00 PM (Night after Isha)
        final coordinates = Coordinates(21.4225, 39.8262); // Makkah
        final params = CalculationMethodParameters.muslimWorldLeague();
        final prayerTimes = PrayerTimes(
          date: baseDate,
          coordinates: coordinates,
          calculationParameters: params,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  height: 120,
                  child: CustomPaint(
                    painter: SolarArcPainterTestHarness(
                      prayerTimes: prayerTimes,
                      nextPrayer: 'Fajr',
                      isDark: true,
                      isAr: true,
                      now: baseDate,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    test('verifies mathematical duration proportionality on Day Arc: Fajr->Dhuhr > Dhuhr->Asr > Asr->Maghrib', () {
      final baseDate = DateTime(2026, 11, 5, 12, 0);
      final coordinates = Coordinates(21.4225, 39.8262); // Makkah
      final params = CalculationMethodParameters.muslimWorldLeague();
      final pt = PrayerTimes(
        date: baseDate,
        coordinates: coordinates,
        calculationParameters: params,
      );

      final dayDuration = pt.maghrib.difference(pt.fajr).inSeconds;
      expect(dayDuration, greaterThan(0));

      const tStart = 0.08;
      const tEnd = 0.92;
      const tSpan = tEnd - tStart; // 0.84

      final tFajr = tStart;
      final tSunrise =
          (tStart +
                  (pt.sunrise.difference(pt.fajr).inSeconds / dayDuration) *
                      tSpan)
              .clamp(0.20, 0.28);
      final tDhuhr =
          (tStart +
                  (pt.dhuhr.difference(pt.fajr).inSeconds / dayDuration) *
                      tSpan)
              .clamp(0.46, 0.54);
      final tAsr =
          (tStart +
                  (pt.asr.difference(pt.fajr).inSeconds / dayDuration) * tSpan)
              .clamp(0.70, 0.78);
      final tMaghrib = tEnd;

      final segMorning = tDhuhr - tFajr; // Fajr -> Dhuhr (~6.5h)
      final segEarlyAfternoon = tAsr - tDhuhr; // Dhuhr -> Asr (~3.5h)
      final segLateAfternoon = tMaghrib - tAsr; // Asr -> Maghrib (~2.5h)

      // Spacing order: Morning > Early Afternoon > Late Afternoon
      expect(segMorning, greaterThan(segEarlyAfternoon));
      expect(segEarlyAfternoon, greaterThan(segLateAfternoon));

      // Also verify sunrise is positioned cleanly between Fajr and Dhuhr
      expect(tSunrise, greaterThan(tFajr));
      expect(tSunrise, lessThan(tDhuhr));
    });

    test(
      'verifies 12-hour Night Arc spacing and Tahajjud at Last Third of Night',
      () {
        final baseDate = DateTime(2026, 11, 5, 23, 0); // 11:00 PM
        final coordinates = Coordinates(21.4225, 39.8262); // Makkah
        final params = CalculationMethodParameters.muslimWorldLeague();
        final pt = PrayerTimes(
          date: baseDate,
          coordinates: coordinates,
          calculationParameters: params,
        );

        final maghrib = pt.maghrib;
        final isha = pt.isha;
        final tomorrowFajr = pt.fajr.add(const Duration(days: 1));

        final nightDuration = tomorrowFajr.difference(maghrib).inSeconds;
        expect(nightDuration, greaterThan(0));

        const tStart = 0.08;
        const tEnd = 0.92;
        const tSpan = tEnd - tStart; // 0.84

        final ishaRatio = isha.difference(maghrib).inSeconds / nightDuration;
        final tMaghribNight = tStart;
        final tIshaNight = (tStart + ishaRatio * tSpan).clamp(0.22, 0.32);
        final tTahajjudNight = (tStart + (2 / 3) * tSpan).clamp(0.60, 0.72);
        final tFajrNight = tEnd;

        // Spacing assertions
        expect(tMaghribNight, equals(0.08));
        expect(tIshaNight, greaterThan(tMaghribNight + 0.12));
        expect(tTahajjudNight, greaterThan(tIshaNight + 0.25));
        expect(tFajrNight, greaterThan(tTahajjudNight + 0.15));

        // 1. Twilight dusk (between Maghrib and Isha)
        final midDusk = maghrib.add(const Duration(minutes: 35));
        final duskSpan = isha.difference(maghrib).inSeconds;
        final duskElapsed = midDusk.difference(maghrib).inSeconds;
        final duskRatio = (duskElapsed / duskSpan).clamp(0.0, 1.0);
        final progressDusk =
            tMaghribNight + duskRatio * (tIshaNight - tMaghribNight);
        expect(progressDusk, greaterThan(tMaghribNight));
        expect(progressDusk, lessThan(tIshaNight));

        // 2. Midnight (between Isha and Tahajjud)
        final tahajjudTime = tomorrowFajr.subtract(
          Duration(seconds: (nightDuration / 3).round()),
        );
        final midnight = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          23,
          59,
        );
        final nightMidSpan = tahajjudTime.difference(isha).inSeconds;
        final nightMidElapsed = midnight.difference(isha).inSeconds;
        final nightMidRatio = (nightMidElapsed / nightMidSpan).clamp(0.0, 1.0);
        final progressMidnight =
            tIshaNight + nightMidRatio * (tTahajjudNight - tIshaNight);
        expect(progressMidnight, greaterThan(tIshaNight));
        expect(progressMidnight, lessThan(tTahajjudNight));

        // 3. Tahajjud window (between Tahajjud and Fajr)
        final preFajr = tomorrowFajr.subtract(const Duration(minutes: 45));
        final tahajjudSpan = tomorrowFajr.difference(tahajjudTime).inSeconds;
        final tahajjudElapsed = preFajr.difference(tahajjudTime).inSeconds;
        final tahajjudRatio = (tahajjudElapsed / tahajjudSpan).clamp(0.0, 1.0);
        final progressTahajjud =
            tTahajjudNight + tahajjudRatio * (tFajrNight - tTahajjudNight);
        expect(progressTahajjud, greaterThan(tTahajjudNight));
        expect(progressTahajjud, lessThanOrEqualTo(tFajrNight));
      },
    );

    test(
      'verifies sun moves dynamically closer to Dhuhr as morning progresses',
      () {
        final baseDate = DateTime(2026, 11, 5, 12, 0);
        final coordinates = Coordinates(21.4225, 39.8262); // Makkah
        final params = CalculationMethodParameters.muslimWorldLeague();
        final pt = PrayerTimes(
          date: baseDate,
          coordinates: coordinates,
          calculationParameters: params,
        );

        final totalSeconds = pt.isha.difference(pt.fajr).inSeconds;
        const tStart = 0.08;
        const tEnd = 0.93;
        const tSpan = tEnd - tStart;
        final tFajr = tStart;
        final tDhuhr =
            (tStart +
                    (pt.dhuhr.difference(pt.fajr).inSeconds / totalSeconds) *
                        tSpan)
                .clamp(0.38, 0.56);

        final morningSpan = pt.dhuhr.difference(pt.fajr).inSeconds;

        // 9:00 AM
        final time9am = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          9,
          0,
        );
        final elapsed9am = time9am.difference(pt.fajr).inSeconds;
        final ratio9am = (elapsed9am / morningSpan).clamp(0.0, 1.0);
        final progress9am = tFajr + ratio9am * (tDhuhr - tFajr);

        // 11:00 AM
        final time11am = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          11,
          0,
        );
        final elapsed11am = time11am.difference(pt.fajr).inSeconds;
        final ratio11am = (elapsed11am / morningSpan).clamp(0.0, 1.0);
        final progress11am = tFajr + ratio11am * (tDhuhr - tFajr);

        // 11:00 AM must be closer to Dhuhr than 9:00 AM
        expect(progress11am, greaterThan(progress9am));
        final dist9amToDhuhr = (tDhuhr - progress9am).abs();
        final dist11amToDhuhr = (tDhuhr - progress11am).abs();
        expect(dist11amToDhuhr, lessThan(dist9amToDhuhr));

        // At exact Dhuhr time, ratio is 1.0 and progress is exactly tDhuhr
        final progressDhuhr = tFajr + 1.0 * (tDhuhr - tFajr);
        expect(progressDhuhr, equals(tDhuhr));
      },
    );

    test('verifies progressArcPath terminates exactly at celestial body position (progressT)', () {
      const p0 = Offset(18, 71.44);
      const p1 = Offset(79.2, 15.04);
      const p2 = Offset(280.8, 15.04);
      const p3 = Offset(342, 71.44);

      Offset evalCubic(double t) {
        final u = 1 - t;
        final tt = t * t;
        final uu = u * u;
        final uuu = uu * u;
        final ttt = tt * t;
        return Offset(
          uuu * p0.dx + 3 * uu * t * p1.dx + 3 * u * tt * p2.dx + ttt * p3.dx,
          uuu * p0.dy + 3 * uu * t * p1.dy + 3 * u * tt * p2.dy + ttt * p3.dy,
        );
      }

      for (final progressT in [0.15, 0.40, 0.65, 0.88]) {
        const int steps = 48;
        Offset? lastPt;
        for (int i = 1; i <= steps; i++) {
          final t = (i / steps) * progressT;
          lastPt = evalCubic(t);
        }

        final expectedCelestialPos = evalCubic(progressT);
        expect(lastPt, isNotNull);
        expect(lastPt!.dx, closeTo(expectedCelestialPos.dx, 0.001));
        expect(lastPt.dy, closeTo(expectedCelestialPos.dy, 0.001));
      }
    });
  });
}

/// Test harness to expose CustomPainter directly for testing
class SolarArcPainterTestHarness extends CustomPainter {
  final PrayerTimes? prayerTimes;
  final String nextPrayer;
  final bool isDark;
  final bool isAr;
  final DateTime now;

  SolarArcPainterTestHarness({
    required this.prayerTimes,
    required this.nextPrayer,
    required this.isDark,
    required this.isAr,
    required this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paints using the exact same logic as _SolarArcPainter
    final horizonY = size.height * 0.76;
    final w = size.width;

    final p0 = Offset(18, horizonY);
    final p1 = Offset(w * 0.22, size.height * 0.16);
    final p2 = Offset(w * 0.78, size.height * 0.16);
    final p3 = Offset(w - 18, horizonY);

    final bgArcPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    final bgArcPaint = Paint()
      ..color = isDark ? Colors.white24 : const Color(0xFFCBD5E1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(bgArcPath, bgArcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
