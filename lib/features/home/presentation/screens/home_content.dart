import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_adhkar_pill.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_celestial_arc.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_daily_ayah_card.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_daily_progress_section.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_energy_khushu_meter.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_nap_timer_banner.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_prayer_card.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_productivity_toolkit.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_qualities_carousel.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_today_tasks_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Subtle Islamic Lattice Watermark
        Positioned.fill(
          child: CustomPaint(
            painter: IslamicLatticeBackgroundPainter(isDark: isDark),
          ),
        ),

        // Atmospheric Radial Spiritual Glow Orbs
        Positioned(
          top: -60,
          left: 20,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0F4C3A)
                      .withValues(alpha: isDark ? 0.35 : 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 360,
          right: -40,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFE9C349)
                      .withValues(alpha: isDark ? 0.18 : 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -40,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4EDEA3)
                      .withValues(alpha: isDark ? 0.20 : 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hero Celestial Solar Arc Prayer Card
                  const HomePrayerCard(),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Sub-Hero Proactive Barakah Nap Timer Banner
                  const HomeNapTimerBanner(),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Daily Energy & Khushu' Level Meter
                  const DailyEnergyKhushuMeter(),
                  const SizedBox(height: AppSpacing.lg),

                  // 4. Spiritual Performance Toolkit (2x2 Bento)
                  const HomeProductivityToolkit(),
                  const SizedBox(height: AppSpacing.lg),

                  // 5. Daily Ayah of Barakah
                  HomeDailyAyahCard(isDark: isDark),
                  const SizedBox(height: AppSpacing.lg),

                  // 6. Quick Adhkar Routine Pill
                  const HomeAdhkarPill(),
                  const SizedBox(height: AppSpacing.md),

                  // 7. Daily Progress Rings
                  HomeDailyProgressSection(today: today, l10n: l10n),
                  const SizedBox(height: AppSpacing.lg),

                  // 8. Today's Tasks Overview
                  HomeTodayTasksCard(today: today, l10n: l10n),
                  const SizedBox(height: AppSpacing.lg),

                  // 9. The 9 Essential Qualities Carousel
                  HomeQualitiesCarousel(l10n: l10n),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
