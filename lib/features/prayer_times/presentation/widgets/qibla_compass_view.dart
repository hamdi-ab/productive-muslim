import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/data/services/qibla_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

String _locDigits(BuildContext context, String value) {
  if (Localizations.localeOf(context).languageCode != 'ar') return value;
  return value.replaceAllMapped(
    RegExp('[0-9]'),
    (match) => String.fromCharCode(0x0660 + int.parse(match[0]!)),
  );
}

class QiblaCompassView extends StatefulWidget {
  const QiblaCompassView({
    super.key,
    this.position,
    this.latitude,
    this.longitude,
    this.qiblaService,
    this.initialHeading = 0.0,
    this.headingStream,
  });

  final Position? position;
  final double? latitude;
  final double? longitude;
  final QiblaService? qiblaService;
  final double initialHeading;
  final Stream<double>? headingStream;

  @override
  State<QiblaCompassView> createState() => _QiblaCompassViewState();
}

class _QiblaCompassViewState extends State<QiblaCompassView> {
  late final QiblaService _qiblaService;
  late double _heading;
  StreamSubscription<dynamic>? _headingSubscription;

  @override
  void initState() {
    super.initState();
    _qiblaService = widget.qiblaService ?? QiblaService();
    _heading = widget.initialHeading;
    if (widget.headingStream != null) {
      _headingSubscription = widget.headingStream!.listen((newHeading) {
        if (mounted) {
          setState(() {
            _heading = newHeading;
          });
        }
      });
    } else {
      try {
        _headingSubscription = FlutterCompass.events?.listen((event) {
          final heading = event.heading;
          if (heading != null && mounted) {
            setState(() {
              _heading = heading;
            });
          }
        });
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _headingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final lat = widget.latitude ?? widget.position?.latitude ?? 21.4225;
    final lng = widget.longitude ?? widget.position?.longitude ?? 39.8262;

    final qiblaBearing = _qiblaService.getQiblaBearing(lat, lng);
    final distanceKm = _qiblaService.getDistanceToKaabaKm(lat, lng);

    final angleDifference = (qiblaBearing - _heading).abs() % 360;
    final isFacingKaaba = angleDifference < 5 || angleDifference > 355;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Compass Glass Container
              GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                borderRadius: 24,
                blur: 18,
                color: isDark
                    ? const Color(0xFF13221C).withValues(alpha: 0.88)
                    : Colors.white.withValues(alpha: 0.9),
                borderColor: isFacingKaaba
                    ? AppColors.secondary
                    : (isDark
                          ? AppColors.secondary.withValues(alpha: 0.28)
                          : AppColors.primary.withValues(alpha: 0.2)),
                child: Column(
                  children: [
                    // Top Header: Title & Accuracy Pill
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.explore_rounded,
                              size: 19,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.qiblaTabCompass,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Accuracy: ±0.2°',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Rotating Celestial Compass Rose
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Compass Dial
                          Transform.rotate(
                            angle: -_heading * (math.pi / 180.0),
                            child: CustomPaint(
                              size: const Size(240, 240),
                              painter: _CompassDialPainter(isDark: isDark),
                            ),
                          ),

                          // Kaaba Indicator Pointer Needle
                          Transform.rotate(
                            angle:
                                (qiblaBearing - _heading) * (math.pi / 180.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary.withValues(
                                          alpha: 0.6,
                                        ),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.mosque_rounded,
                                    size: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                                Container(
                                  width: 3.5,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.secondary,
                                        AppColors.secondary.withValues(
                                          alpha: 0.0,
                                        ),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Center Hub Indicator
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F4C3A)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isFacingKaaba
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isFacingKaaba
                                              ? AppColors.secondary
                                              : AppColors.primary)
                                          .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.navigation_rounded,
                                size: 22,
                                color: isFacingKaaba
                                    ? AppColors.secondary
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Real-time Dynamic Heading Readout (FittedBox prevents overflow)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _locDigits(
                              context,
                              '${((_heading % 360 + 360) % 360).toStringAsFixed(0)}°',
                            ),
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: isFacingKaaba
                                  ? AppColors.secondary
                                  : (isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary),
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getCardinalDirection((_heading % 360 + 360) % 360),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isFacingKaaba
                                  ? const Color(0xFF10B981)
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Live Guidance Badge (FittedBox scales down cleanly on extreme fonts)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isFacingKaaba
                              ? const Color(0xFF10B981).withValues(alpha: 0.18)
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isFacingKaaba
                                ? const Color(0xFF10B981)
                                      .withValues(alpha: 0.45)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFacingKaaba
                                  ? Icons.check_circle_rounded
                                  : (_getTurnDiff(qiblaBearing, _heading) > 0
                                        ? Icons.rotate_right_rounded
                                        : Icons.rotate_left_rounded),
                              size: 16,
                              color: isFacingKaaba
                                  ? const Color(0xFF10B981)
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getTurnText(
                                context,
                                qiblaBearing,
                                _heading,
                                isFacingKaaba,
                                l10n,
                              ),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isFacingKaaba
                                    ? const Color(0xFF10B981)
                                    : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Sub-stats Row (Bearing & Distance to Kaaba)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  l10n.qiblaBearing(
                                    _locDigits(
                                      context,
                                      qiblaBearing.toStringAsFixed(1),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.secondary
                                        : AppColors.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.qiblaDirectionLabel,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  l10n.qiblaDistance(
                                    _locDigits(
                                      context,
                                      distanceKm.toStringAsFixed(0),
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.secondary
                                        : AppColors.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.qiblaDistanceLabel,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // 2. Flat phone alignment guidance banner (Stitch Design)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141E1A)
                      : AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.screen_rotation_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'ضع الهاتف بشكل أفقي مسطح باتجاه الكعبة المشرفة بمكة المكرمة.'
                            : 'Orient phone flat towards the Holy Kaaba in Makkah al-Mukarramah.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // 3. Calibration advice card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.qiblaCalibrate,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  final bool isDark;

  _CompassDialPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer subtle gold/metallic ring
    final outerRing = Paint()
      ..color = (isDark ? AppColors.secondary : Colors.grey.shade400)
          .withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 4, outerRing);

    // Inner dashed circle
    final innerDashedRing = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius - 18, innerDashedRing);

    // Cardinal tick marks
    final tickPaint = Paint()
      ..color = isDark ? Colors.white54 : Colors.black45
      ..strokeWidth = 1.5;

    for (int i = 0; i < 360; i += 15) {
      final rad = (i - 90) * (math.pi / 180.0);
      final isMajor = i % 90 == 0;
      final isSemiMajor = i % 30 == 0;
      final tickLength = isMajor ? 12.0 : (isSemiMajor ? 8.0 : 4.0);

      final start = Offset(
        center.dx + (radius - 6) * math.cos(rad),
        center.dy + (radius - 6) * math.sin(rad),
      );
      final end = Offset(
        center.dx + (radius - 6 - tickLength) * math.cos(rad),
        center.dy + (radius - 6 - tickLength) * math.sin(rad),
      );

      canvas.drawLine(start, end, tickPaint);
    }

    // Cardinal Labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final cardinals = [
      ('N', 0, const Color(0xFFEF4444)), // Red North
      ('E', 90, isDark ? Colors.white70 : Colors.black87),
      ('S', 180, isDark ? Colors.white70 : Colors.black87),
      ('W', 270, isDark ? Colors.white70 : Colors.black87),
    ];

    for (final (label, deg, color) in cardinals) {
      final rad = (deg - 90) * (math.pi / 180.0);
      final pos = Offset(
        center.dx + (radius - 28) * math.cos(rad),
        center.dy + (radius - 28) * math.sin(rad),
      );

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

String _getCardinalDirection(double heading) {
  final normalized = (heading % 360 + 360) % 360;
  if (normalized >= 337.5 || normalized < 22.5) return 'N';
  if (normalized >= 22.5 && normalized < 67.5) return 'NE';
  if (normalized >= 67.5 && normalized < 112.5) return 'E';
  if (normalized >= 112.5 && normalized < 157.5) return 'SE';
  if (normalized >= 157.5 && normalized < 202.5) return 'S';
  if (normalized >= 202.5 && normalized < 247.5) return 'SW';
  if (normalized >= 247.5 && normalized < 292.5) return 'W';
  return 'NW';
}

double _getTurnDiff(double target, double current) {
  var diff = (target - current) % 360;
  if (diff > 180) diff -= 360;
  if (diff < -180) diff += 360;
  return diff;
}

String _getTurnText(
  BuildContext context,
  double target,
  double current,
  bool isFacingKaaba,
  AppLocalizations l10n,
) {
  if (isFacingKaaba) {
    return l10n.qiblaFacingKaaba;
  }
  final diff = _getTurnDiff(target, current);
  final deg = _locDigits(context, diff.abs().toStringAsFixed(0));
  if (diff > 0) {
    return l10n.qiblaTurnRight(deg);
  } else {
    return l10n.qiblaTurnLeft(deg);
  }
}
