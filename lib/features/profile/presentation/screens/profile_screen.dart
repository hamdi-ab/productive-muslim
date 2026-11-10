import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/services/barakah_score_service.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_bloc.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_event.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_state.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_atmosphere_background.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_heatmap_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_radar_chart_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_score_header_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_weekly_review_card.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_preferences_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Screen representing the user's spiritual profile, anchoring the 9-essential qualities
/// radar chart, Barakah capacity level, consistency momentum, and personal settings.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final hasParentScaffold = Scaffold.maybeOf(context) != null;

    final Widget content = BlocBuilder<BarakahBloc, BarakahState>(
      builder: (context, state) {
        final entries = state is Loaded ? state.entries : const [];
        final Map<String, int> entriesByDate = {};
        for (final e in entries) {
          entriesByDate[e.date] = (entriesByDate[e.date] ?? 0) + 1;
        }

        return FutureBuilder<(BarakahScores?, Map<String, int>)>(
          future: () async {
            BarakahScores? scores;
            if (getIt.isRegistered<BarakahScoreService>()) {
              scores = await getIt<BarakahScoreService>().calculateLiveScores(
                date: today,
              );
            }
            Map<String, int> habitCounts = const {};
            if (getIt.isRegistered<HabitRepository>()) {
              habitCounts = await getIt<HabitRepository>()
                  .getCompletionsCountByDate(days: 84);
            }
            return (scores, habitCounts);
          }(),
          builder: (context, snapshot) {
            final scores = snapshot.data?.$1;
            final habitCounts = snapshot.data?.$2 ?? const {};
            final Map<String, int> totalActivity = Map<String, int>.from(
              habitCounts,
            );
            for (final entry in entriesByDate.entries) {
              totalActivity[entry.key] =
                  (totalActivity[entry.key] ?? 0) + entry.value;
            }

            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              children: [
                // Bismillah Sacred Purpose Pill
                _buildBismillahPill(isDark, isAr),
                const SizedBox(height: AppSpacing.sm),

                // In-Page Header when hosted inside bottom navigation shell
                if (hasParentScaffold) ...[
                  _buildInPageHeader(context, l10n, isDark),
                  const SizedBox(height: AppSpacing.sm),
                ],

                // 1. User Spiritual Identity Header Card
                ProfileHeaderCard(isDark: isDark, isAr: isAr),
                const SizedBox(height: AppSpacing.md),

                // 2. Barakah Capacity & Score Header Card
                BarakahScoreHeaderCard(
                  isDark: isDark,
                  isAr: isAr,
                  scorePercent: scores?.scorePercent ?? 0.85,
                  scorePoints: scores?.scorePoints ?? 85,
                ),
                const SizedBox(height: AppSpacing.md),

                // 3. 9-Qualities Radar / Spider Chart Card
                BarakahRadarChartCard(dimensions: scores?.dimensions),
                const SizedBox(height: AppSpacing.md),

                // 4. 12-Week Consistency & Growth Momentum Heatmap
                BarakahHeatmapCard(activityByDate: totalActivity),
                const SizedBox(height: AppSpacing.md),

                // 5. Weekly Muhasabah Milestone Launcher
                const BarakahWeeklyReviewCard(),
                const SizedBox(height: AppSpacing.md),

                // 6. Quick Preferences & Touch Settings
                ProfilePreferencesCard(isDark: isDark, isAr: isAr),
                const SizedBox(height: AppSpacing.xl),
              ],
            );
          },
        );
      },
    );

    // Provide BarakahBloc if not already present in the ancestor tree
    final Widget bodyWithBloc;
    bool hasBloc = false;
    try {
      BlocProvider.of<BarakahBloc>(context);
      hasBloc = true;
    } catch (_) {
      hasBloc = false;
    }

    if (hasBloc) {
      bodyWithBloc = content;
    } else {
      bodyWithBloc = BlocProvider(
        create: (context) =>
            BarakahBloc(context.read<BarakahRepository>())
              ..add(BarakahLoaded(today)),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1512)
          : const Color(0xFFF8FAF9),
      appBar: hasParentScaffold
          ? null
          : ProductiveAppBar(
              title: l10n.profile,
              subtitle: l10n.profileSubtitle,
              showBackButton: true,
            ),
      body: Stack(
        children: [
          BarakahAtmosphereBackground(isDark: isDark),
          bodyWithBloc,
        ],
      ),
    );
  }

  Widget _buildBismillahPill(bool isDark, bool isAr) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceSubtle
                : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppColors.secondary.withValues(alpha: 0.35)
                  : AppColors.borderLight,
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'amiri',
                  fontSize: 13,
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SPIRITUAL PROFILE & 9 QUALITIES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white70 : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInPageHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profile,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.profileSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
