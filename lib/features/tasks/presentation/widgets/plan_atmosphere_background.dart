import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';

/// Atmospheric background for Plan Screen with sacred geometry lattice and dual-tier ambient glows.
class PlanAtmosphereBackground extends StatelessWidget {
  final bool isDark;

  const PlanAtmosphereBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Sacred Geometry Watermark
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: PlanLatticePainter(isDark: isDark)),
          ),
        ),
        // Subtle Atmospheric Sacred Glow (Stitch style)
        Positioned(
          top: -50,
          left: 0,
          right: 0,
          height: 260,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.6),
                  radius: 0.85,
                  colors: [
                    const Color(0xFFE9C349)
                        .withValues(alpha: isDark ? 0.12 : 0.08),
                    const Color(0xFF0F4C3A)
                        .withValues(alpha: isDark ? 0.08 : 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
        // Bottom subtle emerald glow
        Positioned(
          bottom: -40,
          left: -40,
          width: 220,
          height: 220,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0F4C3A)
                        .withValues(alpha: isDark ? 0.12 : 0.04),
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

class PlanLatticePainter extends CustomPainter {
  final bool isDark;

  const PlanLatticePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? const Color(0xFF4EDEA3) : AppColors.primary)
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
  bool shouldRepaint(covariant PlanLatticePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
