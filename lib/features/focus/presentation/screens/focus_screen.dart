import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/focus/presentation/widgets/focus_background_painters.dart';
import 'package:productive_muslim/features/focus/presentation/widgets/focus_completion_dialog.dart';
import 'package:productive_muslim/features/focus/presentation/widgets/focus_niyyah_banner.dart';
import 'package:productive_muslim/features/focus/presentation/widgets/focus_prayer_collision_card.dart';
import 'package:productive_muslim/features/focus/presentation/widgets/focus_preset_selector.dart';
import 'package:productive_muslim/features/focus/presentation/widgets/focus_salah_alignment_card.dart';
import 'package:productive_muslim/features/focus/presentation/widgets/focus_soundscape_card.dart';
import 'package:productive_muslim/features/focus/presentation/widgets/focus_task_card.dart';
import 'package:productive_muslim/features/focus/presentation/widgets/focus_timer_controls.dart';
import 'package:productive_muslim/features/focus/presentation/widgets/focus_timer_dial.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Focus & Khushu' session screen blending celestial timer cycles, ambient soundscapes,
/// prayer alignment protection, and spiritual intention anchoring.
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
    await showFocusCompletionDialog(
      context: context,
      selectedDurationMinutes: _selectedDurationMinutes,
      selectedTask: _selectedTask,
      onResetTimer: _resetTimer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSeconds = _selectedDurationMinutes * 60;

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

    final hasParentScaffold = Scaffold.maybeOf(context) != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: hasParentScaffold
          ? null
          : ProductiveAppBar(
              title: l10n.focusTitle,
              subtitle: _selectedTask != null
                  ? _selectedTask!.title
                  : l10n.focusSubtitle,
              showBackButton: true,
              actions: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
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
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.8),
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
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
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
                painter: IslamicLatticeBackgroundPainter(isDark: isDark),
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
                    const FocusNiyyahBanner(),

                    const SizedBox(height: 8),

                    // Prayer Collision Warning Card (when preparing session or wind-down)
                    FocusPrayerCollisionCard(
                      isPrayerCollision: isPrayerCollision,
                      isRunning: _isRunning,
                      nextPrayerName: _nextPrayerName,
                      timeUntilNextPrayer: _timeUntilNextPrayer,
                      onSelectPreset: _selectPreset,
                    ),

                    // Timer Dial with calm breathing pulse, cursor dot & Islamic Rosette watermark
                    FocusTimerDial(
                      isRunning: _isRunning,
                      secondsRemaining: _secondsRemaining,
                      totalSeconds: totalSeconds,
                    ),

                    const SizedBox(height: 12),

                    // Preset selector chips (if not running)
                    FocusPresetSelector(
                      presets: _presets,
                      selectedDurationMinutes: _selectedDurationMinutes,
                      onPresetSelected: _selectPreset,
                      isRunning: _isRunning,
                    ),

                    // Ambient Barakah Soundscape Section
                    FocusSoundscapeCard(
                      selectedSoundscapeIndex: _selectedSoundscapeIndex,
                      isRunning: _isRunning,
                      onSoundscapeChanged: (idx) {
                        setState(() => _selectedSoundscapeIndex = idx);
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Primary Action Controls matching Stitch
                    FocusTimerControls(
                      isRunning: _isRunning,
                      secondsRemaining: _secondsRemaining,
                      totalSeconds: totalSeconds,
                      onToggleTimer: _toggleTimer,
                      onResetTimer: _resetTimer,
                      onEndSession: _onSessionComplete,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Linked Focus Task Section (matching Stitch Luxury Card)
                    FocusTaskCard(
                      tasksStream: _tasksStream,
                      selectedTask: _selectedTask,
                      selectedDurationMinutes: _selectedDurationMinutes,
                      isRunning: _isRunning,
                      onTaskSelected: (task) {
                        setState(() => _selectedTask = task);
                      },
                      onClearTask: () {
                        setState(() => _selectedTask = null);
                      },
                    ),

                    // Salah Safe Alignment Indicator (when session is within safe window)
                    FocusSalahAlignmentCard(
                      isRunning: _isRunning,
                      timeUntilNextPrayer: _timeUntilNextPrayer,
                      isPrayerCollision: isPrayerCollision,
                      nextPrayerName: _nextPrayerName,
                      selectedDurationMinutes: _selectedDurationMinutes,
                    ),

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
}
