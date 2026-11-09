import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';

/// Preset selector pills for focus intervals (Sprint, Barakah, Deep, Mastery).
class FocusPresetSelector extends StatelessWidget {
  final List<int> presets;
  final int selectedDurationMinutes;
  final ValueChanged<int> onPresetSelected;
  final bool isRunning;

  const FocusPresetSelector({
    super.key,
    this.presets = const [15, 25, 45, 60],
    required this.selectedDurationMinutes,
    required this.onPresetSelected,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    if (isRunning) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: presets.map((mins) {
            final isSelected = selectedDurationMinutes == mins;
            final tag = switch (mins) {
              15 => 'Sprint',
              25 => 'Barakah',
              45 => 'Deep',
              _ => 'Mastery',
            };
            return AppPressable(
              onTap: () {
                AppHaptics.selectionClick();
                onPresetSelected(mins);
              },
              pressedScale: 0.92,
              haptic: AppHapticFeedback.none,
              child: ChoiceChip(
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$mins min',
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 12,
                        color: isSelected
                            ? (isDark ? Colors.white : AppColors.primaryDark)
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? (isDark
                                  ? AppColors.secondary
                                  : AppColors.secondaryDark)
                            : (isDark
                                  ? AppColors.darkTextSecondary.withValues(
                                      alpha: 0.6,
                                    )
                                  : AppColors.textSecondary.withValues(
                                      alpha: 0.6,
                                    )),
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) {
                  AppHaptics.selectionClick();
                  onPresetSelected(mins);
                },
                backgroundColor: isDark
                    ? AppColors.darkSurfaceSubtle.withValues(alpha: 0.6)
                    : AppColors.surfaceSubtle,
                selectedColor: isDark
                    ? AppColors.primary.withValues(alpha: 0.45)
                    : AppColors.primary.withValues(alpha: 0.15),
                side: BorderSide(
                  color: isSelected
                      ? (isDark ? AppColors.secondary : AppColors.primary)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: isSelected ? 1.5 : 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
