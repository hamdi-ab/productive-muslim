import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';

/// Single prayer entry tile with glassmorphism styling, live status badges,
/// Arabic calligraphy label, and notification icons.
class PrayerTile extends StatelessWidget {
  final String name;
  final String arabicName;
  final IconData icon;
  final String subtitle;
  final String time;
  final bool isNext;
  final bool isPassed;
  final bool isAstronomical;
  final String? tag;

  const PrayerTile({
    super.key,
    required this.name,
    required this.arabicName,
    required this.icon,
    required this.subtitle,
    required this.time,
    required this.isNext,
    required this.isPassed,
    this.isAstronomical = false,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    Color cardColor;
    Color borderColor;
    if (isNext) {
      cardColor = isDark
          ? const Color(0xFF132A22)
          : AppColors.primary.withValues(alpha: 0.12);
      borderColor = isDark ? AppColors.secondary : AppColors.primary;
    } else if (isPassed) {
      cardColor = isDark
          ? const Color(0xFF0F1815).withValues(alpha: 0.6)
          : Colors.grey.shade50.withValues(alpha: 0.8);
      borderColor = isDark
          ? AppColors.borderDark.withValues(alpha: 0.4)
          : AppColors.borderLight.withValues(alpha: 0.5);
    } else {
      cardColor = isDark
          ? AppColors.darkSurface.withValues(alpha: 0.75)
          : Colors.white.withValues(alpha: 0.75);
      borderColor = isDark
          ? AppColors.borderDark
          : AppColors.borderLight.withValues(alpha: 0.6);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 3.5,
      ),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        borderRadius: 18,
        blur: 15,
        color: cardColor,
        borderColor: borderColor,
        child: Row(
          children: [
            // Status Icon Indicator
            Container(
              padding: const EdgeInsets.all(7.5),
              decoration: BoxDecoration(
                color: isNext
                    ? (isDark
                          ? AppColors.secondary.withValues(alpha: 0.22)
                          : AppColors.primary.withValues(alpha: 0.18))
                    : (isPassed && !isAstronomical)
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : (isDark
                          ? AppColors.darkSurfaceSubtle
                          : AppColors.surfaceSubtle),
                shape: BoxShape.circle,
                border: isNext
                    ? Border.all(
                        color: isDark ? AppColors.secondary : AppColors.primary,
                        width: 1.2,
                      )
                    : (isPassed && !isAstronomical)
                    ? Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        width: 0.8,
                      )
                    : (isPassed && isAstronomical)
                    ? Border.all(
                        color: isDark
                            ? AppColors.borderDark.withValues(alpha: 0.4)
                            : AppColors.borderLight.withValues(alpha: 0.5),
                        width: 0.8,
                      )
                    : null,
              ),
              child: Icon(
                (isPassed && !isAstronomical) ? Icons.check_rounded : icon,
                size: 16,
                color: isNext
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : (isPassed && !isAstronomical)
                    ? const Color(0xFF10B981)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 10),
            // Prayer Details: Name, Arabic script, Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    runSpacing: 2,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isNext
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isNext
                              ? (isDark
                                    ? AppColors.secondary
                                    : AppColors.primary)
                              : isPassed
                              ? (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary)
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary),
                        ),
                      ),
                      if (!isAr)
                        Text(
                          arabicName,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 12,
                            color: isNext
                                ? AppColors.secondary.withValues(alpha: 0.85)
                                : (isDark
                                      ? AppColors.secondary.withValues(
                                          alpha: 0.6,
                                        )
                                      : AppColors.textSecondary.withValues(
                                          alpha: 0.7,
                                        )),
                          ),
                        ),
                      if (isPassed && !isAstronomical)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.25),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            isAr ? 'انقضى' : 'Past',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      if (tag != null && !isPassed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            tag!,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.secondary
                                  : AppColors.secondaryDark,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isNext)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2.5,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                color: isNext
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : isPassed
                    ? (isDark
                          ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
                          : AppColors.textSecondary.withValues(alpha: 0.7))
                    : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isNext
                  ? Icons.notifications_active_rounded
                  : (isPassed && !isAstronomical)
                  ? Icons.check_circle_outline_rounded
                  : isAstronomical
                  ? Icons.wb_sunny_outlined
                  : Icons.notifications_none_rounded,
              size: 15,
              color: isNext
                  ? (isDark ? AppColors.secondary : AppColors.primary)
                  : (isPassed && !isAstronomical)
                  ? const Color(0xFF10B981).withValues(alpha: 0.6)
                  : (isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.4)
                        : AppColors.textSecondary.withValues(alpha: 0.4)),
            ),
          ],
        ),
      ),
    );
  }
}
