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

    final nowMins = now.hour * 60 + now.minute;
    final fajrMins = fajr.hour * 60 + fajr.minute;
    final ishaMins = isha.hour * 60 + isha.minute;

    double progress = 0.0;
    if (nowMins >= fajrMins && nowMins <= ishaMins && ishaMins > fajrMins) {
      progress = (nowMins - fajrMins) / (ishaMins - fajrMins);
    } else if (nowMins > ishaMins) {
      final nightDuration = (24 * 60 - ishaMins) + fajrMins;
      final nightElapsed = nowMins - ishaMins;
      progress = nightDuration > 0 ? (nightElapsed / nightDuration) : 1.0;
    } else {
      final nightDuration = (24 * 60 - ishaMins) + fajrMins;
      final nightElapsed = (24 * 60 - ishaMins) + nowMins;
      progress = nightDuration > 0 ? (nightElapsed / nightDuration) : 0.0;
    }

    String currentSlotName = l10n.slotNight;
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
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
                    const Icon(
                      Icons.wb_sunny_rounded,
                      size: 18,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        l10n.solarDialTitle,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
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
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.solarCurrentWindow(currentSlotName),
                    style: const TextStyle(
                      color: AppColors.primary,
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
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.jm().format(now),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.solarNext(localizedNext),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
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

  _SolarArcPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final radius = math.min(size.width * 0.42, size.height * 0.85);

    const startAngle = math.pi;
    const sweepAngle = math.pi;

    final backgroundPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFF10B981), Color(0xFF6366F1)],
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

    // Draw Sun Indicator dot
    final currentAngle = startAngle + (sweepAngle * progress);
    final sunX = center.dx + radius * math.cos(currentAngle);
    final sunY = center.dy + radius * math.sin(currentAngle);

    final sunGlow = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sunX, sunY), 12, sunGlow);

    final sunCore = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sunX, sunY), 6, sunCore);
  }

  @override
  bool shouldRepaint(covariant _SolarArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
