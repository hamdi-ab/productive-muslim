import 'dart:math';

import 'package:flutter/material.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';

/// Subtle Islamic geometric lattice watermark painter for background ambiance.
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

/// Geometric Khatam / 8-pointed star Islamic rosette watermark.
class IslamicRosettePainter extends CustomPainter {
  final Color color;

  const IslamicRosettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final side = size.width * 0.54;
    final rect = Rect.fromCenter(center: center, width: side, height: side);

    // Square 1
    canvas.drawRect(rect, paint);

    // Square 2 (rotated 45 degrees)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 4);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: side, height: side),
      paint,
    );
    canvas.restore();

    // Concentric celestial guidance rings
    canvas.drawCircle(center, side * 0.58, paint);
    canvas.drawCircle(center, side * 0.28, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicRosettePainter oldDelegate) =>
      oldDelegate.color != color;
}
