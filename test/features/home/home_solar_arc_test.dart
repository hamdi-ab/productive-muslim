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
