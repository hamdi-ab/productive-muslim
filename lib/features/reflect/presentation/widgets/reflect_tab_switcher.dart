import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

enum ReflectTab { muhasabah, barakah }

/// Segmented capsule switcher allowing quick toggling between Muhasabah and Barakah tabs.
class ReflectTabSwitcher extends StatelessWidget {
  final ReflectTab selectedTab;
  final ValueChanged<ReflectTab> onTabChanged;
  final bool isDark;

  const ReflectTabSwitcher({
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
              flex: 6,
              child: _buildTabPill(
                context: context,
                tab: ReflectTab.muhasabah,
                label: l10n.muhasabah,
                icon: Icons.edit_note_rounded,
                isSelected: selectedTab == ReflectTab.muhasabah,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 5,
              child: _buildTabPill(
                context: context,
                tab: ReflectTab.barakah,
                label: l10n.barakah,
                icon: Icons.auto_awesome_rounded,
                isSelected: selectedTab == ReflectTab.barakah,
                isPrimary: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required BuildContext context,
    required ReflectTab tab,
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isPrimary,
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
              ? (isPrimary
                    ? const LinearGradient(
                        colors: [Color(0xFF0F4C3A), Color(0xFF004D33)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF132D24), Color(0xFF1A382E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ))
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: isPrimary
                      ? const Color(0xFFE9C349).withValues(alpha: 0.35)
                      : const Color(0xFF4EDEA3).withValues(alpha: 0.25),
                  width: 1,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: isPrimary
                        ? const Color(0xFF4EDEA3).withValues(alpha: 0.22)
                        : const Color(0xFF10B981).withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Builder(
          builder: (context) {
            final unselectedColor = isDark
                ? (isPrimary
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF94A3B8))
                : (isPrimary ? AppColors.textPrimary : AppColors.textSecondary);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: isPrimary ? 17 : 15,
                  color: isSelected
                      ? (isPrimary
                            ? const Color(0xFFE9C349)
                            : const Color(0xFF4EDEA3))
                      : unselectedColor,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : unselectedColor,
                      fontWeight: isSelected
                          ? (isPrimary ? FontWeight.bold : FontWeight.w600)
                          : (isPrimary ? FontWeight.w600 : FontWeight.w500),
                      fontSize: isPrimary ? 13.5 : 12.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
