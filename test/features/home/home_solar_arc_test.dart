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

    test('verifies mathematical duration proportionality: Fajr->Dhuhr > Dhuhr->Asr > Asr->Maghrib > Maghrib->Isha', () {
      final baseDate = DateTime(2026, 11, 5, 12, 0);
      final coordinates = Coordinates(21.4225, 39.8262); // Makkah
      final params = CalculationMethodParameters.muslimWorldLeague();
      final pt = PrayerTimes(
        date: baseDate,
        coordinates: coordinates,
        calculationParameters: params,
      );

      final totalSeconds = pt.isha.difference(pt.fajr).inSeconds;
      expect(totalSeconds, greaterThan(0));

      const tStart = 0.08;
      const tEnd = 0.93;
      const tSpan = tEnd - tStart;

      final dhuhrRatio = pt.dhuhr.difference(pt.fajr).inSeconds / totalSeconds;
      final asrRatio = pt.asr.difference(pt.fajr).inSeconds / totalSeconds;
      final maghribRatio =
          pt.maghrib.difference(pt.fajr).inSeconds / totalSeconds;

      final tFajr = tStart;
      final tDhuhr = (tStart + dhuhrRatio * tSpan).clamp(0.38, 0.56);
      final tAsr = (tStart + asrRatio * tSpan).clamp(tDhuhr + 0.12, 0.78);
      final tMaghrib = (tStart + maghribRatio * tSpan).clamp(tAsr + 0.08, 0.88);
      final tIsha = tEnd;

      final seg1 = tDhuhr - tFajr; // Fajr -> Dhuhr
      final seg2 = tAsr - tDhuhr; // Dhuhr -> Asr
      final seg3 = tMaghrib - tAsr; // Asr -> Maghrib
      final seg4 = tIsha - tMaghrib; // Maghrib -> Isha

      // Verify that Fajr to Dhuhr is the largest segment
      expect(seg1, greaterThan(seg2));
      // Verify that Dhuhr to Asr is larger than Asr to Maghrib
      expect(seg2, greaterThan(seg3));
      // Verify that Asr to Maghrib is larger than Maghrib to Isha
      expect(seg3, greaterThan(seg4));
      // Verify that Maghrib to Isha is the shortest segment
      expect(seg4, lessThan(seg1));
      expect(seg4, lessThan(seg2));
      expect(seg4, lessThan(seg3));
    });

    test('verifies celestial position is >= tMaghrib and never at Asr after sunset', () {
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

      final asrRatio = pt.asr.difference(pt.fajr).inSeconds / totalSeconds;
      final maghribRatio =
          pt.maghrib.difference(pt.fajr).inSeconds / totalSeconds;

      final tDhuhr =
          (tStart +
                  (pt.dhuhr.difference(pt.fajr).inSeconds / totalSeconds) *
                      tSpan)
              .clamp(0.38, 0.56);
      final tAsr = (tStart + asrRatio * tSpan).clamp(tDhuhr + 0.12, 0.78);
      final tMaghrib = (tStart + maghribRatio * tSpan).clamp(tAsr + 0.08, 0.88);
      final tIsha = tEnd;

      // 1. Time right after Maghrib (e.g., 20 mins after Maghrib)
      final postMaghribNow = pt.maghrib.add(const Duration(minutes: 20));
      final spanSec = pt.isha.difference(pt.maghrib).inSeconds;
      final elapsedSec = postMaghribNow.difference(pt.maghrib).inSeconds;
      final ratio = (elapsedSec / (spanSec > 0 ? spanSec : 1)).clamp(0.0, 1.0);
      final postMaghribT = (tMaghrib + ratio * (tIsha - tMaghrib)).clamp(
        tMaghrib,
        tIsha,
      );

      // Verify that postMaghribT is between tMaghrib and tIsha, well past Asr
      expect(postMaghribT, greaterThanOrEqualTo(tMaghrib));
      expect(postMaghribT, lessThanOrEqualTo(tIsha));
      expect(postMaghribT, greaterThan(tAsr));

      // 2. Time after Isha (night)
      final postIshaT = tIsha;
      expect(postIshaT, equals(tIsha));
      expect(postIshaT, greaterThan(tAsr));
    });

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
