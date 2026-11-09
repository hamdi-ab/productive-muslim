import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';

class BarakahAtmosphereBackground extends StatelessWidget {
  final bool isDark;

  const BarakahAtmosphereBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Subtle Islamic Geometric Watermark Lattice
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _IslamicLatticeBackgroundPainter(isDark: isDark),
            ),
          ),
        ),

        // Sacred Ambient Atmosphere Aura matching Stitch
        if (isDark) ...[
          Positioned(
            top: -60,
            left: MediaQuery.of(context).size.width / 2 - 120,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0F4C3A).withValues(alpha: 0.20),
                      const Color(0xFF0F4C3A).withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 260,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.10),
                      AppColors.secondary.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: IgnorePointer(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF004D33).withValues(alpha: 0.22),
                      const Color(0xFF0F4C3A).withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _IslamicLatticeBackgroundPainter extends CustomPainter {
  final bool isDark;

  const _IslamicLatticeBackgroundPainter({required this.isDark});

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
  bool shouldRepaint(covariant _IslamicLatticeBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
