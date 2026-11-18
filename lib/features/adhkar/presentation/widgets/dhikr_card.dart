import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/arabic_typography.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Custom painter for the circular Tasbih bead gauge with authentic 33-bead track
class _TasbihProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  const _TasbihProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;

    // Background track ring
    final trackPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, trackPaint);

    // Beaded track dots (33 beads)
    final beadPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;
    const int beadCount = 33;
    for (int i = 0; i < beadCount; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / beadCount);
      final bx = center.dx + radius * math.cos(angle);
      final by = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(bx, by), 1.5, beadPaint);
    }

    // Active progress arc with ambient glow and circumference indicator dot
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

      // Soft ambient glow
      final glowPaint = Paint()
        ..color = progressColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );

      // Crisp core progress arc
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4.0;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Tip indicator dot on ring circumference
      final tipAngle = -math.pi / 2 + sweepAngle;
      final tipX = center.dx + radius * math.cos(tipAngle);
      final tipY = center.dy + radius * math.sin(tipAngle);
      final tipCenter = Offset(tipX, tipY);

      final tipGlow = Paint()
        ..color = progressColor.withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(tipCenter, 4.5, tipGlow);

      final tipCore = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(tipCenter, 2.2, tipCore);
    }
  }

  @override
  bool shouldRepaint(_TasbihProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

/// Presentation card for an individual Dhikr item.
/// Optimized with large Arabic typography, transliteration, English translation,
/// Hadith virtue reference, and an expansive tactile haptic counter target surface.
class DhikrCard extends StatelessWidget {
  final DhikrItem item;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onReset;
  final int? index;
  final int? total;
  final bool isBookmarked;
  final VoidCallback? onToggleBookmark;
  final bool showTransliteration;

  const DhikrCard({
    super.key,
    required this.item,
    required this.count,
    required this.onTap,
    required this.onReset,
    this.index,
    this.total,
    this.isBookmarked = false,
    this.onToggleBookmark,
    this.showTransliteration = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isCompleted = count >= item.targetCount;
    final progress = item.targetCount > 0
        ? (count / item.targetCount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (item.targetCount - count).clamp(0, item.targetCount);

    final settings = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : null;
    final font = ArabicFontFamily.fromKey(settings?.arabicFontFamily);
    final fontSize = settings?.arabicFontSize ?? 22.0;

    final displayTitle = isArabic && item.titleAr.isNotEmpty
        ? item.titleAr
        : item.titleEn;
    final displayTranslation = isArabic && item.translationAr.isNotEmpty
        ? item.translationAr
        : item.translationEn;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? const Color(0xFF10B981)
                      .withValues(alpha: isDark ? 0.22 : 0.14)
                : AppColors.secondary.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(AppSpacing.md),
        borderColor: isCompleted
            ? const Color(0xFF10B981).withValues(alpha: 0.5)
            : (isDark
                  ? AppColors.secondary.withValues(alpha: 0.35)
                  : AppColors.secondary.withValues(alpha: 0.4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Meta Row: Dhikr Index Badge + Authentic Badge + Reset Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (index != null && total != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkSurfaceSubtle
                                        : AppColors.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.secondary.withValues(
                                        alpha: 0.35,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Dhikr $index of $total',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.secondary
                                          : AppColors.secondaryDark,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              if (item.isApproved)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.primaryLight.withValues(
                                            alpha: 0.14,
                                          )
                                        : AppColors.primary.withValues(
                                            alpha: 0.08,
                                          ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primaryLight.withValues(
                                        alpha: 0.25,
                                      ),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        size: 13,
                                        color: isDark
                                            ? AppColors.primaryLight
                                            : AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Authentic',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? AppColors.primaryLight
                                                : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(
                                      alpha: isDark ? 0.18 : 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.amber.withValues(
                                        alpha: 0.4,
                                      ),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.hourglass_top_rounded,
                                        size: 13,
                                        color: isDark
                                            ? const Color(0xFFFCD34D)
                                            : const Color(0xFFD97706),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          l10n.adhkarPendingReview,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? const Color(0xFFFCD34D)
                                                : const Color(0xFFD97706),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : Colors.black.withValues(alpha: 0.08),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  item.isCountPrescribed
                                      ? l10n.adhkarPrescribedCount
                                      : l10n.adhkarRecommendedTarget,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (onToggleBookmark != null) ...[
                              AppPressable(
                                onTap: onToggleBookmark!,
                                haptic: AppHapticFeedback.light,
                                borderRadius: BorderRadius.circular(20),
                                child: Tooltip(
                                  message: isBookmarked
                                      ? l10n.adhkarBookmarkRemove
                                      : l10n.adhkarBookmarkAdd,
                                  child: Container(
                                    padding: const EdgeInsets.all(7.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isBookmarked
                                          ? AppColors.secondary.withValues(
                                              alpha: isDark ? 0.25 : 0.15,
                                            )
                                          : (isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.06,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.04,
                                                  )),
                                    ),
                                    child: Icon(
                                      isBookmarked
                                          ? Icons.bookmark_rounded
                                          : Icons.bookmark_outline_rounded,
                                      size: 18,
                                      color: isBookmarked
                                          ? AppColors.secondary
                                          : (isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.textSecondary),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            AppPressable(
                              onTap: onReset,
                              haptic: AppHapticFeedback.light,
                              borderRadius: BorderRadius.circular(20),
                              child: Tooltip(
                                message: l10n.adhkarReset,
                                child: Container(
                                  padding: const EdgeInsets.all(7.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : Colors.black.withValues(alpha: 0.04),
                                  ),
                                  child: Icon(
                                    Icons.restart_alt_rounded,
                                    size: 18,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Title
                    Text(
                      displayTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Arabic Text Box (Sacred Geometry & Tap-to-count surface)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onTap,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF07120E).withValues(alpha: 0.7)
                              : AppColors.primary.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isCompleted
                                ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                : AppColors.secondary.withValues(alpha: 0.2),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          item.arabic,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: font.getTextStyle(
                            fontSize: fontSize,
                            height: 1.85,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Transliteration (optional)
                    if (showTransliteration &&
                        !isArabic &&
                        item.transliteration.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '"${item.transliteration}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                            color: isDark
                                ? AppColors.primaryLight.withValues(alpha: 0.9)
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],

                    // English / Localized Translation
                    if (!isArabic || item.translationAr != item.arabic)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          displayTranslation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.black87,
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.md),

                    // Hadith Virtue Callout Box
                    if (item.virtue.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.secondary.withValues(alpha: 0.12)
                              : AppColors.secondary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 17,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.virtue,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      height: 1.4,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (item.reference.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '— ${item.reference}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.secondary
                                            : AppColors.secondaryDark,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Interactive Tactile Counter Trigger (Tasbih Dial)
            SizedBox(
              height: 104,
              child: AppPressable(
                onTap: onTap,
                pressedScale: 0.95,
                haptic: AppHapticFeedback.none,
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF10B981).withValues(alpha: 0.18)
                        : (isDark
                              ? const Color(0xFF0F261E)
                              : AppColors.primary.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFF10B981)
                          : (isDark
                                ? AppColors.secondary.withValues(alpha: 0.45)
                                : AppColors.primary.withValues(alpha: 0.25)),
                      width: isCompleted ? 2.0 : 1.4,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Circular Radial Meter Gauge
                      SizedBox(
                        width: 74,
                        height: 74,
                        child: CustomPaint(
                          painter: _TasbihProgressPainter(
                            progress: progress,
                            trackColor: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08),
                            progressColor: isCompleted
                                ? const Color(0xFF10B981)
                                : AppColors.secondary,
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.touch_app_rounded,
                                key: ValueKey('tasbih_status_$isCompleted'),
                                color: isCompleted
                                    ? const Color(0xFF10B981)
                                    : (isDark
                                          ? AppColors.secondary
                                          : AppColors.primary),
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Count, Remaining Badge & Tap prompt text
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 150),
                                    transitionBuilder: (child, anim) =>
                                        ScaleTransition(
                                          scale: anim,
                                          child: child,
                                        ),
                                    child: Text(
                                      '$count / ${item.targetCount}',
                                      key: ValueKey('dhikr_count_$count'),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                        color: isCompleted
                                            ? const Color(0xFF10B981)
                                            : (isDark
                                                  ? Colors.white
                                                  : AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? const Color(0xFF10B981)
                                                .withValues(alpha: 0.2)
                                          : (isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.08,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.05,
                                                  )),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      remaining > 0
                                          ? '$remaining remaining'
                                          : 'Done',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isCompleted
                                            ? const Color(0xFF10B981)
                                            : (isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors.textSecondary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isCompleted
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.touch_app_rounded,
                                    size: 13,
                                    color: isCompleted
                                        ? const Color(0xFF10B981)
                                        : (isDark
                                              ? AppColors.secondary
                                              : AppColors.primary),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isCompleted
                                        ? l10n.adhkarCompleted
                                        : l10n.adhkarTapToCount,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isCompleted
                                          ? const Color(0xFF10B981)
                                          : (isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
