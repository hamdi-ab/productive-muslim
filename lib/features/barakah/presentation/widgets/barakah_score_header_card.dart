import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';

String _toArabicDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], arabic[i]);
  }
  return input;
}

class BarakahScoreHeaderCard extends StatelessWidget {
  final bool isDark;
  final bool isAr;
  final double scorePercent;
  final int scorePoints;

  const BarakahScoreHeaderCard({
    super.key,
    required this.isDark,
    required this.isAr,
    this.scorePercent = 0.92,
    this.scorePoints = 84,
  });

  @override
  Widget build(BuildContext context) {
    final scoreStr = (scorePercent * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0B1512), const Color(0xFF0F4C3A)]
              : [const Color(0xFF0F4C3A), const Color(0xFF1B6B52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C3A)
                .withValues(alpha: isDark ? 0.35 : 0.2),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'البركة والتأمل اليومي' : 'Barakah & Reflection',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr
                          ? 'إطار الأبعاد التسعة للإنتاجية'
                          : '9 Qualities Framework',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFB4EFD6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF222C29).withValues(alpha: 0.9)
                        : AppColors.secondary.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BarakahPulseBeaconDot(),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.stars_rounded,
                          size: 15,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAr
                              ? '${_toArabicDigits('$scoreStr')}٪ مقياس البركة'
                              : '$scoreStr% Barakah Score',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar with dynamic Spiritual Tier
          () {
            final tierName = scorePoints >= 90
                ? (isAr ? 'رتبة المقربين' : 'Al-Muqarraboon Tier')
                : scorePoints >= 80
                ? (isAr ? 'رتبة الإحسان' : 'Al-Ihsan Tier')
                : scorePoints >= 70
                ? (isAr ? 'رتبة المقتصد' : 'Al-Muqtased Tier')
                : (isAr ? 'رتبة الساعين' : 'Sabiqun Tier');
            final scorePointsStr = isAr
                ? _toArabicDigits('$scorePoints')
                : '$scorePoints';
            final totalPointsStr = isAr ? '١٠٠' : '100';
            final pointsWord = isAr ? 'نقطة' : 'points';

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$tierName ($scorePointsStr/$totalPointsStr $pointsWord)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isAr ? '$scorePointsStr٪' : '$scorePoints%',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }(),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: scorePoints / 100.0,
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarakahPulseBeaconDot extends StatelessWidget {
  const BarakahPulseBeaconDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondary,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.6),
            blurRadius: 6,
            spreadRadius: 1.5,
          ),
        ],
      ),
    );
  }
}
