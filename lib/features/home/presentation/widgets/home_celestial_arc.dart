import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// 12-Hour Shift Celestial Solar & Nocturnal Arc Diagram
class SolarArcDiagram extends StatelessWidget {
  final PrayerTimes? prayerTimes;
  final String nextPrayer;
  final bool isDark;

  const SolarArcDiagram({
    super.key,
    required this.prayerTimes,
    required this.nextPrayer,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return SizedBox(
      height: 94,
      width: double.infinity,
      child: CustomPaint(
        key: const ValueKey('solar_arc_custom_paint'),
        painter: SolarArcPainter(
          prayerTimes: prayerTimes,
          nextPrayer: nextPrayer,
          isDark: isDark,
          isAr: isAr,
          now: DateTime.now(),
        ),
      ),
    );
  }
}

class SolarArcPainter extends CustomPainter {
  final PrayerTimes? prayerTimes;
  final String nextPrayer;
  final bool isDark;
  final bool isAr;
  final DateTime now;

  SolarArcPainter({
    required this.prayerTimes,
    required this.nextPrayer,
    required this.isDark,
    required this.isAr,
    required this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.76;
    final w = size.width;

    // 1. Draw dashed horizon baseline
    final dashPaint = Paint()
      ..color = isDark ? Colors.white12 : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 12.0;
    final endX = w - 12.0;
    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, horizonY),
        Offset(math.min(startX + dashWidth, endX), horizonY),
        dashPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // 2. Compute day/night cycle and prayer boundary times
    final fajr = prayerTimes?.fajr;
    final sunrise = prayerTimes?.sunrise;
    final dhuhr = prayerTimes?.dhuhr;
    final asr = prayerTimes?.asr;
    final maghrib = prayerTimes?.maghrib;
    final isha = prayerTimes?.isha;

    // Islamic day/night cycle: night begins at Maghrib (sunset) and ends at Fajr (dawn)
    final isNight =
        (maghrib != null && now.isAfter(maghrib)) ||
        (fajr != null && now.isBefore(fajr));

    // 3. Solar curve path (cubic bezier)
    final p0 = Offset(18, horizonY);
    final p1 = Offset(w * 0.22, size.height * 0.16);
    final p2 = Offset(w * 0.78, size.height * 0.16);
    final p3 = Offset(w - 18, horizonY);

    final bgArcPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    final bgArcPaint = Paint()
      ..color = isDark
          ? (isNight ? Colors.indigo.withValues(alpha: 0.25) : Colors.white24)
          : (isNight
                ? Colors.indigo.withValues(alpha: 0.12)
                : const Color(0xFFCBD5E1))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(bgArcPath, bgArcPaint);

    const tStart = 0.08;
    const tEnd = 0.92;
    const tSpan = tEnd - tStart; // 0.84

    final key = nextPrayer.toLowerCase();
    double progressT = tStart;

    // Milestone fractions for Day Arc vs Night Arc
    double tFajrDay = tStart;
    double tSunriseDay = 0.24;
    double tDhuhrDay = 0.50;
    double tAsrDay = 0.74;
    double tMaghribDay = tEnd;

    double tMaghribNight = tStart;
    double tIshaNight = 0.26;
    double tTahajjudNight = 0.64;
    double tFajrNight = tEnd;

    DateTime? fajrNext;
    DateTime? maghribPrev;
    DateTime? ishaPrev;
    DateTime? tahajjudTime;

    if (!isNight) {
      // ----------------- DAY ARC (Fajr -> Maghrib) -----------------
      final dayDuration = (fajr != null && maghrib != null)
          ? maghrib.difference(fajr).inSeconds
          : 12 * 3600;

      if (fajr != null && sunrise != null && dayDuration > 0) {
        tSunriseDay =
            (tStart +
                    (sunrise.difference(fajr).inSeconds / dayDuration) * tSpan)
                .clamp(0.20, 0.28);
      }
      if (fajr != null && dhuhr != null && dayDuration > 0) {
        tDhuhrDay =
            (tStart + (dhuhr.difference(fajr).inSeconds / dayDuration) * tSpan)
                .clamp(0.46, 0.54);
      }
      if (fajr != null && asr != null && dayDuration > 0) {
        tAsrDay =
            (tStart + (asr.difference(fajr).inSeconds / dayDuration) * tSpan)
                .clamp(0.70, 0.78);
      }

      // Compute continuous piecewise progress along Day Arc
      if (fajr != null && now.isBefore(fajr)) {
        progressT = tFajrDay;
      } else if (fajr != null && sunrise != null && now.isBefore(sunrise)) {
        final span = sunrise.difference(fajr).inSeconds;
        final elapsed = now.difference(fajr).inSeconds;
        final ratio = (elapsed / (span > 0 ? span : 1)).clamp(0.0, 1.0);
        progressT = (tFajrDay + ratio * (tSunriseDay - tFajrDay)).clamp(
          tFajrDay,
          tSunriseDay,
        );
      } else if (sunrise != null && dhuhr != null && now.isBefore(dhuhr)) {
        final span = dhuhr.difference(sunrise).inSeconds;
        final elapsed = now.difference(sunrise).inSeconds;
        final ratio = (elapsed / (span > 0 ? span : 1)).clamp(0.0, 1.0);
        progressT = (tSunriseDay + ratio * (tDhuhrDay - tSunriseDay)).clamp(
          tSunriseDay,
          tDhuhrDay,
        );
      } else if (dhuhr != null && asr != null && now.isBefore(asr)) {
        final span = asr.difference(dhuhr).inSeconds;
        final elapsed = now.difference(dhuhr).inSeconds;
        final ratio = (elapsed / (span > 0 ? span : 1)).clamp(0.0, 1.0);
        progressT = (tDhuhrDay + ratio * (tAsrDay - tDhuhrDay)).clamp(
          tDhuhrDay,
          tAsrDay,
        );
      } else if (asr != null && maghrib != null && now.isBefore(maghrib)) {
        final span = maghrib.difference(asr).inSeconds;
        final elapsed = now.difference(asr).inSeconds;
        final ratio = (elapsed / (span > 0 ? span : 1)).clamp(0.0, 1.0);
        progressT = (tAsrDay + ratio * (tMaghribDay - tAsrDay)).clamp(
          tAsrDay,
          tMaghribDay,
        );
      } else {
        progressT = switch (key) {
          'fajr' => tFajrDay,
          'sunrise' => tSunriseDay,
          'dhuhr' => tDhuhrDay,
          'asr' => tAsrDay,
          'maghrib' => tMaghribDay,
          _ => tDhuhrDay,
        };
      }
    } else {
      // ----------------- NIGHT ARC (Maghrib -> Fajr) -----------------
      fajrNext = (fajr != null && now.isBefore(fajr))
          ? fajr
          : (fajr?.add(const Duration(days: 1)) ??
                now.add(const Duration(hours: 8)));
      maghribPrev = (maghrib != null && now.isAfter(maghrib))
          ? maghrib
          : (maghrib?.subtract(const Duration(days: 1)) ??
                now.subtract(const Duration(hours: 4)));
      ishaPrev = (isha != null && now.isAfter(isha))
          ? isha
          : (isha != null && fajr != null && now.isBefore(fajr)
                ? isha.subtract(const Duration(days: 1))
                : isha ??
                      maghribPrev.add(const Duration(hours: 1, minutes: 30)));

      final nightDuration = fajrNext.difference(maghribPrev).inSeconds;
      tahajjudTime = fajrNext.subtract(
        Duration(seconds: (nightDuration / 3).round()),
      );

      if (nightDuration > 0) {
        final ishaSec = ishaPrev.difference(maghribPrev).inSeconds;
        tIshaNight = (tStart + (ishaSec / nightDuration) * tSpan).clamp(
          0.22,
          0.32,
        );
        tTahajjudNight = (tStart + (2 / 3) * tSpan).clamp(0.60, 0.72);
      }

      // Compute continuous piecewise progress along Night Arc
      if (now.isBefore(ishaPrev)) {
        final span = ishaPrev.difference(maghribPrev).inSeconds;
        final elapsed = now.difference(maghribPrev).inSeconds;
        final ratio = (elapsed / (span > 0 ? span : 1)).clamp(0.0, 1.0);
        progressT = (tMaghribNight + ratio * (tIshaNight - tMaghribNight))
            .clamp(tMaghribNight, tIshaNight);
      } else if (now.isBefore(tahajjudTime)) {
        final span = tahajjudTime.difference(ishaPrev).inSeconds;
        final elapsed = now.difference(ishaPrev).inSeconds;
        final ratio = (elapsed / (span > 0 ? span : 1)).clamp(0.0, 1.0);
        progressT = (tIshaNight + ratio * (tTahajjudNight - tIshaNight)).clamp(
          tIshaNight,
          tTahajjudNight,
        );
      } else if (now.isBefore(fajrNext)) {
        final span = fajrNext.difference(tahajjudTime).inSeconds;
        final elapsed = now.difference(tahajjudTime).inSeconds;
        final ratio = (elapsed / (span > 0 ? span : 1)).clamp(0.0, 1.0);
        progressT = (tTahajjudNight + ratio * (tFajrNight - tTahajjudNight))
            .clamp(tTahajjudNight, tFajrNight);
      } else {
        progressT = tFajrNight;
      }
    }

    // 4. Draw active illuminated progress arc directly leading to the celestial body
    final progressArcPath = Path()..moveTo(p0.dx, p0.dy);
    const int steps = 48;
    for (int i = 1; i <= steps; i++) {
      final t = (i / steps) * progressT;
      final pt = _evalCubic(p0, p1, p2, p3, t);
      progressArcPath.lineTo(pt.dx, pt.dy);
    }

    if (!isNight) {
      final gradientPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF0F4C3A), Color(0xFFD4AF37)],
        ).createShader(Rect.fromLTWH(0, 0, w, size.height))
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(progressArcPath, gradientPaint);
    } else {
      final nightProgressPaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF8B5CF6), // dusk violet
            Color(0xFF6366F1), // celestial indigo
            Color(0xFF38BDF8), // dawn cyan
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, size.height))
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(progressArcPath, nightProgressPaint);

      // Faint ambient stars in the nocturnal sky
      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.6 : 0.45)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w * 0.16, size.height * 0.22), 1.2, starPaint);
      canvas.drawCircle(Offset(w * 0.38, size.height * 0.14), 1.5, starPaint);
      canvas.drawCircle(Offset(w * 0.64, size.height * 0.12), 1.2, starPaint);
      canvas.drawCircle(Offset(w * 0.84, size.height * 0.24), 1.4, starPaint);
    }

    // Helper to draw fixed milestone and active nodes
    void drawNode(
      double t,
      Color color,
      String label, {
      bool isAbove = false,
      bool isActive = false,
      bool isCompleted = false,
    }) {
      final pt = _evalCubic(p0, p1, p2, p3, t);
      final nodePaint = Paint()
        ..color = isActive
            ? const Color(0xFFF59E0B)
            : (isCompleted ? const Color(0xFF10B981) : color)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = isActive ? 2.2 : 1.6
        ..style = PaintingStyle.stroke;

      if (isActive) {
        final haloPaint = Paint()
          ..color = const Color(0xFFF59E0B).withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pt, 8.0, haloPaint);
      }

      canvas.drawCircle(pt, isActive ? 5.0 : 4.0, nodePaint);
      canvas.drawCircle(pt, isActive ? 5.0 : 4.0, borderPaint);

      final textSpan = TextSpan(
        text: label,
        style: TextStyle(
          color: isActive
              ? (isDark ? AppColors.secondary : const Color(0xFFD97706))
              : (isCompleted
                    ? (isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF059669))
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF64748B))),
          fontSize: isActive ? 9.5 : 8.5,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      )..layout();
      final textOffset = isAbove
          ? Offset(pt.dx - textPainter.width / 2, pt.dy - 15)
          : Offset(pt.dx - textPainter.width / 2, pt.dy + 7);
      textPainter.paint(canvas, textOffset);
    }

    final defaultNodeColor = isDark ? Colors.white38 : const Color(0xFF94A3B8);

    if (!isNight) {
      // 5 Milestones on Day Arc: Fajr, Sunrise, Dhuhr, Asr, Maghrib
      final fajrLabel = isAr ? 'الفجر' : 'Fajr';
      final sunriseLabel = isAr ? 'الشروق' : 'Sunrise';
      final dhuhrLabel = isAr ? 'الظهر' : 'Dhuhr';
      final asrLabel = isAr ? 'العصر' : 'Asr';
      final maghribLabel = isAr ? 'المغرب' : 'Maghrib';

      final isFajrActive = key == 'fajr';
      final isSunriseActive = key == 'sunrise';
      final isDhuhrActive = key == 'dhuhr';
      final isAsrActive = key == 'asr';
      final isMaghribActive = key == 'maghrib';

      final isFajrPast = fajr != null && now.isAfter(fajr) && !isFajrActive;
      final isSunrisePast =
          sunrise != null && now.isAfter(sunrise) && !isSunriseActive;
      final isDhuhrPast = dhuhr != null && now.isAfter(dhuhr) && !isDhuhrActive;
      final isAsrPast = asr != null && now.isAfter(asr) && !isAsrActive;

      // 1. Fajr (Dawn horizon, label below)
      drawNode(
        tFajrDay,
        defaultNodeColor,
        fajrLabel,
        isAbove: false,
        isActive: isFajrActive,
        isCompleted: isFajrPast,
      );
      // 2. Sunrise (Ascending slope, label above)
      drawNode(
        tSunriseDay,
        defaultNodeColor,
        sunriseLabel,
        isAbove: true,
        isActive: isSunriseActive,
        isCompleted: isSunrisePast,
      );
      // 3. Dhuhr (Zenith peak, label above)
      drawNode(
        tDhuhrDay,
        defaultNodeColor,
        dhuhrLabel,
        isAbove: true,
        isActive: isDhuhrActive,
        isCompleted: isDhuhrPast,
      );
      // 4. Asr (Afternoon slope, label above)
      drawNode(
        tAsrDay,
        defaultNodeColor,
        asrLabel,
        isAbove: true,
        isActive: isAsrActive,
        isCompleted: isAsrPast,
      );
      // 5. Maghrib (Sunset horizon, label below)
      drawNode(
        tMaghribDay,
        defaultNodeColor,
        maghribLabel,
        isAbove: false,
        isActive: isMaghribActive,
        isCompleted: false,
      );
    } else {
      // 4 Milestones on Night Arc: Maghrib, Isha, Tahajjud, Fajr
      final maghribLabel = isAr ? 'المغرب' : 'Maghrib';
      final ishaLabel = isAr ? 'العشاء' : 'Isha';
      final tahajjudLabel = isAr ? 'التهجد' : 'Tahajjud';
      final fajrLabel = isAr ? 'الفجر' : 'Fajr';

      final isIshaActive = key == 'isha';
      final isTahajjudActive =
          tahajjudTime != null &&
          fajrNext != null &&
          now.isAfter(tahajjudTime) &&
          now.isBefore(fajrNext);
      final isFajrActive = key == 'fajr';

      final isIshaPast =
          ishaPrev != null && now.isAfter(ishaPrev) && !isIshaActive;
      final isTahajjudPast =
          tahajjudTime != null &&
          now.isAfter(tahajjudTime) &&
          !isTahajjudActive;

      // 1. Maghrib (Sunset horizon, label below)
      drawNode(
        tMaghribNight,
        defaultNodeColor,
        maghribLabel,
        isAbove: false,
        isActive: false,
        isCompleted: true,
      );
      // 2. Isha (Nightfall slope, label above)
      drawNode(
        tIshaNight,
        defaultNodeColor,
        ishaLabel,
        isAbove: true,
        isActive: isIshaActive,
        isCompleted: isIshaPast,
      );
      // 3. Tahajjud (Night zenith / Last third, label above)
      drawNode(
        tTahajjudNight,
        defaultNodeColor,
        tahajjudLabel,
        isAbove: true,
        isActive: isTahajjudActive,
        isCompleted: isTahajjudPast,
      );
      // 4. Fajr (Dawn horizon, label below)
      drawNode(
        tFajrNight,
        defaultNodeColor,
        fajrLabel,
        isAbove: false,
        isActive: isFajrActive,
        isCompleted: false,
      );
    }

    // 5. Draw Celestial Body: Sun during daytime, Crescent Moon (Hilal) during night
    final celestialPos = _evalCubic(p0, p1, p2, p3, progressT);

    if (!isNight) {
      // Outer halo
      final haloPaint = Paint()
        ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(celestialPos, 11.0, haloPaint);

      // Glowing sun disk
      final sunPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(celestialPos, 7.5, sunPaint);

      // Core white center
      final corePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(celestialPos, 3.5, corePaint);
    } else {
      // Soft nocturnal lunar aura
      final moonAuraPaint = Paint()
        ..color = const Color(0xFF818CF8).withValues(alpha: 0.28)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(celestialPos, 12.0, moonAuraPaint);

      // Luminous Crescent Moon (Hilal)
      final moonPath = Path()
        ..addOval(Rect.fromCircle(center: celestialPos, radius: 7.5));
      final cutPath = Path()
        ..addOval(
          Rect.fromCircle(
            center: celestialPos.translate(3.5, -2.0),
            radius: 6.2,
          ),
        );
      final crescent = Path.combine(
        PathOperation.difference,
        moonPath,
        cutPath,
      );

      final moonFillPaint = Paint()
        ..color = const Color(0xFFFDE68A)
        ..style = PaintingStyle.fill;
      canvas.drawPath(crescent, moonFillPaint);
    }
  }

  Offset _evalCubic(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;

    final x =
        uuu * p0.dx + 3 * uu * t * p1.dx + 3 * u * tt * p2.dx + ttt * p3.dx;
    final y =
        uuu * p0.dy + 3 * uu * t * p1.dy + 3 * u * tt * p2.dy + ttt * p3.dy;
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant SolarArcPainter oldDelegate) {
    return oldDelegate.nextPrayer != nextPrayer ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isAr != isAr ||
        oldDelegate.prayerTimes != prayerTimes ||
        oldDelegate.now.minute != now.minute;
  }
}

String getLocalizedPrayerName(String key, AppLocalizations l10n) {
  return switch (key.toLowerCase()) {
    'fajr' => l10n.fajr,
    'sunrise' => l10n.sunrise,
    'dhuhr' => l10n.dhuhr,
    'asr' => l10n.asr,
    'maghrib' => l10n.maghrib,
    'isha' => l10n.isha,
    _ => key,
  };
}

class IslamicLatticeBackgroundPainter extends CustomPainter {
  final bool isDark;
  const IslamicLatticeBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? const Color(0xFFE9C349).withValues(alpha: 0.025)
          : const Color(0xFF0F4C3A).withValues(alpha: 0.02)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 50.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), spacing * 0.45, paint);
        final path = Path()
          ..moveTo(x, y - spacing * 0.45)
          ..lineTo(x + spacing * 0.45, y)
          ..lineTo(x, y + spacing * 0.45)
          ..lineTo(x - spacing * 0.45, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant IslamicLatticeBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
