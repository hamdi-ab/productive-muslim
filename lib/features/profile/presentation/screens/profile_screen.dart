import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_bloc.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_event.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_state.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_atmosphere_background.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_heatmap_card.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_action_hub.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_lifetime_stats_grid.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

typedef _ProfileData = ({
  Map<String, int> habitCounts,
  int streak,
  int longestStreak,
  int lifetimeHabits,
  int lifetimeTasks,
  int focusMinutes,
});

/// Screen representing the user's personal sovereignty & account hub,
/// combining identity, lifetime activity metrics, consistency badges,
/// consistency heatmap, and sovereign data settings.
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

        return FutureBuilder<_ProfileData>(
          future: () async {
            Map<String, int> habitCounts = const {};
            int streak = 0;
            int longestStreak = 0;
            int lifetimeHabits = 0;
            if (getIt.isRegistered<HabitRepository>()) {
              final habitRepo = getIt<HabitRepository>();
              habitCounts = await habitRepo.getCompletionsCountByDate(days: 84);
              streak = await habitRepo.getOverallStreak();
              longestStreak = await habitRepo.getLongestStreak();
              lifetimeHabits = await habitRepo.getLifetimeCompletionsCount();
            }

            int lifetimeTasks = 0;
            if (getIt.isRegistered<TaskRepository>()) {
              lifetimeTasks = await getIt<TaskRepository>()
                  .getLifetimeCompletedTasksCount();
            }

            int focusMinutes = 0;
            if (getIt.isRegistered<SettingsService>()) {
              focusMinutes = getIt<SettingsService>().totalFocusMinutes;
            }

            return (
              habitCounts: habitCounts,
              streak: streak,
              longestStreak: longestStreak,
              lifetimeHabits: lifetimeHabits,
              lifetimeTasks: lifetimeTasks,
              focusMinutes: focusMinutes,
            );
          }(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            final habitCounts = data?.habitCounts ?? const {};
            final streak = data?.streak ?? 0;
            final longestStreak = data?.longestStreak ?? 0;
            final lifetimeHabits = data?.lifetimeHabits ?? 0;
            final lifetimeTasks = data?.lifetimeTasks ?? 0;
            final focusMinutes = data?.focusMinutes ?? 0;

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
                // 1. User Identity Header Card (tap-to-edit name, motto & avatar)
                ProfileHeaderCard(isDark: isDark, isAr: isAr),
                const SizedBox(height: AppSpacing.md),

                // 2. 2x2 Lifetime Activity Grid
                ProfileLifetimeStatsGrid(
                  currentStreak: streak,
                  longestStreak: longestStreak,
                  lifetimeHabitCompletions: lifetimeHabits,
                  lifetimeTasksCompleted: lifetimeTasks,
                  totalFocusMinutes: focusMinutes,
                  isDark: isDark,
                  isAr: isAr,
                ),
                const SizedBox(height: AppSpacing.md),

                // 3. 12-Week Consistency & Growth Momentum Heatmap
                BarakahHeatmapCard(activityByDate: totalActivity),
                const SizedBox(height: AppSpacing.md),

                // 5. Action Hub (Preferences, JSON Backup & Restore, Privacy & Sharing)
                ProfileActionHub(isDark: isDark, isAr: isAr),
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
}
