import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/animated_progress_ring.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/core/widgets/pulsing_glow.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class FocusScreen extends StatefulWidget {
  final Task? initialTask;

  const FocusScreen({super.key, this.initialTask});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int _selectedDurationMinutes = 25;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  Task? _selectedTask;
  Stream<List<Task>>? _tasksStream;
  String _nextPrayerName = 'Fajr';
  DateTime? _nextPrayerTime;
  Duration? _timeUntilNextPrayer;
  int _selectedSoundscapeIndex =
      0; // 0: Rain & Makkah, 1: Gentle Stream, 2: Pure Silence

  final _presets = [15, 25, 45, 60];

  @override
  void initState() {
    super.initState();
    _selectedTask = widget.initialTask;
    _secondsRemaining = _selectedDurationMinutes * 60;
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    if (!getIt.isRegistered<PrayerTimeService>()) return;
    try {
      final service = getIt<PrayerTimeService>();
      if (service.cachedPrayerTimes != null) {
        final pt = service.cachedPrayerTimes!;
        final next = service.getNextPrayerName(pt) ?? 'Fajr';
        final nextTime = service.getNextPrayerTime(pt);
        final until = service.getTimeUntilNextPrayer(pt);
        if (mounted) {
          setState(() {
            _nextPrayerName = next;
            _nextPrayerTime = nextTime;
            _timeUntilNextPrayer = until;
          });
        }
      }
      final position = await service.getCurrentPosition();
      if (position != null) {
        final pt = service.getPrayerTimes(position);
        if (pt != null) {
          final next = service.getNextPrayerName(pt) ?? 'Fajr';
          final nextTime = service.getNextPrayerTime(pt);
          final until = service.getTimeUntilNextPrayer(pt);
          if (mounted) {
            setState(() {
              _nextPrayerName = next;
              _nextPrayerTime = nextTime;
              _timeUntilNextPrayer = until;
            });
          }
        }
      }
    } catch (_) {}
  }

  String _getLocalizedPrayerName(String prayerName, AppLocalizations l10n) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return l10n.fajr;
      case 'sunrise':
        return l10n.sunrise;
      case 'dhuhr':
        return l10n.dhuhr;
      case 'asr':
        return l10n.asr;
      case 'maghrib':
        return l10n.maghrib;
      case 'isha':
        return l10n.isha;
      default:
        return prayerName;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    _tasksStream ??= context
        .read<TaskRepository>()
        .watchTasksForDate(today)
        .asBroadcastStream();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectPreset(int minutes) {
    if (_isRunning) return;
    setState(() {
      _selectedDurationMinutes = minutes;
      _secondsRemaining = minutes * 60;
    });
  }

  void _toggleTimer() {
    AppHaptics.mediumImpact();
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
          if (_nextPrayerTime != null) {
            _timeUntilNextPrayer = _nextPrayerTime!.difference(DateTime.now());
          }
        });
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _onSessionComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    AppHaptics.lightImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _selectedDurationMinutes * 60;
    });
  }

  Future<void> _onSessionComplete() async {
    AppHaptics.heavyImpact();
    try {
      final settings = getIt<SettingsService>();
      await settings.addFocusMinutes(_selectedDurationMinutes);
    } catch (_) {}

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool taskMarkedDone = false;
    final taskToComplete = _selectedTask;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: (isDark ? AppColors.secondary : AppColors.primary)
                    .withValues(alpha: 0.25),
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.focusComplete,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.focusCompleteMessage,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.25 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_rounded,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '+$_selectedDurationMinutes min focus added',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (taskToComplete != null && !taskToComplete.completed) ...[
                  const SizedBox(height: 14),
                  if (taskMarkedDone)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.focusTaskCompletedSuccess,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: Text(l10n.focusMarkTaskComplete),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final success = await context
                              .read<TaskRepository>()
                              .updateTask(
                                taskToComplete.copyWith(completed: true),
                              );
                          if (success) {
                            setDialogState(() {
                              taskMarkedDone = true;
                            });
                          }
                        } catch (_) {}
                      },
                    ),
                ],
              ],
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(
                  Icons.favorite_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
                label: Text(
                  l10n.barakah,
                  style: const TextStyle(color: AppColors.secondary),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _resetTimer();
                  GoRouter.of(context).go('/barakah');
                },
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _resetTimer();
                },
                child: Text(l10n.done),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final totalSeconds = _selectedDurationMinutes * 60;
    final progress = totalSeconds > 0
        ? (_secondsRemaining / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    final totalFocusMins = () {
      try {
        return getIt<SettingsService>().totalFocusMinutes;
      } catch (_) {
        return 0;
      }
    }();

    final isPrayerCollision =
        !_isRunning &&
        _timeUntilNextPrayer != null &&
        _selectedDurationMinutes * 60 >
            _timeUntilNextPrayer!.inSeconds - (5 * 60);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: ProductiveAppBar(
        title: l10n.focusTitle,
        subtitle: _selectedTask != null
            ? _selectedTask!.title
            : l10n.focusSubtitle,
        showBackButton: true,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryLight.withValues(alpha: 0.16)
                  : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.primaryLight.withValues(alpha: 0.3)
                    : AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.8),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.insights_rounded,
                  size: 14,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                const SizedBox(width: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    l10n.focusTotalMinutes(totalFocusMins),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Islamic Rosette Lattice Watermark (matching Stitch obsidian/emerald design)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _IslamicLatticeBackgroundPainter(isDark: isDark),
              ),
            ),
          ),

          // Ambient Background Glow Orbs matching Stitch luxury aesthetic
          if (isDark) ...[
            Positioned(
              top: -100,
              left: MediaQuery.of(context).size.width / 2 - 150,
              child: IgnorePointer(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF10B981).withValues(alpha: 0.20),
                        const Color(0xFF0F4C3A).withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 240,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: IgnorePointer(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryLight.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 8,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Spiritual Intention (Niyyah) Header Banner
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      borderColor:
                          (isDark ? AppColors.secondary : AppColors.primary)
                              .withValues(alpha: 0.22),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'رَّبِّ زِدْنِي عِلْمًا',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                    height: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.secondary.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'بِسْمِ اللَّهِ — ${l10n.focusNiyyahPrompt}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '“${l10n.focusDua}”',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.secondary,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    isRtl ? 'خالص لله' : 'Sanctified',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Prayer Collision Warning Card (when preparing session)
                    if (isPrayerCollision) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.focusPrayerWarningTitle,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF59E0B),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.focusPrayerOverlap(
                                _getLocalizedPrayerName(_nextPrayerName, l10n),
                                _timeUntilNextPrayer!.inMinutes,
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (_timeUntilNextPrayer!.inMinutes >= 10) ...[
                              const SizedBox(height: 10),
                              ActionChip(
                                avatar: const Icon(
                                  Icons.timer_outlined,
                                  size: 14,
                                  color: Color(0xFFF59E0B),
                                ),
                                label: Text(
                                  l10n.focusPrayerSuggestion(
                                    (_timeUntilNextPrayer!.inMinutes - 5).clamp(
                                      5,
                                      60,
                                    ),
                                    _getLocalizedPrayerName(
                                      _nextPrayerName,
                                      l10n,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  _selectPreset(
                                    (_timeUntilNextPrayer!.inMinutes - 5).clamp(
                                      5,
                                      60,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Wind-Down Indicator (when running and prayer is near)
                    if (_isRunning &&
                        _timeUntilNextPrayer != null &&
                        _timeUntilNextPrayer!.inMinutes <= 10) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_filled_rounded,
                              color: Color(0xFFF59E0B),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n.focusWindDownWarning(
                                  _timeUntilNextPrayer!.inMinutes,
                                ),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Timer Dial with calm breathing pulse, cursor dot & Islamic Rosette watermark
                    Center(
                      child: PulsingGlow(
                        animate: _isRunning,
                        minScale: 0.985,
                        maxScale: 1.015,
                        duration: const Duration(milliseconds: 2400),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Ambient Glow
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_isRunning
                                                ? AppColors.secondary
                                                : const Color(0xFF10B981))
                                            .withValues(
                                              alpha: isDark ? 0.22 : 0.10,
                                            ),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),

                            // Islamic 8-Point Rosette Watermark
                            CustomPaint(
                              size: const Size(160, 160),
                              painter: _IslamicRosettePainter(
                                color:
                                    (isDark
                                            ? AppColors.secondary
                                            : AppColors.primary)
                                        .withValues(
                                          alpha: isDark ? 0.11 : 0.07,
                                        ),
                              ),
                            ),

                            // Animated Progress Ring with circumference glowing cursor dot
                            AnimatedProgressRing(
                              progress: progress,
                              size: 220,
                              strokeWidth: 10,
                              color: _isRunning
                                  ? AppColors.secondary
                                  : const Color(0xFF10B981),
                              glowColor: _isRunning
                                  ? AppColors.secondaryLight
                                  : const Color(0xFF4EDEA3),
                              showCursorDot: true,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Barakah Flow pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.primary.withValues(
                                                  alpha: 0.45,
                                                )
                                              : AppColors.primary.withValues(
                                                  alpha: 0.1,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: isDark
                                                ? AppColors.primaryLight
                                                      .withValues(alpha: 0.35)
                                                : AppColors.primary.withValues(
                                                    alpha: 0.2,
                                                  ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 5,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _isRunning
                                                    ? AppColors.secondary
                                                    : const Color(0xFF10B981),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        (_isRunning
                                                                ? AppColors
                                                                      .secondary
                                                                : const Color(
                                                                    0xFF10B981,
                                                                  ))
                                                            .withValues(
                                                              alpha: 0.8,
                                                            ),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'BARAKAH FLOW',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.7,
                                                color: isDark
                                                    ? const Color(0xFF4EDEA3)
                                                    : AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatTime(_secondsRemaining),
                                        style: const TextStyle(
                                          fontSize: 44,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -1.2,
                                          fontFeatures: [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: Text(
                                          _isRunning ? 'In Flow...' : 'Ready',
                                          key: ValueKey(
                                            'focus_status_$_isRunning',
                                          ),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        _isRunning
                                            ? 'Khushu\' State • Level 1 Active'
                                            : 'Ready • Level 1 Calm',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                                    .withValues(alpha: 0.6)
                                              : AppColors.textSecondary
                                                    .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Preset selector chips (if not running)
                    if (!_isRunning) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: _presets.map((mins) {
                          final isSelected = _selectedDurationMinutes == mins;
                          final tag = switch (mins) {
                            15 => 'Sprint',
                            25 => 'Barakah',
                            45 => 'Deep',
                            _ => 'Mastery',
                          };
                          return AppPressable(
                            onTap: () {
                              AppHaptics.selectionClick();
                              _selectPreset(mins);
                            },
                            pressedScale: 0.92,
                            haptic: AppHapticFeedback.none,
                            child: ChoiceChip(
                              label: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$mins min',
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      fontSize: 12,
                                      color: isSelected
                                          ? (isDark
                                                ? Colors.white
                                                : AppColors.primaryDark)
                                          : (isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.textSecondary),
                                    ),
                                  ),
                                  Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? (isDark
                                                ? AppColors.secondary
                                                : AppColors.secondaryDark)
                                          : (isDark
                                                ? AppColors.darkTextSecondary
                                                      .withValues(alpha: 0.6)
                                                : AppColors.textSecondary
                                                      .withValues(alpha: 0.6)),
                                    ),
                                  ),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (_) {
                                AppHaptics.selectionClick();
                                _selectPreset(mins);
                              },
                              backgroundColor: isDark
                                  ? AppColors.darkSurfaceSubtle.withValues(
                                      alpha: 0.6,
                                    )
                                  : AppColors.surfaceSubtle,
                              selectedColor: isDark
                                  ? AppColors.primary.withValues(alpha: 0.45)
                                  : AppColors.primary.withValues(alpha: 0.15),
                              side: BorderSide(
                                color: isSelected
                                    ? (isDark
                                          ? AppColors.secondary
                                          : AppColors.primary)
                                    : (isDark
                                          ? AppColors.borderDark
                                          : AppColors.borderLight),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Ambient Barakah Soundscape Section
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      borderColor: isDark
                          ? AppColors.borderDark.withValues(alpha: 0.5)
                          : AppColors.borderLight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.graphic_eq_rounded,
                                      size: 18,
                                      color: AppColors.secondary,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'AMBIENT BARAKAH SOUNDSCAPE',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.6,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Audio wave visualizer bars
                              _SoundWaveVisualizer(
                                isPlaying:
                                    _isRunning && _selectedSoundscapeIndex != 2,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildSoundscapePill(
                                index: 0,
                                icon: Icons.water_drop_rounded,
                                title: 'Rain & Makkah',
                                subtitle: _selectedSoundscapeIndex == 0
                                    ? 'Active'
                                    : 'Offline',
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                              _buildSoundscapePill(
                                index: 1,
                                icon: Icons.waves_rounded,
                                title: 'Gentle Stream',
                                subtitle: _selectedSoundscapeIndex == 1
                                    ? 'Active'
                                    : 'Offline',
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                              _buildSoundscapePill(
                                index: 2,
                                icon: Icons.volume_off_rounded,
                                title: 'Pure Silence',
                                subtitle: _selectedSoundscapeIndex == 2
                                    ? 'Active'
                                    : 'Muted',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Primary Action Controls matching Stitch
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Reset button
                          if (_isRunning ||
                              _secondsRemaining < _selectedDurationMinutes * 60)
                            AppPressable(
                              onTap: _resetTimer,
                              pressedScale: 0.88,
                              haptic: AppHapticFeedback.none,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? AppColors.darkSurfaceSubtle
                                      : AppColors.surfaceSubtle,
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  size: 22,
                                ),
                              ),
                            ),
                          if (_isRunning ||
                              _secondsRemaining < _selectedDurationMinutes * 60)
                            const SizedBox(width: 14),

                          // Main Glowing Action Button
                          AppPressable(
                            onTap: _toggleTimer,
                            pressedScale: 0.94,
                            haptic: AppHapticFeedback.none,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: _isRunning
                                    ? AppColors.goldGradient
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFF0F4C3A),
                                          Color(0xFF10B981),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_isRunning
                                                ? AppColors.secondary
                                                : AppColors.primaryLight)
                                            .withValues(alpha: 0.35),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color:
                                      (_isRunning
                                              ? AppColors.secondaryLight
                                              : AppColors.primaryLight)
                                          .withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    transitionBuilder: (child, anim) =>
                                        ScaleTransition(
                                          scale: anim,
                                          child: child,
                                        ),
                                    child: Icon(
                                      _isRunning
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      key: ValueKey('timer_icon_$_isRunning'),
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _isRunning
                                        ? l10n.focusPause
                                        : l10n.focusStart,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // End Session / Muhasabah Button
                          if (_isRunning) ...[
                            const SizedBox(width: 14),
                            AppPressable(
                              onTap: _onSessionComplete,
                              pressedScale: 0.88,
                              haptic: AppHapticFeedback.none,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? AppColors.darkSurfaceSubtle
                                      : AppColors.surfaceSubtle,
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.flag_rounded,
                                  size: 22,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Linked Focus Task Section (matching Stitch Luxury Card)
                    StreamBuilder<List<Task>>(
                      key: const ValueKey('focus_task_stream_builder'),
                      stream: _tasksStream,
                      builder: (context, snapshot) {
                        final tasks = snapshot.data ?? [];
                        if (tasks.isEmpty && _selectedTask == null) {
                          return const SizedBox.shrink();
                        }

                        Task? matchedTask;
                        if (_selectedTask != null) {
                          for (final task in tasks) {
                            if (task.id == _selectedTask?.id) {
                              matchedTask = task;
                              break;
                            }
                          }
                          matchedTask ??= _selectedTask;
                        }

                        if (matchedTask != null) {
                          return GlassContainer(
                            padding: const EdgeInsets.all(14),
                            borderRadius: 18,
                            borderColor: isDark
                                ? AppColors.secondary.withValues(alpha: 0.25)
                                : AppColors.primary.withValues(alpha: 0.2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.task_alt_rounded,
                                            size: 16,
                                            color: AppColors.secondary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'LINKED SACRED TASK',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                                letterSpacing: 0.6,
                                                color: isDark
                                                    ? AppColors.secondaryLight
                                                    : AppColors.secondaryDark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!_isRunning)
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => _selectedTask = null,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withValues(
                                              alpha: 0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Text(
                                            'Clear',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkSurfaceSubtle
                                        : AppColors.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.borderDark.withValues(
                                              alpha: 0.6,
                                            )
                                          : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        matchedTask.completed
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                  .radio_button_unchecked_rounded,
                                        color: matchedTask.completed
                                            ? const Color(0xFF10B981)
                                            : AppColors.secondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              matchedTask.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? AppColors.darkTextPrimary
                                                    : AppColors.textPrimary,
                                                decoration:
                                                    matchedTask.completed
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.secondary
                                                        .withValues(
                                                          alpha: 0.14,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    matchedTask
                                                            .lifeArea
                                                            .isNotEmpty
                                                        ? matchedTask.lifeArea
                                                        : 'Focus Target',
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColors.secondary,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .primaryLight
                                                        .withValues(
                                                          alpha: 0.14,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${_selectedDurationMinutes}m Target',
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .primaryLight,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 20,
                          borderColor: isDark
                              ? AppColors.borderDark.withValues(alpha: 0.4)
                              : AppColors.borderLight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.task_alt_rounded,
                                    size: 18,
                                    color: AppColors.primaryLight,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      l10n.focusSelectTask,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<Task?>(
                                initialValue: null,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? AppColors.darkSurfaceSubtle
                                      : AppColors.surfaceSubtle,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<Task?>(
                                    value: null,
                                    child: Text(
                                      'No task selected (General Focus)',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  ...tasks.map(
                                    (t) => DropdownMenuItem<Task?>(
                                      value: t,
                                      child: Row(
                                        children: [
                                          Icon(
                                            t.completed
                                                ? Icons.check_circle_rounded
                                                : Icons
                                                      .radio_button_unchecked_rounded,
                                            size: 16,
                                            color: t.completed
                                                ? AppColors.primaryLight
                                                : AppColors.textDisabled,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              t.title,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                decoration: t.completed
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: _isRunning
                                    ? null
                                    : (task) {
                                        setState(() => _selectedTask = task);
                                      },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Salah Safe Alignment Indicator (when session is within safe window)
                    if (!_isRunning &&
                        _timeUntilNextPrayer != null &&
                        !isPrayerCollision) ...[
                      const SizedBox(height: AppSpacing.md),
                      GlassContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        borderColor: AppColors.primaryLight.withValues(
                          alpha: 0.25,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.primaryLight.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.mosque_rounded,
                                size: 18,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 2,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        'Next: ${_getLocalizedPrayerName(_nextPrayerName, l10n)} in ${_timeUntilNextPrayer!.inMinutes}m',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Text(
                                          'Salah Safe Alignment',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Session finishes safely ${_timeUntilNextPrayer!.inMinutes - _selectedDurationMinutes}m before prayer call.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.lock_clock_rounded,
                              size: 18,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundscapePill({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    final isSelected = _selectedSoundscapeIndex == index;
    return Expanded(
      child: AppPressable(
        onTap: () {
          AppHaptics.selectionClick();
          setState(() => _selectedSoundscapeIndex = index);
        },
        pressedScale: 0.94,
        haptic: AppHapticFeedback.none,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : AppColors.primary.withValues(alpha: 0.12))
                : (isDark
                      ? AppColors.darkSurfaceSubtle.withValues(alpha: 0.5)
                      : AppColors.surfaceSubtle),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark
                        ? AppColors.borderDark.withValues(alpha: 0.5)
                        : AppColors.borderLight),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary)
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 8,
                    color: isSelected
                        ? AppColors.primaryLight
                        : (isDark
                              ? AppColors.darkTextSecondary.withValues(
                                  alpha: 0.5,
                                )
                              : AppColors.textSecondary.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Subtle Islamic geometric lattice watermark painter for background ambiance
class _IslamicLatticeBackgroundPainter extends CustomPainter {
  final bool isDark;

  const _IslamicLatticeBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? const Color(0xFF10B981) : AppColors.primary)
          .withValues(alpha: isDark ? 0.025 : 0.015)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const step = 56.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        canvas.drawCircle(Offset(x, y), step * 0.35, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicLatticeBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Animated 4-bar equalizer for the spiritual soundscape
class _SoundWaveVisualizer extends StatefulWidget {
  final bool isPlaying;

  const _SoundWaveVisualizer({required this.isPlaying});

  @override
  State<_SoundWaveVisualizer> createState() => _SoundWaveVisualizerState();
}

class _SoundWaveVisualizerState extends State<_SoundWaveVisualizer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  bool get _isTestEnvironment =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    if (!_isTestEnvironment) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
      if (widget.isPlaying) {
        _controller?.repeat(reverse: true);
      }
    }
  }

  @override
  void didUpdateWidget(covariant _SoundWaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isTestEnvironment && _controller != null) {
      if (widget.isPlaying && !oldWidget.isPlaying) {
        _controller?.repeat(reverse: true);
      } else if (!widget.isPlaying && oldWidget.isPlaying) {
        _controller?.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTestEnvironment || _controller == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bar(widget.isPlaying ? 12 : 4),
          const SizedBox(width: 3),
          _bar(widget.isPlaying ? 8 : 4),
          const SizedBox(width: 3),
          _bar(widget.isPlaying ? 14 : 4),
          const SizedBox(width: 3),
          _bar(widget.isPlaying ? 6 : 4),
        ],
      );
    }

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, _) {
        final val = _controller!.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _bar(widget.isPlaying ? 6 + 10 * sin(val * pi) : 4),
            const SizedBox(width: 3),
            _bar(widget.isPlaying ? 4 + 12 * cos(val * pi).abs() : 4),
            const SizedBox(width: 3),
            _bar(widget.isPlaying ? 8 + 8 * sin((val + 0.5) * pi).abs() : 4),
            const SizedBox(width: 3),
            _bar(widget.isPlaying ? 5 + 11 * cos((val + 0.2) * pi).abs() : 4),
          ],
        );
      },
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 3,
      height: height.clamp(4.0, 18.0),
      decoration: BoxDecoration(
        color: widget.isPlaying
            ? AppColors.primaryLight
            : AppColors.textDisabled,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Geometric Khatam / 8-pointed star Islamic rosette watermark
class _IslamicRosettePainter extends CustomPainter {
  final Color color;

  const _IslamicRosettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final side = size.width * 0.54;
    final rect = Rect.fromCenter(center: center, width: side, height: side);

    // Square 1
    canvas.drawRect(rect, paint);

    // Square 2 (rotated 45 degrees)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 4);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: side, height: side),
      paint,
    );
    canvas.restore();

    // Concentric celestial guidance rings
    canvas.drawCircle(center, side * 0.58, paint);
    canvas.drawCircle(center, side * 0.28, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicRosettePainter oldDelegate) =>
      oldDelegate.color != color;
}
