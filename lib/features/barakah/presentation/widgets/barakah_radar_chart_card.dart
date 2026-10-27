import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';

class BarakahQualityDimension {
  final String key;
  final String nameEn;
  final String nameAr;
  final double score; // 0.0 to 100.0
  final Color color;

  const BarakahQualityDimension({
    required this.key,
    required this.nameEn,
    required this.nameAr,
    required this.score,
    required this.color,
  });
}

class BarakahRadarChartCard extends StatefulWidget {
  final List<BarakahQualityDimension>? dimensions;

  const BarakahRadarChartCard({super.key, this.dimensions});

  @override
  State<BarakahRadarChartCard> createState() => _BarakahRadarChartCardState();
}

class _BarakahRadarChartCardState extends State<BarakahRadarChartCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  static const List<BarakahQualityDimension> defaultDimensions = [
    BarakahQualityDimension(
      key: 'ruh',
      nameEn: 'Ruh (Spiritual)',
      nameAr: 'الروح',
      score: 88,
      color: Color(0xFFE9C349),
    ),
    BarakahQualityDimension(
      key: 'jism',
      nameEn: 'Jism (Physical)',
      nameAr: 'الجسد',
      score: 82,
      color: Color(0xFF6FFBBE),
    ),
    BarakahQualityDimension(
      key: 'ummah',
      nameEn: 'Ummah (Social)',
      nameAr: 'الأمة',
      score: 78,
      color: Color(0xFF4EDEA3),
    ),
    BarakahQualityDimension(
      key: 'aql',
      nameEn: 'Aql (Mindset)',
      nameAr: 'العقل',
      score: 90,
      color: Color(0xFFE9C349),
    ),
    BarakahQualityDimension(
      key: 'istiqamah',
      nameEn: 'Istiqaamah',
      nameAr: 'الاستقامة',
      score: 94,
      color: Color(0xFFFFE088),
    ),
    BarakahQualityDimension(
      key: 'khushu',
      nameEn: "Khushu' (Focus)",
      nameAr: 'الخشوع',
      score: 72,
      color: Color(0xFFFFB4AB),
    ),
    BarakahQualityDimension(
      key: 'niyyah',
      nameEn: 'Niyyah (Intention)',
      nameAr: 'النية',
      score: 86,
      color: Color(0xFF4EDEA3),
    ),
    BarakahQualityDimension(
      key: 'shukr',
      nameEn: 'Shukr (Gratitude)',
      nameAr: 'الشكر',
      score: 91,
      color: Color(0xFFE9C349),
    ),
    BarakahQualityDimension(
      key: 'ihsan',
      nameEn: 'Ihsan (Excellence)',
      nameAr: 'الإحسان',
      score: 85,
      color: Color(0xFF6FFBBE),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final items = widget.dimensions ?? defaultDimensions;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.35)
              : AppColors.secondary.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.3 : 0.06,
            ),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.hub_rounded,
                        size: 18,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isAr
                            ? 'أبعاد البركة التسعة'
                            : 'Productive Muslim 9 Qualities',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.45),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      size: 13,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAr
                          ? '٨٤/١٠٠ • رتبة الإحسان'
                          : '84 / 100 • Al-Ihsan Tier',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isAr
                ? 'تقييم شامل وموحد للحالة الروحية، والعمل الواعي، والاستمرارية البدنية.'
                : 'Synthesized alignment of spiritual state, intentional action, and physical consistency.',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Radar Spider Chart Canvas
          SizedBox(
            height: 275,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _NonagonRadarPainter(
                    dimensions: items,
                    progress: _animation.value,
                    isDark: isDark,
                    isAr: isAr,
                  ),
                  child: Container(),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Insight Badges: Full-width stacked cards to guarantee zero pixel overflow on any viewport
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    isAr
                        ? 'أعلى نقطة قوة: الاستقامة • ٩٤٪'
                        : 'Top Strength: Consistency (Istiqaamah) • 94%',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(
                alpha: isDark ? 0.18 : 0.08,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.priority_high_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    isAr
                        ? 'فرصة النمو: الخشوع • ٧٢٪'
                        : "Growth Focus: Khushu' (Focus) • 72%",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    AppHaptics.selectionClick();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAr ? 'تحسين' : 'Improve',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NonagonRadarPainter extends CustomPainter {
  final List<BarakahQualityDimension> dimensions;
  final double progress;
  final bool isDark;
  final bool isAr;

  _NonagonRadarPainter({
    required this.dimensions,
    required this.progress,
    required this.isDark,
    required this.isAr,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = dimensions.length;
    if (n < 3) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.34;

    // Grid ring paint
    final ringPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.primary).withValues(
        alpha: 0.12,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    // Spoke ray paint
    final spokePaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.primary).withValues(
        alpha: 0.12,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // 1. Draw 5 Concentric Nonagon Rings (20%, 40%, 60%, 80%, 100%)
    const ringLevels = [0.20, 0.40, 0.60, 0.80, 1.0];
    for (final level in ringLevels) {
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = -math.pi / 2 + i * (2 * math.pi / n);
        final r = maxRadius * level;
        final point = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, ringPaint);
    }

    // 2. Draw Spoke Rays from Center to 100% Perimeter
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + i * (2 * math.pi / n);
      final outer = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );
      canvas.drawLine(center, outer, spokePaint);
    }

    // 3. Compute Value Polygon Points
    final dataPoints = <Offset>[];
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + i * (2 * math.pi / n);
      final scoreRatio = (dimensions[i].score / 100.0) * progress;
      final r = maxRadius * scoreRatio;
      dataPoints.add(
        Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        ),
      );
    }

    // 4. Fill Data Polygon with Radial Gradient
    final polyPath = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      if (i == 0) {
        polyPath.moveTo(dataPoints[i].dx, dataPoints[i].dy);
      } else {
        polyPath.lineTo(dataPoints[i].dx, dataPoints[i].dy);
      }
    }
    polyPath.close();

    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4EDEA3).withValues(alpha: 0.55),
          const Color(0xFF0F4C3A).withValues(alpha: 0.38),
          const Color(0xFFE9C349).withValues(alpha: 0.45),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;
    canvas.drawPath(polyPath, fillPaint);

    // 5. Stroke Data Polygon
    final strokePaint = Paint()
      ..color = const Color(0xFFE9C349)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(polyPath, strokePaint);

    // 6. Draw Vertices (Glow Dots) & Labels
    for (int i = 0; i < n; i++) {
      final p = dataPoints[i];
      final item = dimensions[i];
      final isTopStrength = item.score >= 93;

      // Glow halo for top strength
      if (isTopStrength) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFFE088).withValues(alpha: 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p, 7.5, glowPaint);
      }

      // Outer dot
      final dotPaint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p, isTopStrength ? 5.0 : 4.0, dotPaint);

      final dotBorderPaint = Paint()
        ..color = isDark ? const Color(0xFF0B1512) : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawCircle(p, isTopStrength ? 5.0 : 4.0, dotBorderPaint);

      // Label Positioning around perimeter
      final angle = -math.pi / 2 + i * (2 * math.pi / n);
      final labelDist = maxRadius + 18.0;
      final labelPos = Offset(
        center.dx + labelDist * math.cos(angle),
        center.dy + labelDist * math.sin(angle),
      );

      final labelText = isAr
          ? '${item.nameAr} ${item.score.toInt()}%'
          : '${item.key.toUpperCase()} ${item.score.toInt()}%';
      final textSpan = TextSpan(
        text: labelText,
        style: TextStyle(
          color: isTopStrength
              ? (isDark ? const Color(0xFFFFE088) : AppColors.secondaryDark)
              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
          fontSize: 9.0,
          fontWeight: isTopStrength ? FontWeight.bold : FontWeight.w600,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      );
      textPainter.layout();

      final textOffset = Offset(
        labelPos.dx - textPainter.width / 2,
        labelPos.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _NonagonRadarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isAr != isAr;
  }
}
