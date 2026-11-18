import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/plan_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Segmented capsule switcher for My Day: Overview, Tasks, Habits, and Focus.
class PlanTabSwitcher extends StatelessWidget {
  final PlanTab selectedTab;
  final ValueChanged<PlanTab> onTabChanged;
  final bool isDark;

  const PlanTabSwitcher({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.md, 4),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF18221E)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? const Color(0xFF404944).withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabPill(
                context: context,
                tab: PlanTab.overview,
                label: l10n.overview,
                icon: Icons.dashboard_outlined,
                isSelected: selectedTab == PlanTab.overview,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildTabPill(
                context: context,
                tab: PlanTab.tasks,
                label: l10n.tasks,
                icon: Icons.task_alt_rounded,
                isSelected: selectedTab == PlanTab.tasks,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildTabPill(
                context: context,
                tab: PlanTab.habits,
                label: l10n.habits,
                icon: Icons.local_fire_department_rounded,
                isSelected: selectedTab == PlanTab.habits,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildTabPill(
                context: context,
                tab: PlanTab.focus,
                label: l10n.widgetBtnFocus,
                icon: Icons.timer_outlined,
                isSelected: selectedTab == PlanTab.focus,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required BuildContext context,
    required PlanTab tab,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return AppPressable(
      onTap: () => onTabChanged(tab),
      pressedScale: 0.96,
      haptic: AppHapticFeedback.selection,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF0F4C3A), Color(0xFF004D33)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFFE9C349).withValues(alpha: 0.35),
                  width: 1,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4EDEA3).withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Builder(
          builder: (context) {
            final unselectedColor = isDark
                ? const Color(0xFFBFC9C3)
                : AppColors.textSecondary;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color: isSelected
                          ? const Color(0xFFE9C349)
                          : unselectedColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : unselectedColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
