import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class AdhkarCategoryTabs extends StatelessWidget {
  static const List<DhikrCategory> phase1Categories = [
    DhikrCategory.morning,
    DhikrCategory.evening,
    DhikrCategory.postPrayer,
    DhikrCategory.general,
  ];

  final List<DhikrCategory>? categories;
  final DhikrCategory? selectedCategory;
  final ValueChanged<DhikrCategory> onCategorySelected;
  final bool isBookmarksSelected;
  final VoidCallback? onBookmarksSelected;
  final AppLocalizations l10n;
  final bool isDark;

  const AdhkarCategoryTabs({
    super.key,
    this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.isBookmarksSelected = false,
    this.onBookmarksSelected,
    required this.l10n,
    required this.isDark,
  });

  static String getCategoryLabel(
    DhikrCategory category,
    AppLocalizations l10n,
  ) {
    switch (category) {
      case DhikrCategory.morning:
        return l10n.adhkarTabMorning;
      case DhikrCategory.evening:
        return l10n.adhkarTabEvening;
      case DhikrCategory.wakingUp:
        return l10n.adhkarTabWaking;
      case DhikrCategory.sleeping:
        return l10n.adhkarTabBedtime;
      case DhikrCategory.postPrayer:
        return l10n.adhkarTabPostSalah;
      case DhikrCategory.dailySunnah:
        return l10n.adhkarTabSunnah;
      case DhikrCategory.general:
        return l10n.adhkarTabGeneral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCategories = categories ?? phase1Categories;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          ...activeCategories.map((cat) {
            final isSelected = !isBookmarksSelected && cat == selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppPressable(
                onTap: () => onCategorySelected(cat),
                pressedScale: 0.95,
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                              ? AppColors.primary.withValues(alpha: 0.35)
                              : AppColors.primary.withValues(alpha: 0.12))
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? (isDark
                                ? AppColors.secondary.withValues(alpha: 0.6)
                                : AppColors.primary.withValues(alpha: 0.4))
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06)),
                      width: isSelected ? 1.2 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                      Text(
                        getCategoryLabel(cat, l10n),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? Colors.white : AppColors.primary)
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (onBookmarksSelected != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppPressable(
                onTap: onBookmarksSelected!,
                pressedScale: 0.95,
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isBookmarksSelected
                        ? (isDark
                              ? AppColors.secondary.withValues(alpha: 0.3)
                              : AppColors.secondary.withValues(alpha: 0.15))
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isBookmarksSelected
                          ? AppColors.secondary
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06)),
                      width: isBookmarksSelected ? 1.2 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isBookmarksSelected
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        size: 15,
                        color: isBookmarksSelected
                            ? AppColors.secondary
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        l10n.adhkarTabBookmarks,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isBookmarksSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isBookmarksSelected
                              ? (isDark
                                    ? Colors.white
                                    : AppColors.secondaryDark)
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
