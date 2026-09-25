import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/animated_progress_ring.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/core/widgets/gradient_card.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final displayDate = DateFormat('EEEE, MMM d').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(context, l10n, displayDate),
          const SizedBox(height: AppSpacing.md),
          const _HomePrayerCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildDailyProgressSection(context, today, l10n),
          const SizedBox(height: AppSpacing.lg),
          _buildQualitiesCarousel(context),
          const SizedBox(height: AppSpacing.lg),
          _buildTodayTaskOverview(context, today, l10n),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    AppLocalizations l10n,
    String displayDate,
  ) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = l10n.goodMorning;
    } else if (hour < 17) {
      greeting = l10n.goodAfternoon;
    } else {
      greeting = l10n.goodEvening;
    }

    try {
      final name = getIt<SettingsService>().userName;
      if (name != null && name.isNotEmpty) {
        greeting = l10n.homeGreeting(name);
      }
    } catch (_) {}

    return GradientCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      displayDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.black87,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Barakah Mode',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bismillah — Start your day with intention and barakah',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProgressSection(
    BuildContext context,
    String today,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<List<Task>>(
            stream: context.read<TaskRepository>().watchTasksForDate(today),
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? [];
              final completed = tasks.where((t) => t.completed).length;
              final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;

              return GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 24,
                child: Column(
                  children: [
                    AnimatedProgressRing(
                      progress: progress,
                      size: 56,
                      strokeWidth: 6,
                      color: AppColors.primary,
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.tasks,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed / ${tasks.length} done',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: StreamBuilder<List<Habit>>(
            stream: context.read<HabitRepository>().watchActiveHabits(),
            builder: (context, snapshot) {
              final habits = snapshot.data ?? [];
              final total = habits.length;
              final progress = total == 0
                  ? 0.0
                  : 0.65; // Habit daily streak sample

              return GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 24,
                child: Column(
                  children: [
                    AnimatedProgressRing(
                      progress: progress,
                      size: 56,
                      strokeWidth: 6,
                      color: AppColors.secondary,
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.secondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.habits,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$total active habits',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQualitiesCarousel(BuildContext context) {
    final qualities = [
      {
        'name': 'Ihsan',
        'icon': Icons.star_rounded,
        'color': AppColors.secondary,
      },
      {
        'name': 'Tawakkul',
        'icon': Icons.shield_rounded,
        'color': AppColors.primary,
      },
      {
        'name': 'Discipline',
        'icon': Icons.fitness_center_rounded,
        'color': Colors.blue,
      },
      {'name': 'Energy', 'icon': Icons.bolt_rounded, 'color': Colors.orange},
      {
        'name': 'Intentionality',
        'icon': Icons.psychology_rounded,
        'color': Colors.purple,
      },
      {
        'name': 'Gratitude',
        'icon': Icons.favorite_rounded,
        'color': Colors.pink,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '9 Essential Qualities',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: qualities.length,
            itemBuilder: (context, index) {
              final q = qualities[index];
              final qColor = q['color'] as Color;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => context.go('/barakah'),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: qColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: qColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(q['icon'] as IconData, size: 18, color: qColor),
                        const SizedBox(width: 8),
                        Text(
                          q['name'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: qColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTaskOverview(
    BuildContext context,
    String today,
    AppLocalizations l10n,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.today,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.go('/tasks'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Task>>(
            stream: context.read<TaskRepository>().watchTasksForDate(today),
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.task_alt_rounded,
                        size: 40,
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No tasks planned for today',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: tasks.take(3).map((task) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: task.completed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tileColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurfaceSubtle
                          : AppColors.surfaceSubtle,
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(task.lifeArea),
                      onChanged: (val) async {
                        if (val != null) {
                          await context.read<TaskRepository>().updateTask(
                            task.copyWith(completed: val),
                          );
                        }
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomePrayerCard extends StatefulWidget {
  const _HomePrayerCard();

  @override
  State<_HomePrayerCard> createState() => _HomePrayerCardState();
}

class _HomePrayerCardState extends State<_HomePrayerCard> {
  String _nextPrayer = '--';
  String _countdown = '--:--';
  String? _locationName;
  bool _loading = true;
  Timer? _timer;
  PrayerTimes? _cachedPrayerTimes;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      if (!getIt.isRegistered<PrayerTimeService>()) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final service = getIt<PrayerTimeService>();
      final position = await service.getCurrentPosition();
      if (!mounted) return;
      if (position == null) {
        setState(() => _loading = false);
        return;
      }

      _cachedPrayerTimes = service.getPrayerTimes(position);
      _locationName = service.getLocationName(position);
      _updatePrayerCountdown();
      _startTimer();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updatePrayerCountdown();
    });
  }

  void _updatePrayerCountdown() {
    if (_cachedPrayerTimes == null ||
        !getIt.isRegistered<PrayerTimeService>()) {
      return;
    }

    final service = getIt<PrayerTimeService>();
    final nextPrayer = service.getNextPrayerName(_cachedPrayerTimes!);
    final timeUntil = service.getTimeUntilNextPrayer(_cachedPrayerTimes!);

    if (mounted) {
      setState(() {
        _nextPrayer = nextPrayer ?? '--';
        _countdown = timeUntil != null ? _formatDuration(timeUntil) : '--:--';
        _loading = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final sStr = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours}h ${minutes}m ${sStr}s';
    }
    return '${minutes}m ${sStr}s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.push('/prayer-times'),
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        padding: const EdgeInsets.all(18),
        borderRadius: 24,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mosque_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.nextPrayer}${_locationName != null ? ' • 📍 $_locationName' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (_loading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Text(
                      '${_getLocalizedPrayerName(_nextPrayer, l10n)} in $_countdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    l10n.prayerTimes,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getLocalizedPrayerName(String key, AppLocalizations l10n) {
  return switch (key.toLowerCase()) {
    'fajr' => l10n.fajr,
    'sunrise' => l10n.sunrise,
    'dhuhr' => l10n.dhuhr,
    'asr' => l10n.asr,
    'maghrib' => l10n.maghrib,
    'isha' => l10n.isha,
    _ => key,
  };
}
