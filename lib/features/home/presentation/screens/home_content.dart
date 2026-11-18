import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_adhkar_pill.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_celestial_arc.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_intention_card.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_prayer_card.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_reflection_card.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_today_tasks_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Simplified, calm daily home dashboard focusing on what matters now:
/// next Salah, Adhkar, today's intention, top tasks, and gentle reflection.
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
                  // 1. Next Salah & Celestial Solar Arc
                  const HomePrayerCard(),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Morning / Evening Adhkar Status with Continue Action
                  const HomeAdhkarPill(),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Today's Intention
                  HomeIntentionCard(today: today, isDark: isDark),
                  const SizedBox(height: AppSpacing.md),

                  // 4. Small Task Preview
                  HomeTodayTasksCard(today: today, l10n: l10n),
                  const SizedBox(height: AppSpacing.md),

                  // 5. Gentle Reflection Entry Point
                  HomeReflectionCard(isDark: isDark),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
