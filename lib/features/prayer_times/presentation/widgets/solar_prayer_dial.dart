import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/app_typography_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
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

  String _getSunnahAdvice(
    String nextPrayer,
    bool isAr, {
    bool isAfterIsha = false,
  }) {
    if (isAfterIsha && nextPrayer.toLowerCase() == 'fajr') {
      return isAr
          ? 'قيام الليل والوتر: أفضل الصلاة بعد الفريضة صلاة الليل'
          : 'Qiyam & Witr: The best prayer after obligatory prayers is the night prayer';
    }
    return switch (nextPrayer.toLowerCase()) {
      'fajr' => isAr ? 'سنة الفجر: ركعتان خير من الدنيا وما فيها' : 'Sunnah: 2 Rakat before Fajr is better than the world and all in it',
      'dhuhr' =>
        isAr
            ? 'سنة الظهر: 4 ركعات قبل الفريضة وركعتان بعدها'
            : 'Sunnah: 4 Rakat before Dhuhr and 2 Rakat after',
      'asr' =>
        isAr
            ? 'سنة العصر: رحم الله امرءاً صلى قبل العصر أربعاً'
            : 'Sunnah: 4 Rakat recommended before Asr',
      'maghrib' =>
        isAr
            ? 'سنة المغرب: ركعتان مؤكدتان بعد الفريضة'
            : 'Sunnah: 2 confirmed Rakat after Maghrib',
      'isha' =>
        isAr
            ? 'سنة العشاء: ركعتان بعد العشاء يليهما الوتر والقيام'
            : 'Sunnah: 2 Rakat after Isha, followed by Witr & Qiyam',
      _ =>
        isAr
            ? 'حافظ على صلواتك في وقتها تنل بركة الوقت'
            : 'Preserve prayers in their early times to protect Barakah',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final now = DateTime.now();

    final fajr = (widget.prayerTimes.fajr as DateTime).toLocal();
    final sunrise = (widget.prayerTimes.sunrise as DateTime).toLocal();
    final dhuhr = (widget.prayerTimes.dhuhr as DateTime).toLocal();
    final asr = (widget.prayerTimes.asr as DateTime).toLocal();
    final maghrib = (widget.prayerTimes.maghrib as DateTime).toLocal();
    final isha = (widget.prayerTimes.isha as DateTime).toLocal();

    final isNight = now.isAfter(maghrib) || now.isBefore(fajr);

    double progress = 0.0;
    List<double> nodeFractions;

    if (!isNight) {
      // Daytime: from Fajr to Maghrib
      final dayDuration = maghrib.difference(fajr).inSeconds;
      final dayElapsed = now.difference(fajr).inSeconds;
      progress = dayDuration > 0 ? (dayElapsed / dayDuration) : 0.5;

      if (dayDuration > 0) {
        nodeFractions = [
          0.0,
          (sunrise.difference(fajr).inSeconds / dayDuration).clamp(0.05, 0.95),
          (dhuhr.difference(fajr).inSeconds / dayDuration).clamp(0.1, 0.95),
          (asr.difference(fajr).inSeconds / dayDuration).clamp(0.15, 0.95),
          1.0,
        ];
      } else {
        nodeFractions = [0.0, 0.2, 0.5, 0.75, 1.0];
      }
    } else {
      // Nighttime: from Maghrib to Fajr
      final fajrNext = now.isBefore(fajr)
          ? fajr
          : fajr.add(const Duration(days: 1));
      final maghribPrev = now.isAfter(maghrib)
          ? maghrib
          : maghrib.subtract(const Duration(days: 1));
      final nightDuration = fajrNext.difference(maghribPrev).inSeconds;
      final nightElapsed = now.difference(maghribPrev).inSeconds;
      progress = nightDuration > 0 ? (nightElapsed / nightDuration) : 0.5;

      if (nightDuration > 0) {
        final ishaPrev = now.isAfter(isha)
            ? isha
            : isha.subtract(const Duration(days: 1));
        final ishaFraction =
            (ishaPrev.difference(maghribPrev).inSeconds / nightDuration).clamp(
              0.05,
              0.95,
            );
        nodeFractions = [0.0, ishaFraction, 0.5, 0.75, 1.0];
      } else {
        nodeFractions = [0.0, 0.25, 0.5, 0.75, 1.0];
      }
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

    final isAfterIsha = now.isAfter(isha);
    final isTomorrowFajr =
        isAfterIsha && widget.nextPrayer.toLowerCase() == 'fajr';
    final localizedNext = isTomorrowFajr
        ? (isAr ? 'الفجر (غداً)' : 'Fajr (Tomorrow)')
        : _localizePrayerName(widget.nextPrayer, l10n);

    // Remaining duration to next prayer
    DateTime? nextTime;
    switch (widget.nextPrayer.toLowerCase()) {
      case 'fajr':
        nextTime = now.isBefore(fajr)
            ? fajr
            : fajr.add(const Duration(days: 1));
        break;
      case 'sunrise':
        nextTime = sunrise;
        break;
      case 'dhuhr':
        nextTime = dhuhr;
        break;
      case 'asr':
        nextTime = asr;
        break;
      case 'maghrib':
        nextTime = maghrib;
        break;
      case 'isha':
        nextTime = isha;
        break;
      default:
        nextTime = null;
    }

    String countdownString = '';
    String countdownMinutesSeconds = '';
    if (nextTime != null) {
      final diff = nextTime.difference(now);
      if (!diff.isNegative) {
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        final seconds = diff.inSeconds % 60;
        if (hours > 0) {
          countdownString = '${hours}h ${minutes}m ${seconds}s';
          countdownMinutesSeconds = '${hours}h ${minutes}m';
        } else {
          countdownString = '${minutes}m ${seconds}s';
          countdownMinutesSeconds = '${minutes}m ${seconds}s';
        }
      }
    }

    // High contrast theme tokens matching Stitch
    final badgeBg = isNight
        ? (isDark
              ? const Color(0xFF6366F1).withValues(alpha: 0.25)
              : const Color(0xFF6366F1).withValues(alpha: 0.12))
        : (isDark
              ? AppColors.primary.withValues(alpha: 0.22)
              : AppColors.primary.withValues(alpha: 0.12));
    final badgeText = isNight
        ? (isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA))
        : (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857));

    final headerIconColor = isNight
        ? const Color(0xFF818CF8)
        : const Color(0xFFF59E0B);
    final headerTitle = isNight
        ? (isAr ? 'مسار الليل والتهجد' : 'Night & Tahajjud Arc')
        : l10n.solarDialTitle;

    final timeFmt = DateFormat.jm();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: 24,
        blur: 16,
        color: isDark
            ? const Color(0xFF13221C).withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.9),
        borderColor: isDark
            ? AppColors.secondary.withValues(alpha: 0.28)
            : AppColors.primary.withValues(alpha: 0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Row: Arc title and current active spiritual window
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: headerIconColor.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isNight
                              ? Icons.nightlight_round
                              : Icons.wb_sunny_rounded,
                          size: 15,
                          color: headerIconColor,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs + 2),
                      Flexible(
                        child: Text(
                          headerTitle,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
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
                      horizontal: 9,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: badgeText.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      l10n.solarCurrentWindow(currentSlotName),
                      style: TextStyle(
                        color: badgeText,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),

            // 2. Celestial Arc Visual Canvas
            SizedBox(
              height: 136,
              width: double.infinity,
              child: CustomPaint(
                painter: _SolarArcPainter(
                  progress: progress.clamp(0.0, 1.0),
                  nodeFractions: nodeFractions,
                  isDark: isDark,
                  isNight: isNight,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          countdownString.isNotEmpty
                              ? '${l10n.solarNext(localizedNext)} • $countdownString'
                              : l10n.solarNext(localizedNext),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.secondary
                                : AppColors.secondaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          countdownMinutesSeconds.isNotEmpty
                              ? countdownMinutesSeconds
                              : DateFormat.jm().format(now),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          isNight
                              ? (isAr
                                    ? 'مسار الليل والتهجد'
                                    : 'Night arc • Tahajjud time')
                              : (isAr
                                    ? 'مسار الشمس: مدار نهاري'
                                    : 'Solar zenith • Declining arc'),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Horizon times: Sunrise & Sunset
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wb_twilight_rounded,
                        size: 13,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeFmt.format(sunrise),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Text(
                      isNight
                          ? (isAr
                                ? 'الثلث الأخير من الليل'
                                : 'Last Third of Night')
                          : (isAr ? 'المسار النهاري' : 'Daytime Trajectory'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.secondary
                            : AppColors.secondaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wb_sunny_rounded,
                        size: 13,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeFmt.format(maghrib),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // 4. Sunnah / Barakah advice tip footer with Dua guide link
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.spa_rounded,
                    size: 15,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getSunnahAdvice(
                        widget.nextPrayer,
                        isAr,
                        isAfterIsha: isAfterIsha,
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.primaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolarArcPainter extends CustomPainter {
  final double progress;
  final List<double> nodeFractions;
  final bool isDark;
  final bool isNight;

  _SolarArcPainter({
    required this.progress,
    required this.nodeFractions,
    required this.isDark,
    required this.isNight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.94);
    final radius = math.min(size.width * 0.44, size.height * 0.88);

    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // 1. Draw dashed horizon line
    final horizonPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = center.dx - radius - 16;
    final endX = center.dx + radius + 16;
    final y = center.dy;

    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(math.min(startX + dashWidth, endX), y),
        horizonPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // 2. Draw background track arc
    final backgroundPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // 3. Draw active illuminated progress arc
    final List<Color> gradientColors = isNight
        ? const [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFF38BDF8)]
        : const [Color(0xFF10B981), Color(0xFFD4AF37), Color(0xFFE9C349)];

    final progressPaint = Paint()
      ..shader = LinearGradient(colors: gradientColors)
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * progress,
        false,
        progressPaint,
      );
    }

    // 4. Draw node anchors along the arc
    for (final node in nodeFractions) {
      final nodeAngle = startAngle + (sweepAngle * node);
      final nx = center.dx + radius * math.cos(nodeAngle);
      final ny = center.dy + radius * math.sin(nodeAngle);
      final isPassed = progress >= node;

      final nodePaint = Paint()
        ..color = isPassed
            ? (isNight ? const Color(0xFF8B5CF6) : AppColors.primaryLight)
            : (isDark ? Colors.white24 : Colors.grey.shade400)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(nx, ny), 3.5, nodePaint);

      // Inner white dot for passed nodes
      if (isPassed) {
        final innerDot = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(nx, ny), 1.5, innerDot);
      }
    }

    // 5. Draw glowing Sun or Moon orb indicator
    final currentAngle = startAngle + (sweepAngle * progress);
    final indicatorX = center.dx + radius * math.cos(currentAngle);
    final indicatorY = center.dy + radius * math.sin(currentAngle);

    final auraColor = isNight
        ? const Color(0xFF818CF8)
        : const Color(0xFFF59E0B);

    // Outer glow aura
    final indicatorAura = Paint()
      ..color = auraColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(indicatorX, indicatorY), 14, indicatorAura);

    // Inner bright halo
    final indicatorHalo = Paint()
      ..color = auraColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(indicatorX, indicatorY), 8, indicatorHalo);

    // Core white center
    final indicatorCore = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(indicatorX, indicatorY), 4, indicatorCore);
  }

  @override
  bool shouldRepaint(covariant _SolarArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.isDark != isDark ||
      oldDelegate.isNight != isNight ||
      oldDelegate.nodeFractions != nodeFractions;
}
