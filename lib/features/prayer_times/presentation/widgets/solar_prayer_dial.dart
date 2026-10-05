import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/app_typography_extension.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class SolarPrayerDial extends StatefulWidget {
  const SolarPrayerDial({
    super.key,
    required this.prayerTimes,
    required this.nextPrayer,
  });

  final dynamic prayerTimes;
  final String nextPrayer;

  @override
  State<SolarPrayerDial> createState() => _SolarPrayerDialState();
}

class _SolarPrayerDialState extends State<SolarPrayerDial> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _localizePrayerName(String prayer, AppLocalizations l10n) {
    return switch (prayer.toLowerCase()) {
      'fajr' => l10n.fajr,
      'sunrise' => l10n.sunrise,
      'dhuhr' => l10n.dhuhr,
      'asr' => l10n.asr,
      'maghrib' => l10n.maghrib,
      'isha' => l10n.isha,
      _ => prayer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final fajr = (widget.prayerTimes.fajr as DateTime).toLocal();
    final sunrise = (widget.prayerTimes.sunrise as DateTime).toLocal();
    final dhuhr = (widget.prayerTimes.dhuhr as DateTime).toLocal();
    final asr = (widget.prayerTimes.asr as DateTime).toLocal();
    final maghrib = (widget.prayerTimes.maghrib as DateTime).toLocal();
    final isha = (widget.prayerTimes.isha as DateTime).toLocal();

    final isNight = now.isAfter(maghrib) || now.isBefore(fajr);

    double progress = 0.0;
    if (!isNight) {
      // Daytime: from Fajr to Maghrib
      final dayDuration = maghrib.difference(fajr).inSeconds;
      final dayElapsed = now.difference(fajr).inSeconds;
      progress = dayDuration > 0 ? (dayElapsed / dayDuration) : 0.5;
    } else {
      // Nighttime: from Maghrib to Fajr (next morning)
      final fajrNext = now.isBefore(fajr) ? fajr : fajr.add(const Duration(days: 1));
      final maghribPrev = now.isAfter(maghrib) ? maghrib : maghrib.subtract(const Duration(days: 1));
      final nightDuration = fajrNext.difference(maghribPrev).inSeconds;
      final nightElapsed = now.difference(maghribPrev).inSeconds;
      progress = nightDuration > 0 ? (nightElapsed / nightDuration) : 0.5;
    }

    String currentSlotName;
    if (now.isBefore(fajr)) {
      currentSlotName = l10n.slotTahajjud;
    } else if (now.isBefore(sunrise)) {
      currentSlotName = l10n.slotEarlyMorning;
    } else if (now.isBefore(dhuhr)) {
      currentSlotName = l10n.slotDuha;
    } else if (now.isBefore(asr)) {
      currentSlotName = l10n.slotDhuhr;
    } else if (now.isBefore(maghrib)) {
      currentSlotName = l10n.slotAsr;
    } else if (now.isBefore(isha)) {
      currentSlotName = l10n.slotMaghrib;
    } else {
      currentSlotName = l10n.slotNight;
    }

    final localizedNext = _localizePrayerName(widget.nextPrayer, l10n);

    // High contrast theme tokens
    final badgeBg = isNight
        ? (isDark ? const Color(0xFF6366F1).withValues(alpha: 0.25) : const Color(0xFF6366F1).withValues(alpha: 0.12))
        : (isDark ? AppColors.primary.withValues(alpha: 0.22) : AppColors.primary.withValues(alpha: 0.12));
    final badgeText = isNight
        ? (isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA))
        : (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857));

    final headerIconColor = isNight ? const Color(0xFF818CF8) : const Color(0xFFF59E0B);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final headerTitle = isNight
        ? (isAr ? 'مسار الليل والتهجد' : 'Night & Tahajjud Arc')
        : l10n.solarDialTitle;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                      size: 18,
                      color: headerIconColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        headerTitle,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.solarCurrentWindow(currentSlotName),
                    style: TextStyle(
                      color: badgeText,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _SolarArcPainter(
                progress: progress.clamp(0.0, 1.0),
                isDark: isDark,
                isNight: isNight,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.jm().format(now),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.solarNext(localizedNext),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.75)
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SolarArcPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final bool isNight;

  _SolarArcPainter({
    required this.progress,
    required this.isDark,
    required this.isNight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final radius = math.min(size.width * 0.42, size.height * 0.85);

    const startAngle = math.pi;
    const sweepAngle = math.pi;

    final backgroundPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.15)
          : Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final List<Color> gradientColors = isNight
        ? const [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFF38BDF8)]
        : const [Color(0xFFF59E0B), Color(0xFF10B981), Color(0xFF0EA5E9)];

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: gradientColors,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Draw active progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * progress,
        false,
        progressPaint,
      );
    }

    // Draw Indicator dot (Sun or Moon)
    final currentAngle = startAngle + (sweepAngle * progress);
    final indicatorX = center.dx + radius * math.cos(currentAngle);
    final indicatorY = center.dy + radius * math.sin(currentAngle);

    final auraColor = isNight
        ? const Color(0xFF818CF8)
        : const Color(0xFFF59E0B);

    final indicatorGlow = Paint()
      ..color = auraColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(indicatorX, indicatorY), 13, indicatorGlow);

    final indicatorCore = Paint()
      ..color = auraColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(indicatorX, indicatorY), 6.5, indicatorCore);
  }

  @override
  bool shouldRepaint(covariant _SolarArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.isDark != isDark ||
      oldDelegate.isNight != isNight;
}
