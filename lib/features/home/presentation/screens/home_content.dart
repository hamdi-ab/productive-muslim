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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(context, l10n, displayDate),
              const SizedBox(height: AppSpacing.md),
              const _HomePrayerCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildDailyProgressSection(context, today, l10n),
              const SizedBox(height: AppSpacing.lg),
              _buildProductivityToolkit(context, l10n),
              const SizedBox(height: AppSpacing.lg),
              _buildQualitiesCarousel(context, l10n),
              const SizedBox(height: AppSpacing.lg),
              _buildTodayTaskOverview(context, today, l10n),
            ],
          ),
        ),
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

  Widget _buildProductivityToolkit(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        // Focus Mode Card
        Expanded(
          child: InkWell(
            onTap: () => context.push('/focus'),
            borderRadius: BorderRadius.circular(20),
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.timer_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.focus,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Khushu\' Timer',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Energy & Routine Card
        Expanded(
          child: InkWell(
            onTap: () => context.push('/energy'),
            borderRadius: BorderRadius.circular(20),
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sunnah Routine',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Energy & Fasting',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQualitiesCarousel(BuildContext context, AppLocalizations l10n) {
    final qualities = [
      (
        id: 'taqwa',
        name: l10n.qualityTaqwa,
        desc: l10n.qualityTaqwaDesc,
        icon: Icons.mosque_rounded,
        color: AppColors.primary,
        context: '"And whoever fears Allah - He will make for him a way out and provide for him from where he does not expect." (Quran 65:2-3)',
        action: 'Pause before your next major task and ensure your intention and methods are pleasing to Allah.',
      ),
      (
        id: 'ikhlas',
        name: l10n.qualityIkhlas,
        desc: l10n.qualityIkhlasDesc,
        icon: Icons.favorite_rounded,
        color: Colors.pink,
        context: '"Actions are judged by intentions." (Sahih Bukhari)',
        action: 'Renew your Niyyah: dedicate this day’s study, work, or service purely for Allah’s pleasure.',
      ),
      (
        id: 'sabr',
        name: l10n.qualitySabr,
        desc: l10n.qualitySabrDesc,
        icon: Icons.hourglass_bottom_rounded,
        color: Colors.orange,
        context: '"Indeed, Allah is with the patient." (Quran 2:153)',
        action: 'Stay steadfast through challenging work blocks and resist the urge to get distracted.',
      ),
      (
        id: 'shukr',
        name: l10n.qualityShukr,
        desc: l10n.qualityShukrDesc,
        icon: Icons.thumb_up_rounded,
        color: Colors.teal,
        context:
            '"If you are grateful, I will surely increase you." (Quran 14:7)',
        action: 'Say Alhamdulillah after completing each task and express gratitude for your energy and faculties.',
      ),
      (
        id: 'tawakkul',
        name: l10n.qualityTawakkul,
        desc: l10n.qualityTawakkulDesc,
        icon: Icons.shield_rounded,
        color: Colors.indigo,
        context: '"Tie your camel, and then put your trust in Allah." (Sunan at-Tirmidhi)',
        action: 'Plan and execute with full effort, then let go of anxiety by entrusting the results to Allah.',
      ),
      (
        id: 'ihsan',
        name: l10n.qualityIhsan,
        desc: l10n.qualityIhsanDesc,
        icon: Icons.star_rounded,
        color: AppColors.secondary,
        context: '"Allah loves that when one of you does a job, he does it with excellence (Itqan)." (Al-Bayhaqi)',
        action: 'Review your current task and apply extra polish and craftsmanship before sending it.',
      ),
      (
        id: 'ilm',
        name: l10n.qualityIlm,
        desc: l10n.qualityIlmDesc,
        icon: Icons.menu_book_rounded,
        color: Colors.blue,
        context: '"Say: My Lord, increase me in knowledge." (Quran 20:114)',
        action: 'Dedicate 20 minutes today to reading beneficial knowledge (Quran, study, skill development).',
      ),
      (
        id: 'dawah',
        name: l10n.qualityDawah,
        desc: l10n.qualityDawahDesc,
        icon: Icons.campaign_rounded,
        color: Colors.amber,
        context: '"Invite to the way of your Lord with wisdom and good instruction." (Quran 16:125)',
        action: 'Lead by example in the workplace or university with honesty, punctuality, and good character.',
      ),
      (
        id: 'ummah',
        name: l10n.qualityUmmah,
        desc: l10n.qualityUmmahDesc,
        icon: Icons.groups_rounded,
        color: Colors.purple,
        context: '"The believers in their mutual kindness and compassion are like one body." (Sahih Muslim)',
        action: 'Check in on family, help a colleague, or do an act of service for the community today.',
      ),
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
              final qColor = q.color;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => _showQualityDetails(context, q, l10n),
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
                        Icon(q.icon, size: 18, color: qColor),
                        const SizedBox(width: 8),
                        Text(
                          q.name,
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

  void _showQualityDetails(
    BuildContext context,
    ({
      String id,
      String name,
      String desc,
      IconData icon,
      Color color,
      String context,
      String action,
    })
    quality,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: quality.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(quality.icon, color: quality.color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quality.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quality.desc,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Islamic Foundation
              Text(
                l10n.qualityDetailsContext,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  quality.context,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Practical Action
              Text(
                l10n.qualityDetailsAction,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  quality.action,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.done),
                ),
              ),
            ],
          ),
        ),
      ),
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
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        child: Column(
          children: [
            // Header row: Icon, Next Prayer & Location, and Action pill
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.nextPrayer,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (_locationName != null && _locationName!.isNotEmpty)
                        Text(
                          '📍 $_locationName',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary.withValues(
                                    alpha: 0.8,
                                  )
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.8,
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.prayerTimes,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 2),
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
            const SizedBox(height: 12),
            // Body row: Localized prayer name and countdown badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_loading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  Text(
                    _getLocalizedPrayerName(_nextPrayer, l10n),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _countdown,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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
