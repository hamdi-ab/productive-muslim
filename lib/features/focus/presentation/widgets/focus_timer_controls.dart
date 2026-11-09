import 'package:flutter/material.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Primary action controls for timer start, pause, reset, and early completion.
class FocusTimerControls extends StatelessWidget {
  final bool isRunning;
  final int secondsRemaining;
  final int totalSeconds;
  final VoidCallback onToggleTimer;
  final VoidCallback onResetTimer;
  final VoidCallback onEndSession;

  const FocusTimerControls({
    super.key,
    required this.isRunning,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.onToggleTimer,
    required this.onResetTimer,
    required this.onEndSession,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canReset = isRunning || secondsRemaining < totalSeconds;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Reset button
          if (canReset) ...[
            AppPressable(
              onTap: onResetTimer,
              pressedScale: 0.88,
              haptic: AppHapticFeedback.none,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkSurfaceSubtle
                      : AppColors.surfaceSubtle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: const Icon(Icons.refresh_rounded, size: 22),
              ),
            ),
            const SizedBox(width: 14),
          ],

          // Main Glowing Action Button
          AppPressable(
            onTap: onToggleTimer,
            pressedScale: 0.94,
            haptic: AppHapticFeedback.none,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: isRunning
                    ? AppColors.goldGradient
                    : const LinearGradient(
                        colors: [Color(0xFF0F4C3A), Color(0xFF10B981)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isRunning
                                ? AppColors.secondary
                                : AppColors.primaryLight)
                            .withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color:
                      (isRunning
                              ? AppColors.secondaryLight
                              : AppColors.primaryLight)
                          .withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      key: ValueKey('timer_icon_$isRunning'),
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isRunning ? l10n.focusPause : l10n.focusStart,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // End Session / Muhasabah Button
          if (isRunning) ...[
            const SizedBox(width: 14),
            AppPressable(
              onTap: onEndSession,
              pressedScale: 0.88,
              haptic: AppHapticFeedback.none,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkSurfaceSubtle
                      : AppColors.surfaceSubtle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  size: 22,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
