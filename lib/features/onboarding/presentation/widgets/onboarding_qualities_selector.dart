import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class OnboardingQualitiesSelector extends StatelessWidget {
  final List<String> selectedQualities;
  final ValueChanged<String> onToggle;
  final bool isDark;

  const OnboardingQualitiesSelector({
    super.key,
    required this.selectedQualities,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final qualities = [
      (id: 'taqwa', label: l10n.qualityTaqwa, icon: Icons.mosque_outlined),
      (id: 'ikhlas', label: l10n.qualityIkhlas, icon: Icons.favorite_outline),
      (
        id: 'sabr',
        label: l10n.qualitySabr,
        icon: Icons.hourglass_empty_outlined,
      ),
      (id: 'shukr', label: l10n.qualityShukr, icon: Icons.thumb_up_outlined),
      (
        id: 'tawakkul',
        label: l10n.qualityTawakkul,
        icon: Icons.shield_outlined,
      ),
      (id: 'ihsan', label: l10n.qualityIhsan, icon: Icons.star_outline),
      (id: 'ilm', label: l10n.qualityIlm, icon: Icons.menu_book_outlined),
      (id: 'dawah', label: l10n.qualityDawah, icon: Icons.campaign_outlined),
      (id: 'ummah', label: l10n.qualityUmmah, icon: Icons.groups_outlined),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: qualities.map((q) {
        final selected = selectedQualities.contains(q.id);
        return InkWell(
          onTap: () => onToggle(q.id),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? (isDark
                        ? AppColors.secondary.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.12))
                  : (isDark
                        ? AppColors.darkSurfaceSubtle
                        : AppColors.surfaceSubtle),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  q.icon,
                  size: 18,
                  color: selected
                      ? (isDark ? AppColors.secondary : AppColors.primary)
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  q.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected
                        ? (isDark ? AppColors.secondary : AppColors.primary)
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
