import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/app_typography_extension.dart';
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
  });

  final Position? position;
  final double? latitude;
  final double? longitude;
  final QiblaService? qiblaService;
  final double initialHeading;

  @override
  State<QiblaCompassView> createState() => _QiblaCompassViewState();
}

class _QiblaCompassViewState extends State<QiblaCompassView> {
  late final QiblaService _qiblaService;
  late double _heading;

  @override
  void initState() {
    super.initState();
    _qiblaService = widget.qiblaService ?? QiblaService();
    _heading = widget.initialHeading;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final lat = widget.latitude ?? widget.position?.latitude ?? 21.4225;
    final lng = widget.longitude ?? widget.position?.longitude ?? 39.8262;

    final qiblaBearing = _qiblaService.getQiblaBearing(lat, lng);
    final distanceKm = _qiblaService.getDistanceToKaabaKm(lat, lng);

    final angleDifference = (qiblaBearing - _heading).abs() % 360;
    final isFacingKaaba = angleDifference < 5 || angleDifference > 355;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Compass Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isFacingKaaba
                    ? const Color(0xFF10B981).withValues(alpha: 0.6)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05)),
                width: isFacingKaaba ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isFacingKaaba
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                if (isFacingKaaba)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.qiblaFacingKaaba,
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Rotating Compass Rose
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

                      // Kaaba Indicator Pointer
                      Transform.rotate(
                        angle: (qiblaBearing - _heading) * (math.pi / 180.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFF59E0B),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.mosque_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              width: 3,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF59E0B),
                                    const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Center Hub
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isFacingKaaba
                                ? const Color(0xFF10B981)
                                : AppColors.primary,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.navigation_rounded,
                            size: 22,
                            color: isFacingKaaba
                                ? const Color(0xFF10B981)
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Readout
                Text(
                  l10n.qiblaBearing(
                    _locDigits(context, qiblaBearing.toStringAsFixed(1)),
                  ),
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.qiblaDistance(
                    _locDigits(context, distanceKm.toStringAsFixed(0)),
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Calibration advice
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
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
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.4,
                    ),
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

class _CompassDialPainter extends CustomPainter {
  final bool isDark;

  _CompassDialPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outerRing = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 4, outerRing);

    // Cardinal points
    final tickPaint = Paint()
      ..color = isDark ? Colors.white54 : Colors.black45
      ..strokeWidth = 1.5;

    for (int i = 0; i < 360; i += 30) {
      final rad = i * (math.pi / 180.0);
      final isMajor = i % 90 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;

      final start = Offset(
        center.dx + (radius - 4) * math.cos(rad),
        center.dy + (radius - 4) * math.sin(rad),
      );
      final end = Offset(
        center.dx + (radius - 4 - tickLength) * math.cos(rad),
        center.dy + (radius - 4 - tickLength) * math.sin(rad),
      );

      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
