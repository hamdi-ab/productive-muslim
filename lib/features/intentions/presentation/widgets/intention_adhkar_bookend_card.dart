import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';

/// Bookend Adhkar card in the Journal that links prophetic remembrance directly
/// to intention setting in the morning, and Istighfar & Muhasabah in the evening.
class IntentionAdhkarBookendCard extends StatelessWidget {
  final bool isDark;

  const IntentionAdhkarBookendCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    DhikrCategory currentCategory = DhikrCategory.morning;
    int completedCount = 0;
    int totalCount = 0;

    if (getIt.isRegistered<AdhkarService>()) {
      final adhkarService = getIt<AdhkarService>();
      final prayerService = getIt.isRegistered<PrayerTimeService>()
          ? getIt<PrayerTimeService>()
          : null;

      currentCategory = adhkarService.getCurrentContextCategory(
        prayerTimes: prayerService?.cachedPrayerTimes,
      );

      final completedIds = adhkarService.getCompletedDhikrIdsForDate(null);
      final categoryItems = AdhkarCatalog.getByCategory(currentCategory);
      totalCount = categoryItems.length;
      completedCount = categoryItems
          .where((i) => completedIds.contains(i.id))
          .length;
    }

    final isMorning =
        currentCategory == DhikrCategory.morning ||
        currentCategory == DhikrCategory.wakingUp;

    final badgeTitle = isMorning
        ? (isAr ? 'أذكار الصباح والنية' : 'MORNING ADHKAR & NIYYAH')
        : (isAr ? 'المحاسبة والاستغفار' : 'EVENING ADHKAR & ISTIGHFAR');

    final arabicDua = isMorning
        ? '«اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا»'
        : '«أَسْتَغْفِرُ اللَّهَ الَّذِي لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ»';

    final translationDua = isMorning
        ? '“O Allah, I ask You for beneficial knowledge, wholesome provision, and deeds that are accepted.”'
        : '“I seek forgiveness of Allah, besides Whom there is no deity, the Ever-Living, the Sustainer, and I repent to Him.”';

    final buttonLabel = isMorning
        ? (isAr ? 'قراءة أذكار الصباح' : 'Recite Morning Adhkar')
        : (isAr ? 'قراءة أذكار المساء' : 'Recite Evening Adhkar');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10221B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.25 : 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceSubtle
                  : const Color(0xFFF2F8F4),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isMorning
                      ? Icons.wb_sunny_rounded
                      : Icons.nights_stay_rounded,
                  size: 15,
                  color: AppColors.secondaryDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    badgeTitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.secondaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (totalCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: completedCount == totalCount
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$completedCount/$totalCount',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: completedCount == totalCount
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Content Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  arabicDua,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryDark,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  translationDua,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),

                // Action Button to open Adhkar
                AppPressable(
                  onTap: () {
                    AppHaptics.lightImpact();
                    context.push('/adhkar', extra: currentCategory);
                  },
                  pressedScale: 0.96,
                  haptic: AppHapticFeedback.light,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF0F4C3A), const Color(0xFF135D47)]
                            : [AppColors.primary, const Color(0xFF125642)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            buttonLabel,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
