import 'dart:math';

import 'package:flutter/material.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';

class AnimatedProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final Color? glowColor;
  final bool showCursorDot;
  final Widget? child;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.size = 64,
    this.strokeWidth = 6,
    this.color,
    this.backgroundColor,
    this.glowColor,
    this.showCursorDot = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.secondary;
    final trackColor =
        backgroundColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white10
            : Colors.black12);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  progress: val,
                  strokeWidth: strokeWidth,
                  color: activeColor,
                  backgroundColor: trackColor,
                  glowColor: glowColor,
                  showCursorDot: showCursorDot,
                ),
              );
            },
          ),
          ?child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final Color? glowColor;
  final bool showCursorDot;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
    this.glowColor,
    this.showCursorDot = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress Arc
    if (progress > 0) {
      if (glowColor != null) {
        final glowPaint = Paint()
          ..color = glowColor!.withValues(alpha: 0.35)
          ..strokeWidth = strokeWidth + 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

        final startAngle = -pi / 2;
        final sweepAngle = 2 * pi * progress;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          glowPaint,
        );
      }

      final fgPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final startAngle = -pi / 2;
      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        fgPaint,
      );

      if (showCursorDot) {
        final tipAngle = startAngle + sweepAngle;
        final dotX = center.dx + radius * cos(tipAngle);
        final dotY = center.dy + radius * sin(tipAngle);
        final dotCenter = Offset(dotX, dotY);

        if (glowColor != null) {
          final dotGlow = Paint()
            ..color = glowColor!.withValues(alpha: 0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
          canvas.drawCircle(dotCenter, strokeWidth * 0.9, dotGlow);
        }

        final dotPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(dotCenter, strokeWidth * 0.6, dotPaint);

        final innerDot = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(dotCenter, strokeWidth * 0.3, innerDot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.showCursorDot != showCursorDot;
  }
}
