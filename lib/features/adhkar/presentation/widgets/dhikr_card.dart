import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Presentation card for an individual Dhikr item.
/// Optimized with large Arabic typography, transliteration, English translation,
/// Hadith virtue reference, and an expansive 1-tap haptic counter target surface.
class DhikrCard extends StatelessWidget {
  final DhikrItem item;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onReset;

  const DhikrCard({
    super.key,
    required this.item,
    required this.count,
    required this.onTap,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isCompleted = count >= item.targetCount;

    final displayTitle = isArabic && item.titleAr.isNotEmpty
        ? item.titleAr
        : item.titleEn;
    final displayTranslation = isArabic && item.translationAr.isNotEmpty
        ? item.translationAr
        : item.translationEn;

    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title & Reference Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          displayTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                        ),
                      ),
                      AppPressable(
                        onTap: onReset,
                        haptic: AppHapticFeedback.light,
                        borderRadius: BorderRadius.circular(20),
                        child: Tooltip(
                          message: l10n.adhkarReset,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.refresh_rounded, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Arabic Text Box
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTap,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        item.arabic,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 22,
                          height: 1.8,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Transliteration Toggle / View (Shown in non-Arabic or when available)
                  if (!isArabic && item.transliteration.isNotEmpty) ...[
                    Text(
                      item.transliteration,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  // English / Localized Translation
                  if (!isArabic || item.translationAr != item.arabic)
                    Text(
                      displayTranslation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),

                  const SizedBox(height: AppSpacing.md),

                  // Virtue / Hadith Benefit Card
                  if (item.virtue.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.reference,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.virtue,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
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

          // Interactive Tap Surface & Progress
          SizedBox(
            height: 100,
            child: AppPressable(
              onTap: onTap,
              pressedScale: 0.94,
              haptic: AppHapticFeedback.none,
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : (isDark
                            ? AppColors.primary.withValues(alpha: 0.25)
                            : AppColors.primary.withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : AppColors.primary.withValues(alpha: 0.4),
                    width: isCompleted ? 2.0 : 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.touch_app_rounded,
                            key: ValueKey('dhikr_icon_$isCompleted'),
                            color: isCompleted
                                ? const Color(0xFF10B981)
                                : AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Text(
                            '$count / ${item.targetCount}',
                            key: ValueKey('dhikr_count_$count'),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: isCompleted
                                  ? const Color(0xFF10B981)
                                  : (isDark ? Colors.white : AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
            ),
          ),
        ],
      ),
    );
  }
}
