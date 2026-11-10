import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class AdhkarCategoryTabs extends StatelessWidget {
  final DhikrCategory selectedCategory;
  final ValueChanged<DhikrCategory> onCategorySelected;
  final AppLocalizations l10n;
  final bool isDark;

  const AdhkarCategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: DhikrCategory.values.map((cat) {
          final isSelected = cat == selectedCategory;
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
        }).toList(),
      ),
    );
  }
}
