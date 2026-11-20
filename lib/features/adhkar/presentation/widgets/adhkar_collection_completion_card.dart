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

class AdhkarCollectionCompletionCard extends StatelessWidget {
  final DhikrCategory category;
  final List<DhikrItem> items;
  final String? description;
  final VoidCallback onDone;
  final VoidCallback onReadAgain;

  const AdhkarCollectionCompletionCard({
    super.key,
    required this.category,
    required this.items,
    this.description,
    required this.onDone,
    required this.onReadAgain,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final settings = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : null;
    final font = ArabicFontFamily.fromKey(settings?.arabicFontFamily);

    final totalTargetRepetitions = items.fold<int>(
      0,
      (sum, item) => sum + item.targetCount,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981)
                .withValues(alpha: isDark ? 0.25 : 0.15),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(AppSpacing.md),
        borderColor: const Color(0xFF10B981).withValues(alpha: 0.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.sm),

                    // Serene Emblem
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF10B981)
                              .withValues(alpha: isDark ? 0.2 : 0.12),
                          border: Border.all(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          size: 40,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Sacred Arabic Alhamdulillah Supplication
                    Text(
                      'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: font.getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      'تقبل الله طاعتكم',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: font.getTextStyle(
                        fontSize: 15,
                        color: isDark
                            ? AppColors.secondary
                            : AppColors.secondaryDark,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Friendly localized explanation
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        description ?? l10n.adhkarCollectionCompletedDesc,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Summary stats chips
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.library_books_rounded,
                                size: 13,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${items.length} Supplications',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.repeat_rounded,
                                size: 13,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$totalTargetRepetitions Repetitions',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Actions: Done & Read again
            Row(
              children: [
                Expanded(
                  child: AppPressable(
                    key: const Key('adhkar_completion_read_again_button'),
                    onTap: onReadAgain,
                    haptic: AppHapticFeedback.light,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.15),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restart_alt_rounded,
                            size: 17,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.adhkarReadAgain,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppPressable(
                    key: const Key('adhkar_completion_done_button'),
                    onTap: onDone,
                    haptic: AppHapticFeedback.medium,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.done,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
