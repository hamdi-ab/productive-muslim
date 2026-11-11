import 'package:flutter/material.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/animated_progress_ring.dart';
import 'package:productive_muslim/core/widgets/pulsing_glow.dart';
import 'package:productive_muslim/features/focus/presentation/widgets/focus_background_painters.dart';

/// Central celestial timer dial with breathing pulse, progress cursor dot,
/// and Islamic rosette geometry watermark.
class FocusTimerDial extends StatelessWidget {
  final bool isRunning;
  final int secondsRemaining;
  final int totalSeconds;

  const FocusTimerDial({
    super.key,
    required this.isRunning,
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final progress = totalSeconds > 0
        ? (secondsRemaining / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Center(
      child: PulsingGlow(
        animate: isRunning,
        minScale: 0.985,
        maxScale: 1.015,
        duration: const Duration(milliseconds: 2400),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ambient Glow
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        (isRunning
                                ? AppColors.secondary
                                : const Color(0xFF10B981))
                            .withValues(alpha: isDark ? 0.22 : 0.10),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),

            // Islamic 8-Point Rosette Watermark
            CustomPaint(
              size: const Size(160, 160),
              painter: IslamicRosettePainter(
                color: (isDark ? AppColors.secondary : AppColors.primary)
                    .withValues(alpha: isDark ? 0.11 : 0.07),
              ),
            ),

            // Animated Progress Ring with circumference glowing cursor dot
            AnimatedProgressRing(
              progress: progress,
              size: 220,
              strokeWidth: 10,
              color: isRunning ? AppColors.secondary : const Color(0xFF10B981),
              glowColor: isRunning
                  ? AppColors.secondaryLight
                  : const Color(0xFF4EDEA3),
              showCursorDot: true,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Barakah Flow pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primary.withValues(alpha: 0.45)
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppColors.primaryLight.withValues(alpha: 0.35)
                                : AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isRunning
                                    ? AppColors.secondary
                                    : const Color(0xFF10B981),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isRunning
                                                ? AppColors.secondary
                                                : const Color(0xFF10B981))
                                            .withValues(alpha: 0.8),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'BARAKAH FLOW',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.7,
                                color: isDark
                                    ? const Color(0xFF4EDEA3)
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(secondsRemaining),
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.2,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          isRunning
                              ? (isAr ? 'في تدفق...' : 'In Flow...')
                              : (isAr ? 'جاهز' : 'Ready'),
                          key: ValueKey('focus_status_$isRunning'),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        isRunning
                            ? (isAr
                                  ? 'حالة خشوع • تركيز نشط'
                                  : "Khushu' State • Active Focus")
                            : (isAr
                                  ? 'جاهز • هدوء وسكينة'
                                  : 'Ready • Calm Presence'),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.darkTextSecondary.withValues(
                                  alpha: 0.6,
                                )
                              : AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
