import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';

/// Atmospheric background for Intention Screen with subtle Islamic geometric
/// lattice watermark and celestial glow auras.
class IntentionAtmosphereBackground extends StatelessWidget {
  final bool isDark;

  const IntentionAtmosphereBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Subtle Islamic Geometric Watermark Lattice
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: IslamicLatticeBackgroundPainter(isDark: isDark),
            ),
          ),
        ),

        // Celestial Ambient Glow Auras matching Stitch Luxury System
        Positioned(
          top: -60,
          left: screenWidth / 2 - 120,
          child: IgnorePointer(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.08),
                    AppColors.primary.withValues(alpha: isDark ? 0.05 : 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          right: -40,
          child: IgnorePointer(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: isDark ? 0.12 : 0.06),
                    AppColors.secondary.withValues(alpha: isDark ? 0.02 : 0.01),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IslamicLatticeBackgroundPainter extends CustomPainter {
  final bool isDark;
  const IslamicLatticeBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? const Color(0xFF10B981) : AppColors.primary)
          .withValues(alpha: isDark ? 0.025 : 0.015)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const step = 56.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        canvas.drawCircle(Offset(x, y), step * 0.35, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant IslamicLatticeBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
