import 'dart:async';
import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/animated_progress_ring.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_adhkar_pill.dart';
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
            painter: _IslamicLatticeBackgroundPainter(isDark: isDark),
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
                  const _HomePrayerCard(),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Sub-Hero Proactive Barakah Nap Timer Banner
                  const _HomeNapTimerBanner(),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Daily Energy & Khushu' Level Meter
                  const _DailyEnergyKhushuMeter(),
                  const SizedBox(height: AppSpacing.lg),

                  // 4. Spiritual Performance Toolkit (2x2 Bento)
                  const _HomeProductivityToolkit(),
                  const SizedBox(height: AppSpacing.lg),

                  // 5. Daily Ayah of Barakah
                  _buildDailyAyahCard(context, isDark),
                  const SizedBox(height: AppSpacing.lg),

                  // 6. Quick Adhkar Routine Pill
                  const HomeAdhkarPill(),
                  const SizedBox(height: AppSpacing.md),

                  // 7. Daily Progress Rings
                  _buildDailyProgressSection(context, today, l10n),
                  const SizedBox(height: AppSpacing.lg),

                  // 8. Today's Tasks Overview
                  _buildTodayTaskOverview(context, today, l10n),
                  const SizedBox(height: AppSpacing.lg),

                  // 9. The 9 Essential Qualities Carousel
                  _buildQualitiesCarousel(context, l10n),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyAyahCard(BuildContext context, bool isDark) {
    return Stack(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          borderColor: const Color(0xFFD4AF37)
              .withValues(alpha: isDark ? 0.25 : 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFFD4AF37),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'AYAH OF BARAKAH',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: isDark
                                  ? const Color(0xFFD4AF37)
                                  : const Color(0xFF92600E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: 'Recitation',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.bookmark_outline_rounded,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: 'Bookmark',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'وَتَوَكَّلْ عَلَى الْحَيِّ الَّذِي لَا يَمُوتُ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '“And put your trust in the Ever-Living Who dies not, and celebrate His praise.”',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Surah Al-Furqan • 25:58',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Personal reflection note empty',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: TextButton.icon(
                        onPressed: () => context.push('/journal'),
                        icon: const Icon(Icons.edit_note_rounded, size: 18),
                        label: const Text('Reflect & Journal'),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? AppColors.secondary
                              : AppColors.primary,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 12,
          child: Text(
            '۞',
            style: TextStyle(
              fontSize: 22,
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 12,
          child: Text(
            '۞',
            style: TextStyle(
              fontSize: 22,
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyProgressSection(
    BuildContext context,
    String today,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed / ${tasks.length} done',
                      style: TextStyle(fontSize: 12, color: secondaryText),
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
              final progress = total == 0 ? 0.0 : 0.65;

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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$total active habits',
                      style: TextStyle(fontSize: 12, color: secondaryText),
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

  Widget _buildTodayTaskOverview(
    BuildContext context,
    String today,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<Task>>(
      stream: context.read<TaskRepository>().watchTasksForDate(today),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        if (tasks.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.tasks,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: TextButton(
                      onPressed: () => context.push('/plan'),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...tasks.take(3).map((task) => _TaskItemTile(task: task)),
          ],
        );
      },
    );
  }

  Widget _buildQualitiesCarousel(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final qualities = [
      (
        title: 'Spiritual Purity',
        quality: 'Ikhlas (Sincerity)',
        desc: 'Purify intentions before actions.',
        icon: Icons.favorite_rounded,
        color: const Color(0xFF10B981),
      ),
      (
        title: 'Excellence in Action',
        quality: 'Ihsan (Excellence)',
        desc: 'Execute work as worship with beauty.',
        icon: Icons.star_rounded,
        color: const Color(0xFFD4AF37),
      ),
      (
        title: 'Mindful Presence',
        quality: 'Khushu\' (Focus)',
        desc: 'Deep focus free of distraction.',
        icon: Icons.center_focus_strong_rounded,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Essential Qualities',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton(
                  onPressed: () => context.push('/barakah'),
                  child: Text(
                    'Explore All',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 154,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: qualities.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final q = qualities[index];
              return Container(
                width: 240,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: q.color.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: q.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(q.icon, color: q.color, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            q.quality,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      q.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      q.title,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: q.color,
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
}

class _TaskItemTile extends StatelessWidget {
  final Task task;

  const _TaskItemTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.completed,
            onChanged: (val) {
              context.read<TaskRepository>().toggleTask(task.id);
            },
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: task.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: task.completed
                    ? (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary)
                    : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
              ),
            ),
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
    if (getIt.isRegistered<PrayerTimeService>()) {
      final service = getIt<PrayerTimeService>();
      if (service.cachedPrayerTimes != null) {
        _cachedPrayerTimes = service.cachedPrayerTimes;
        _locationName = service.cachedLocationName;
        _loading = false;
        _updatePrayerCountdown();
        _startTimer();
      }
    }
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
        if (_cachedPrayerTimes == null) {
          setState(() => _loading = false);
        }
        return;
      }

      _cachedPrayerTimes = service.getPrayerTimes(position);
      _locationName = service.getLocationName(position);
      _updatePrayerCountdown();
      _startTimer();
    } catch (_) {
      if (mounted && _cachedPrayerTimes == null) {
        setState(() => _loading = false);
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updatePrayerCountdown();
    });
  }

  void _updatePrayerCountdown() {
    if (!getIt.isRegistered<PrayerTimeService>()) {
      return;
    }

    final service = getIt<PrayerTimeService>();
    final now = DateTime.now();

    if (_cachedPrayerTimes != null && _cachedPrayerTimes!.fajr.day != now.day) {
      if (service.cachedPosition != null) {
        _cachedPrayerTimes = service.getPrayerTimes(
          service.cachedPosition!,
          date: now,
        );
      } else if (service.cachedPrayerTimes != null) {
        _cachedPrayerTimes = service.cachedPrayerTimes;
      }
    }

    if (_cachedPrayerTimes == null) {
      return;
    }

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

  String _formatPrayerTime(
    PrayerTimes times,
    String prayerName,
    BuildContext context,
  ) {
    final format = DateFormat.jm(Localizations.localeOf(context).languageCode);
    final dt = switch (prayerName.toLowerCase()) {
      'fajr' => times.fajr,
      'sunrise' => times.sunrise,
      'dhuhr' => times.dhuhr,
      'asr' => times.asr,
      'maghrib' => times.maghrib,
      'isha' => times.isha,
      _ => null,
    };
    return dt != null ? format.format(dt) : '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isAfterIsha =
        _cachedPrayerTimes != null &&
        DateTime.now().isAfter(_cachedPrayerTimes!.isha);
    final isTomorrowFajr = isAfterIsha && _nextPrayer.toLowerCase() == 'fajr';
    final prayerName = _getLocalizedPrayerName(_nextPrayer, l10n);

    return AppPressable(
      onTap: () => context.push('/prayer-times'),
      pressedScale: 0.98,
      haptic: AppHapticFeedback.light,
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        borderColor: const Color(0xFFD4AF37)
            .withValues(alpha: isDark ? 0.3 : 0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Micro Badge & Audio Adhan Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'SUNNAH ALIGNMENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.volume_up_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Adhan: Mishary',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
            // Header: Upcoming Prayer Title & Countdown Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          prayerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isTomorrowFajr) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: isDark ? 0.22 : 0.14),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              isAr ? 'غداً' : 'Tomorrow',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_loading)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFD97706),
                                ),
                              ),
                            )
                          else ...[
                            const Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'in $_countdown',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Subtitle Row: Scheduled Time (Left) & Location Status (Right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_cachedPrayerTimes != null)
                  Flexible(
                    child: Text(
                      '${isAr ? 'في ' : 'at '}${_formatPrayerTime(_cachedPrayerTimes!, _nextPrayer, context)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationName != null && _locationName!.isNotEmpty
                        ? '📍 $_locationName • Iqamah scheduled'
                        : 'Iqamah scheduled • Clean for Salah',
                    maxLines: 1,
                    textAlign: _cachedPrayerTimes != null
                        ? TextAlign.end
                        : TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Celestial Sun Arc Canvas Diagram
            _SolarArcDiagram(
              key: const ValueKey('hero_solar_arc_diagram'),
              prayerTimes: _cachedPrayerTimes,
              nextPrayer: _nextPrayer,
              isDark: isDark,
            ),
            const SizedBox(height: 6),
            // 5 Daily Prayers Status Horizontal Cards Row
            if (_cachedPrayerTimes != null)
              _buildDailyPrayersRow(
                context,
                _cachedPrayerTimes!,
                _nextPrayer,
                l10n,
                isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPrayersRow(
    BuildContext context,
    PrayerTimes prayerTimes,
    String nextPrayer,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final now = DateTime.now();
    final timeFormat = DateFormat.jm(
      Localizations.localeOf(context).languageCode,
    );

    final prayers = [
      (key: 'fajr', name: l10n.fajr, time: prayerTimes.fajr),
      (key: 'dhuhr', name: l10n.dhuhr, time: prayerTimes.dhuhr),
      (key: 'asr', name: l10n.asr, time: prayerTimes.asr),
      (key: 'maghrib', name: l10n.maghrib, time: prayerTimes.maghrib),
      (key: 'isha', name: l10n.isha, time: prayerTimes.isha),
    ];

    final isAfterIsha = now.isAfter(prayerTimes.isha);
    final nextKey = nextPrayer.toLowerCase();

    return Row(
      children: prayers.map((p) {
        final isNext = !isAfterIsha && p.key == nextKey;
        final isPast = p.time.isBefore(now) && !isNext;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(
              color: isNext
                  ? AppColors.primary
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isNext
                    ? AppColors.secondary.withValues(alpha: 0.8)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06)),
                width: isNext ? 1.5 : 1,
              ),
              boxShadow: isNext
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                    color: isNext
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  timeFormat.format(p.time),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                    color: isNext
                        ? AppColors.secondary
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 3),
                Icon(
                  isNext
                      ? Icons.radio_button_checked_rounded
                      : (isPast
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded),
                  size: 12,
                  color: isNext
                      ? AppColors.secondary
                      : (isPast
                            ? (isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary)
                            : (isDark ? Colors.white30 : Colors.black26)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HomeNapTimerBanner extends StatefulWidget {
  const _HomeNapTimerBanner();

  @override
  State<_HomeNapTimerBanner> createState() => _HomeNapTimerBannerState();
}

class _HomeNapTimerBannerState extends State<_HomeNapTimerBanner> {
  bool _dismissed = false;
  bool _isRunning = false;
  bool _isPaused = false;
  int _totalSeconds = 15 * 60;
  int _remainingSeconds = 15 * 60;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startNap(int minutes) {
    _timer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      _totalSeconds = minutes * 60;
      _remainingSeconds = minutes * 60;
      _isRunning = true;
      _isPaused = false;
      _dismissed = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isPaused) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          t.cancel();
          HapticFeedback.heavyImpact();
          setState(() {
            _isRunning = false;
          });
        }
      }
    });
  }

  void _togglePause() {
    HapticFeedback.selectionClick();
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopNap() {
    _timer?.cancel();
    HapticFeedback.lightImpact();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed && !_isRunning) {
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => setState(() => _dismissed = false),
          icon: const Icon(Icons.refresh_rounded, size: 14),
          label: const Text(
            'Show Sunnah Nap Routine',
            style: TextStyle(fontSize: 11),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    final isMidday = hour >= 11 && hour < 16;
    final title = isMidday ? 'Midday Barakah Boost' : 'Sunnah Qaylulah Nap';

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      borderColor: const Color(0xFFD4AF37)
          .withValues(alpha: isDark ? 0.25 : 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFD4AF37),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD4AF37)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'Sunnah Routine',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isRunning
                          ? 'Taking Sunnah Qaylulah nap before Salah to revitalize Khushu\'.'
                          : 'Renew your Wudhu and take a 15-min Qaylulah (Sunnah nap) before Asr prayer to revitalize your Khushu\'.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
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
          if (_isRunning) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _totalSeconds > 0
                    ? (_totalSeconds - _remainingSeconds) / _totalSeconds
                    : 0,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFD4AF37),
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bedtime_rounded,
                      size: 16,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isPaused ? '(Paused)' : 'remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 20,
                      ),
                      onPressed: _togglePause,
                      tooltip: _isPaused ? 'Resume' : 'Pause',
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop_rounded, size: 20),
                      onPressed: _stopNap,
                      tooltip: 'End Nap',
                    ),
                    TextButton.icon(
                      onPressed: () => context.push('/energy'),
                      icon: const Icon(Icons.graphic_eq_rounded, size: 14),
                      label: const Text(
                        'Soundscape',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: FilledButton.icon(
                    onPressed: () => _startNap(15),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C3A),
                      foregroundColor: const Color(0xFF99D3BA),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.bedtime_rounded, size: 16),
                    label: const Text(
                      'Start 15m Nap',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: OutlinedButton(
                    onPressed: () => _startNap(20),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    child: const Text(
                      '20m',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TextButton(
                    onPressed: () => setState(() => _dismissed = true),
                    child: Text(
                      'Dismiss',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DailyEnergyKhushuMeter extends StatelessWidget {
  const _DailyEnergyKhushuMeter();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPressable(
      onTap: () => context.push('/energy'),
      pressedScale: 0.98,
      haptic: AppHapticFeedback.light,
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        borderColor: const Color(0xFF10B981)
            .withValues(alpha: isDark ? 0.25 : 0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monitor_heart_rounded,
                        color: Color(0xFF10B981),
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "Daily Energy & Khushu' Level",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        '84% Optimal',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.84,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF0F4C3A),
                        Color(0xFFD4AF37),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Physical Energy 88%',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '•',
                  style: TextStyle(
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4AF37),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Spiritual Focus 80%',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeProductivityToolkit extends StatefulWidget {
  const _HomeProductivityToolkit();

  @override
  State<_HomeProductivityToolkit> createState() =>
      _HomeProductivityToolkitState();
}

class _HomeProductivityToolkitState extends State<_HomeProductivityToolkit> {
  int _tasbihCount = 23;
  final int _tasbihTarget = 33;
  bool _isFasting = true;

  void _incrementTasbih() {
    HapticFeedback.lightImpact();
    setState(() {
      _tasbihCount = (_tasbihCount % _tasbihTarget) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.widgets_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.quickToolkit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.allTools,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Card 1: Khushu' Focus
            Expanded(
              child: _buildBentoCard(
                context: context,
                isDark: isDark,
                icon: Icons.timer_rounded,
                iconColor: AppColors.primary,
                bgColor: AppColors.primary.withValues(alpha: 0.15),
                pillLabel: '25m Block',
                pillColor: AppColors.primary,
                title: l10n.focus,
                subtitle: l10n.focusSubtitle,
                bottomAction: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/focus'),
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.primaryLight
                          : const Color(0xFF0F4C3A),
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 15),
                    label: const Text(
                      'Start Timer',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Card 2: Fasting & Sunnah Tracker
            Expanded(
              child: _buildBentoCard(
                context: context,
                isDark: isDark,
                icon: Icons.restaurant_rounded,
                iconColor: const Color(0xFFD4AF37),
                bgColor: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                pillLabel: 'Sunnah',
                pillColor: const Color(0xFFD4AF37),
                title: l10n.fastingTitle,
                subtitle: 'Tomorrow: Thursday Fast',
                bottomAction: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isFasting = !_isFasting);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "I'm Fasting",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: _isFasting,
                            onChanged: (val) {
                              HapticFeedback.selectionClick();
                              setState(() => _isFasting = val ?? false);
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Card 3: Energy & Qaylulah Nap
            Expanded(
              child: _buildBentoCard(
                context: context,
                isDark: isDark,
                icon: Icons.nights_stay_rounded,
                iconColor: AppColors.secondary,
                bgColor: AppColors.secondary.withValues(alpha: 0.2),
                pillLabel: 'Qaylulah',
                pillColor: AppColors.secondary,
                title: l10n.energy,
                subtitle: 'Forest soundscape',
                bottomAction: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => context.push('/energy'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '15 min',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: InkWell(
                        onTap: () => context.push('/energy'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '20 min',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Card 4: Adhkar Studio (Digital Tasbih)
            Expanded(
              child: _buildBentoCard(
                context: context,
                isDark: isDark,
                icon: Icons.fingerprint_rounded,
                iconColor: const Color(0xFFD4AF37),
                bgColor: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                pillLabel: '$_tasbihCount/$_tasbihTarget',
                pillColor: const Color(0xFFD4AF37),
                title: 'SubhanAllah',
                subtitle: l10n.adhkarSubtitle,
                bottomAction: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _incrementTasbih,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF3C7),
                      foregroundColor: const Color(0xFF92400E),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.touch_app_rounded, size: 14),
                    label: Text(
                      'Tap: $_tasbihCount',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String pillLabel,
    required Color pillColor,
    required String title,
    required String subtitle,
    required Widget bottomAction,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      borderColor: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : AppColors.primary.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 17),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: pillColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pillLabel,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: pillColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          bottomAction,
        ],
      ),
    );
  }
}

class _SolarArcDiagram extends StatelessWidget {
  final PrayerTimes? prayerTimes;
  final String nextPrayer;
  final bool isDark;

  const _SolarArcDiagram({
    super.key,
    required this.prayerTimes,
    required this.nextPrayer,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return SizedBox(
      height: 94,
      width: double.infinity,
      child: CustomPaint(
        key: const ValueKey('solar_arc_custom_paint'),
        painter: _SolarArcPainter(
          prayerTimes: prayerTimes,
          nextPrayer: nextPrayer,
          isDark: isDark,
          isAr: isAr,
          now: DateTime.now(),
        ),
      ),
    );
  }
}

class _SolarArcPainter extends CustomPainter {
  final PrayerTimes? prayerTimes;
  final String nextPrayer;
  final bool isDark;
  final bool isAr;
  final DateTime now;

  _SolarArcPainter({
    required this.prayerTimes,
    required this.nextPrayer,
    required this.isDark,
    required this.isAr,
    required this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.76;
    final w = size.width;

    // 1. Draw dashed horizon baseline
    final dashPaint = Paint()
      ..color = isDark ? Colors.white12 : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 12.0;
    final endX = w - 12.0;
    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, horizonY),
        Offset(math.min(startX + dashWidth, endX), horizonY),
        dashPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // 2. Solar curve path (cubic bezier)
    final p0 = Offset(18, horizonY);
    final p1 = Offset(w * 0.22, size.height * 0.16);
    final p2 = Offset(w * 0.78, size.height * 0.16);
    final p3 = Offset(w - 18, horizonY);

    final bgArcPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    final bgArcPaint = Paint()
      ..color = isDark ? Colors.white24 : const Color(0xFFCBD5E1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(bgArcPath, bgArcPaint);

    // 3. Compute dynamic duration-proportional milestone points for the 5 prayers
    final fajr = prayerTimes?.fajr;
    final sunrise = prayerTimes?.sunrise;
    final dhuhr = prayerTimes?.dhuhr;
    final asr = prayerTimes?.asr;
    final maghrib = prayerTimes?.maghrib;
    final isha = prayerTimes?.isha;

    const tStart = 0.08;
    const tEnd = 0.93;
    const tSpan = tEnd - tStart; // 0.85

    // Default aesthetic spacing
    double tFajr = tStart;
    double tDhuhr = 0.50;
    double tAsr = 0.71;
    double tMaghrib = 0.86;
    double tIsha = tEnd;
    double? tSunrise;

    if (fajr != null &&
        dhuhr != null &&
        asr != null &&
        maghrib != null &&
        isha != null) {
      final totalDaySeconds = isha.difference(fajr).inSeconds;
      if (totalDaySeconds > 0) {
        final dhuhrRatio = dhuhr.difference(fajr).inSeconds / totalDaySeconds;
        final asrRatio = asr.difference(fajr).inSeconds / totalDaySeconds;
        final maghribRatio =
            maghrib.difference(fajr).inSeconds / totalDaySeconds;

        tFajr = tStart;
        // Fajr -> Dhuhr is the longest duration (~7h), Dhuhr peaks around zenith
        tDhuhr = (tStart + dhuhrRatio * tSpan).clamp(0.38, 0.56);
        // Dhuhr -> Asr (~3.5h)
        tAsr = (tStart + asrRatio * tSpan).clamp(tDhuhr + 0.12, 0.78);
        // Asr -> Maghrib (~2.5h)
        tMaghrib = (tStart + maghribRatio * tSpan).clamp(tAsr + 0.08, 0.88);
        // Maghrib -> Isha (~1.25h) is the shortest duration
        tIsha = tEnd;

        if (sunrise != null &&
            sunrise.isAfter(fajr) &&
            sunrise.isBefore(dhuhr)) {
          final sunriseRatio =
              sunrise.difference(fajr).inSeconds / totalDaySeconds;
          tSunrise = (tStart + sunriseRatio * tSpan).clamp(
            tFajr + 0.08,
            tDhuhr - 0.06,
          );
        }
      }
    }

    final key = nextPrayer.toLowerCase();
    final isAfterMaghrib = maghrib != null && now.isAfter(maghrib);
    final isAfterIsha = isha != null && now.isAfter(isha);
    final isBeforeFajr = fajr != null && now.isBefore(fajr);
    final isTomorrowFajr = isAfterIsha && key == 'fajr';
    // Islamic nighttime begins at Maghrib (sunset) and extends until dawn (Fajr)
    final isNight = isAfterMaghrib || isBeforeFajr;

    // 4. Compute active celestial progress t (0.0 to 1.0)
    double progressT = tFajr;
    if (isAfterIsha) {
      // Nighttime after Isha: resting at the night horizon (Isha)
      progressT = tIsha;
    } else if (isAfterMaghrib && isha != null) {
      // Twilight dusk between Maghrib and Isha: moves forward from Maghrib toward Isha
      final spanSec = isha.difference(maghrib).inSeconds;
      final elapsedSec = now.difference(maghrib).inSeconds;
      final ratio = (elapsedSec / (spanSec > 0 ? spanSec : 1)).clamp(0.0, 1.0);
      progressT = (tMaghrib + ratio * (tIsha - tMaghrib)).clamp(
        tMaghrib,
        tIsha,
      );
    } else if (asr != null &&
        maghrib != null &&
        now.isAfter(asr) &&
        now.isBefore(maghrib)) {
      // Late afternoon between Asr and Maghrib: Sun descends toward sunset
      final span = maghrib.difference(asr).inSeconds;
      final elapsed = now.difference(asr).inSeconds;
      final ratio = (elapsed / (span > 0 ? span : 1)).clamp(0.0, 1.0);
      progressT = (tAsr + ratio * (tMaghrib - tAsr)).clamp(tAsr, tMaghrib);
    } else if (dhuhr != null &&
        asr != null &&
        now.isAfter(dhuhr) &&
        now.isBefore(asr)) {
      // Early afternoon between Dhuhr and Asr: Sun moves from zenith peak toward Asr
      final span = asr.difference(dhuhr).inSeconds;
      final elapsed = now.difference(dhuhr).inSeconds;
      final ratio = (elapsed / (span > 0 ? span : 1)).clamp(0.0, 1.0);
      progressT = (tDhuhr + ratio * (tAsr - tDhuhr)).clamp(tDhuhr, tAsr);
    } else if (fajr != null &&
        dhuhr != null &&
        now.isAfter(fajr) &&
        now.isBefore(dhuhr)) {
      // Morning between Fajr and Dhuhr: Sun ascends continuously toward zenith peak
      final span = dhuhr.difference(fajr).inSeconds;
      final elapsed = now.difference(fajr).inSeconds;
      final ratio = (elapsed / (span > 0 ? span : 1)).clamp(0.0, 1.0);
      progressT = (tFajr + ratio * (tDhuhr - tFajr)).clamp(tFajr, tDhuhr);
    } else if (isBeforeFajr) {
      // Pre-dawn Tahajjud before Fajr: resting at the dawn horizon
      progressT = tFajr;
    } else {
      progressT = switch (key) {
        'fajr' => tFajr,
        'sunrise' => tSunrise ?? (tFajr + 0.15),
        'dhuhr' => tDhuhr,
        'asr' => tAsr,
        'maghrib' => tMaghrib,
        'isha' => tIsha,
        _ => tDhuhr,
      };
    }

    // 5. Draw active daylight progress arc or nocturnal celestial path
    if (!isNight) {
      final progressArcPath = Path()..moveTo(p0.dx, p0.dy);
      const int steps = 40;
      final int maxSteps = (steps * progressT).round().clamp(1, steps);
      for (int i = 1; i <= maxSteps; i++) {
        final t = (i / steps) * progressT;
        final pt = _evalCubic(p0, p1, p2, p3, t);
        progressArcPath.lineTo(pt.dx, pt.dy);
      }

      final gradientPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF0F4C3A), Color(0xFFD4AF37)],
        ).createShader(Rect.fromLTWH(0, 0, w, size.height))
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(progressArcPath, gradientPaint);
    } else {
      final nightArcPaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF38BDF8), // dawn cyan
            Color(0xFF6366F1), // celestial indigo
            Color(0xFF8B5CF6), // dusk violet
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, size.height))
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(bgArcPath, nightArcPaint);

      // Faint ambient stars in the nocturnal sky
      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.6 : 0.45)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w * 0.16, size.height * 0.22), 1.2, starPaint);
      canvas.drawCircle(Offset(w * 0.38, size.height * 0.14), 1.5, starPaint);
      canvas.drawCircle(Offset(w * 0.64, size.height * 0.12), 1.2, starPaint);
      canvas.drawCircle(Offset(w * 0.84, size.height * 0.24), 1.4, starPaint);
    }

    // Helper to draw fixed milestone and active nodes
    void drawNode(
      double t,
      Color color,
      String label, {
      bool isAbove = false,
      bool isActive = false,
      bool isCompleted = false,
    }) {
      final pt = _evalCubic(p0, p1, p2, p3, t);
      final nodePaint = Paint()
        ..color = isActive
            ? const Color(0xFFF59E0B)
            : (isCompleted ? const Color(0xFF10B981) : color)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = isActive ? 2.2 : 1.6
        ..style = PaintingStyle.stroke;

      if (isActive) {
        final haloPaint = Paint()
          ..color = const Color(0xFFF59E0B).withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pt, 8.0, haloPaint);
      }

      canvas.drawCircle(pt, isActive ? 5.0 : 4.0, nodePaint);
      canvas.drawCircle(pt, isActive ? 5.0 : 4.0, borderPaint);

      final textSpan = TextSpan(
        text: label,
        style: TextStyle(
          color: isActive
              ? (isDark ? AppColors.secondary : const Color(0xFFD97706))
              : (isCompleted
                    ? (isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF059669))
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF64748B))),
          fontSize: isActive ? 9.5 : 8.5,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      )..layout();
      final textOffset = isAbove
          ? Offset(pt.dx - textPainter.width / 2, pt.dy - 15)
          : Offset(pt.dx - textPainter.width / 2, pt.dy + 7);
      textPainter.paint(canvas, textOffset);
    }

    final fajrLabel = isAr ? 'الفجر' : 'Fajr';
    final dhuhrLabel = isAr ? 'الظهر' : 'Dhuhr';
    final asrLabel = isAr ? 'العصر' : 'Asr';
    final maghribLabel = isAr ? 'المغرب' : 'Maghrib';
    final ishaLabel = isAr ? 'العشاء' : 'Isha';

    final isFajrActive = !isTomorrowFajr && key == 'fajr';
    final isDhuhrActive = key == 'dhuhr';
    final isAsrActive = key == 'asr';
    final isMaghribActive = key == 'maghrib';
    final isIshaActive = key == 'isha';

    final isFajrPast =
        isAfterIsha || (fajr != null && now.isAfter(fajr) && !isFajrActive);
    final isDhuhrPast =
        isAfterIsha || (dhuhr != null && now.isAfter(dhuhr) && !isDhuhrActive);
    final isAsrPast =
        isAfterIsha || (asr != null && now.isAfter(asr) && !isAsrActive);
    final isMaghribPast =
        isAfterIsha ||
        (maghrib != null && now.isAfter(maghrib) && !isMaghribActive);
    final isIshaPast = isAfterIsha;

    final defaultNodeColor = isDark ? Colors.white38 : const Color(0xFF94A3B8);

    // Render all 5 daily prayer milestones with duration-proportional spacing
    // 1. Fajr (Horizon level, label below)
    drawNode(
      tFajr,
      defaultNodeColor,
      fajrLabel,
      isAbove: false,
      isActive: isFajrActive,
      isCompleted: isFajrPast,
    );

    // 2. Dhuhr (Zenith peak, label above)
    drawNode(
      tDhuhr,
      defaultNodeColor,
      dhuhrLabel,
      isAbove: true,
      isActive: isDhuhrActive,
      isCompleted: isDhuhrPast,
    );

    // 3. Asr (Upper slope, label above)
    drawNode(
      tAsr,
      defaultNodeColor,
      asrLabel,
      isAbove: true,
      isActive: isAsrActive,
      isCompleted: isAsrPast,
    );

    // 4. Maghrib (Lower slope, label above - prevents overlap with Isha below)
    drawNode(
      tMaghrib,
      defaultNodeColor,
      maghribLabel,
      isAbove: true,
      isActive: isMaghribActive,
      isCompleted: isMaghribPast,
    );

    // 5. Isha (Horizon level, label below)
    drawNode(
      tIsha,
      defaultNodeColor,
      ishaLabel,
      isAbove: false,
      isActive: isIshaActive,
      isCompleted: isIshaPast,
    );

    // Active Sunrise transition milestone (if active prayer is sunrise)
    if (key == 'sunrise' && tSunrise != null) {
      final sunriseLabel = isAr ? 'الشروق' : 'Sunrise';
      drawNode(
        tSunrise,
        const Color(0xFFF59E0B),
        sunriseLabel,
        isAbove: true,
        isActive: true,
        isCompleted: false,
      );
    }

    // 6. Draw Celestial Body: Sun during daytime, Crescent Moon (Hilal) during night
    final celestialPos = _evalCubic(p0, p1, p2, p3, progressT);

    if (!isNight) {
      // Outer halo
      final haloPaint = Paint()
        ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(celestialPos, 11.0, haloPaint);

      // Glowing sun disk
      final sunPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(celestialPos, 7.5, sunPaint);

      // Core white center
      final corePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(celestialPos, 3.5, corePaint);
    } else {
      // Soft nocturnal lunar aura
      final moonAuraPaint = Paint()
        ..color = const Color(0xFF818CF8).withValues(alpha: 0.28)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(celestialPos, 12.0, moonAuraPaint);

      // Luminous Crescent Moon (Hilal)
      final moonPath = Path()
        ..addOval(Rect.fromCircle(center: celestialPos, radius: 7.5));
      final cutPath = Path()
        ..addOval(
          Rect.fromCircle(
            center: celestialPos.translate(3.5, -2.0),
            radius: 6.2,
          ),
        );
      final crescent = Path.combine(
        PathOperation.difference,
        moonPath,
        cutPath,
      );

      final moonFillPaint = Paint()
        ..color = const Color(0xFFFDE68A)
        ..style = PaintingStyle.fill;
      canvas.drawPath(crescent, moonFillPaint);
    }
  }

  Offset _evalCubic(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;

    final x =
        uuu * p0.dx + 3 * uu * t * p1.dx + 3 * u * tt * p2.dx + ttt * p3.dx;
    final y =
        uuu * p0.dy + 3 * uu * t * p1.dy + 3 * u * tt * p2.dy + ttt * p3.dy;
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant _SolarArcPainter oldDelegate) {
    return oldDelegate.nextPrayer != nextPrayer ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isAr != isAr ||
        oldDelegate.prayerTimes != prayerTimes ||
        oldDelegate.now.minute != now.minute;
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

class _IslamicLatticeBackgroundPainter extends CustomPainter {
  final bool isDark;
  const _IslamicLatticeBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? const Color(0xFFE9C349).withValues(alpha: 0.025)
          : const Color(0xFF0F4C3A).withValues(alpha: 0.02)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 50.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), spacing * 0.45, paint);
        final path = Path()
          ..moveTo(x, y - spacing * 0.45)
          ..lineTo(x + spacing * 0.45, y)
          ..lineTo(x, y + spacing * 0.45)
          ..lineTo(x - spacing * 0.45, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicLatticeBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
