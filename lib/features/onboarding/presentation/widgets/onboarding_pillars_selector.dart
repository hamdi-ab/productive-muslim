import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class OnboardingPillarsSelector extends StatelessWidget {
  final List<String> selectedPillars;
  final ValueChanged<String> onToggle;
  final bool isDark;

  const OnboardingPillarsSelector({
    super.key,
    required this.selectedPillars,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pillars = [
      (
        id: 'remember',
        label: l10n.pillarRemember,
        desc: l10n.pillarRememberDesc,
        icon: Icons.flare_rounded,
      ),
      (
        id: 'pray',
        label: l10n.pillarPray,
        desc: l10n.pillarPrayDesc,
        icon: Icons.mosque_rounded,
      ),
      (
        id: 'act',
        label: l10n.pillarAct,
        desc: l10n.pillarActDesc,
        icon: Icons.checklist_rtl_rounded,
      ),
      (
        id: 'reflect',
        label: l10n.pillarReflect,
        desc: l10n.pillarReflectDesc,
        icon: Icons.menu_book_rounded,
      ),
      (
        id: 'grow',
        label: l10n.pillarGrow,
        desc: l10n.pillarGrowDesc,
        icon: Icons.spa_rounded,
      ),
    ];

    return Column(
      children: pillars.map((p) {
        final isSelected = selectedPillars.contains(p.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onToggle(p.id),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                          ? AppColors.secondary.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.10))
                    : (isDark
                          ? AppColors.darkSurfaceSubtle
                          : AppColors.surfaceSubtle),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.secondary : AppColors.primary)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06)),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? (isDark
                                ? AppColors.secondary.withValues(alpha: 0.3)
                                : AppColors.primary.withValues(alpha: 0.18))
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04)),
                    ),
                    child: Icon(
                      p.icon,
                      size: 22,
                      color: isSelected
                          ? (isDark ? AppColors.secondary : AppColors.primary)
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? (isDark
                                      ? AppColors.secondary
                                      : AppColors.primary)
                                : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.desc,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? (isDark ? AppColors.secondary : AppColors.primary)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.2)),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
