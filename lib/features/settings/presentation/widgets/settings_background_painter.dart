import 'package:flutter/material.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';

/// Subtle Islamic geometric lattice watermark painter for background ambiance.
class SettingsIslamicLatticeBackgroundPainter extends CustomPainter {
  final bool isDark;

  const SettingsIslamicLatticeBackgroundPainter({required this.isDark});

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
  bool shouldRepaint(
    covariant SettingsIslamicLatticeBackgroundPainter oldDelegate,
  ) => oldDelegate.isDark != isDark;
}
