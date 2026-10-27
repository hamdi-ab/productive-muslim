import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';

class BarakahMuhasabahAuditCard extends StatefulWidget {
  const BarakahMuhasabahAuditCard({super.key});

  @override
  State<BarakahMuhasabahAuditCard> createState() =>
      _BarakahMuhasabahAuditCardState();
}

class _BarakahMuhasabahAuditCardState extends State<BarakahMuhasabahAuditCard> {
  int _rating = 4;
  final Set<String> _passedCheckpoints = {
    "Fajr in Jama'ah",
    "Morning Adhkar",
    "Mindful Eating",
    "Tongue Guarded",
  };

  static const List<String> allCheckpoints = [
    "Fajr in Jama'ah",
    "Morning Adhkar",
    "Mindful Eating",
    "Tongue Guarded",
    "Evening Adhkar",
    "Quran Tadabbur",
  ];

  void _toggleCheckpoint(String item) {
    AppHaptics.selectionClick();
    setState(() {
      if (_passedCheckpoints.contains(item)) {
        _passedCheckpoints.remove(item);
      } else {
        _passedCheckpoints.add(item);
      }
    });
  }

  void _setRating(int value) {
    AppHaptics.mediumImpact();
    setState(() => _rating = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.35)
              : AppColors.secondary.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.3 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.psychology_alt_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAr
                        ? 'محاسبة الخشوع والتركيز'
                        : "Spiritual Focus & Khushu' Audit",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: const Text(
                  'Muhasabah',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Star Rating Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground
                  : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr
                      ? 'تقييم الحضور القلبي اليوم:'
                      : "Rate Today's Spiritual Focus:",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(5, (index) {
                      final starNum = index + 1;
                      final isFilled = starNum <= _rating;
                      return InkWell(
                        onTap: () => _setRating(starNum),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            isFilled
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 21,
                            color: isFilled
                                ? AppColors.secondary
                                : (isDark
                                      ? AppColors.darkTextSecondary.withValues(
                                          alpha: 0.4,
                                        )
                                      : AppColors.textSecondary.withValues(
                                          alpha: 0.4,
                                        )),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      '$_rating/5',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Audit Checkpoints
          Text(
            isAr ? 'المعالم المتحققة اليوم:' : 'Audit Checkpoints Passed:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: allCheckpoints.map((item) {
              final isPassed = _passedCheckpoints.contains(item);
              return InkWell(
                onTap: () => _toggleCheckpoint(item),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPassed
                        ? AppColors.primary.withValues(
                            alpha: isDark ? 0.25 : 0.12,
                          )
                        : (isDark
                              ? AppColors.darkSurfaceSubtle
                              : AppColors.surfaceSubtle),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPassed
                          ? AppColors.primaryLight.withValues(alpha: 0.6)
                          : (isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isPassed
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isPassed
                              ? (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.primary)
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isPassed
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        size: 13,
                        color: isPassed
                            ? AppColors.primaryLight
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Concluding Night Dua
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.secondary.withValues(alpha: 0.08)
                  : const Color(0xFFFEF3C7).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.nights_stay_rounded,
                  size: 17,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAr
                        ? '«اللهم اغفر لي تقصيري اليوم، وبارك لي في فجري غداً»'
                        : '"O Allah, forgive my lapses today and multiply the barakah in my dawn tomorrow."',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.3,
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
