import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';

/// Meter card calculating and showing spiritual vs worldly completion alignment with a radial gauge.
class PlanBarakahAlignmentMeter extends StatelessWidget {
  final String formattedDate;
  final bool isDark;

  const PlanBarakahAlignmentMeter({
    super.key,
    required this.formattedDate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: context.read<TaskRepository>().watchTasksForDate(formattedDate),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        final totalTasks = tasks.length;
        final completedTasks = tasks.where((t) => t.completed).length;

        final percent = totalTasks > 0
            ? (completedTasks / totalTasks * 100).round()
            : 0;

        return Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            10,
            AppSpacing.md,
            0,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141E1A) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? const Color(0xFFE9C349).withValues(alpha: 0.25)
                  : AppColors.secondary.withValues(alpha: 0.18),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF0F4C3A) : Colors.black)
                    .withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Intention Alignment',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFFBFC9C3)
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          totalTasks == 0
                              ? 'Daily Intention Alignment'
                              : '$completedTasks of $totalTasks Tasks Completed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFDAE5E0)
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(44, 44),
                          painter: GaugeRingPainter(
                            progress: percent / 100,
                            trackColor: isDark
                                ? const Color(0xFF2D3733)
                                : Colors.black.withValues(alpha: 0.06),
                            progressColor: const Color(0xFFE9C349),
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE9C349),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Segmented 10-bar progress indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 6,
                  child: Row(
                    children: List.generate(10, (idx) {
                      final segmentPercent = (idx + 1) * 10;
                      final isFilled = percent >= segmentPercent;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: idx < 9 ? 2 : 0),
                          decoration: BoxDecoration(
                            color: isFilled
                                ? (idx < 7
                                      ? const Color(0xFF4EDEA3)
                                      : const Color(0xFFE9C349))
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.06)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GaugeRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  GaugeRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GaugeRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
