import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';

class FloatingNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class FloatingGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNavItem> items;

  const FloatingGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        borderRadius: 32,
        blur: 24,
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.90),
        borderColor: isDark
            ? Colors.white.withValues(alpha: 0.14)
            : AppColors.primary.withValues(alpha: 0.12),
        child: Row(
          children: List.generate(items.length, (index) {
            final isSelected = index == currentIndex;
            final item = items[index];

            return Expanded(
              child: Semantics(
                label: item.label,
                button: true,
                selected: isSelected,
                excludeSemantics: true,
                child: AppPressable(
                  onTap: () => onTap(index),
                  pressedScale: 0.92,
                  haptic: AppHapticFeedback.selection,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Indicator pill around the icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                      ? AppColors.primaryLight.withValues(
                                          alpha: 0.16,
                                        )
                                      : AppColors.primary.withValues(
                                          alpha: 0.12,
                                        ))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(
                                    color: isDark
                                        ? AppColors.primaryLight.withValues(
                                            alpha: 0.28,
                                          )
                                        : AppColors.primary.withValues(
                                            alpha: 0.20,
                                          ),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutBack,
                            scale: isSelected ? 1.08 : 1.0,
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              size: 21,
                              color: isSelected
                                  ? (isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary)
                                  : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark
                                            ? AppColors.primaryLight
                                            : AppColors.primary)
                                      : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary),
                                  letterSpacing: -0.1,
                                ),
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
