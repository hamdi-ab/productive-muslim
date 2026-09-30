import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/animated_progress_ring.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/core/widgets/gradient_card.dart';
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
    _tasksStream ??= context.read<TaskRepository>().watchTasksForDate(today);
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
    HapticFeedback.mediumImpact();
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
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _selectedDurationMinutes * 60;
    });
  }

  Future<void> _onSessionComplete() async {
    HapticFeedback.heavyImpact();
    try {
      final settings = getIt<SettingsService>();
      await settings.addFocusMinutes(_selectedDurationMinutes);
    } catch (_) {}

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    bool taskMarkedDone = false;
    final taskToComplete = _selectedTask;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.focusComplete,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.focusCompleteMessage),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_rounded, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '+$_selectedDurationMinutes min focus added',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
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
                label: Text(l10n.barakah),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _resetTimer();
                  GoRouter.of(context).go('/barakah');
                },
              ),
              FilledButton(
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.focusTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.focusTotalMinutes(totalFocusMins),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Niyyah & Islamic Focus Banner
                GradientCard(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.mosque_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l10n.focusNiyyahPrompt,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          l10n.focusDua,
                          style: const TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Prayer Collision Warning Card (when preparing session)
                if (!_isRunning &&
                    _timeUntilNextPrayer != null &&
                    _selectedDurationMinutes * 60 >
                        _timeUntilNextPrayer!.inSeconds - (5 * 60)) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
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
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.focusPrayerWarningTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF59E0B),
                                fontSize: 13,
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
                                _getLocalizedPrayerName(_nextPrayerName, l10n),
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
                  const SizedBox(height: AppSpacing.md),
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
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
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
                        Text(
                          l10n.focusWindDownWarning(
                            _timeUntilNextPrayer!.inMinutes,
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Timer Dial
                Center(
                  child: AnimatedProgressRing(
                    progress: progress,
                    size: 240,
                    strokeWidth: 14,
                    color: _isRunning ? AppColors.secondary : AppColors.primary,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_secondsRemaining),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRunning ? 'In Flow...' : 'Ready',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Preset selector (if not running)
                if (!_isRunning) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _presets.map((mins) {
                      final isSelected = _selectedDurationMinutes == mins;
                      return ChoiceChip(
                        label: Text('$mins min'),
                        selected: isSelected,
                        onSelected: (_) => _selectPreset(mins),
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Action Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isRunning ||
                        _secondsRemaining < _selectedDurationMinutes * 60)
                      IconButton.filledTonal(
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: l10n.focusReset,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _toggleTimer,
                      icon: Icon(
                        _isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 28,
                      ),
                      label: Text(
                        _isRunning ? l10n.focusPause : l10n.focusStart,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Task link card (Stream from TaskRepository)
                StreamBuilder<List<Task>>(
                  stream: _tasksStream,
                  builder: (context, snapshot) {
                    final tasks = snapshot.data ?? [];
                    if (tasks.isEmpty) return const SizedBox.shrink();

                    Task? matchedTask;
                    if (_selectedTask != null) {
                      for (final task in tasks) {
                        if (task.id == _selectedTask?.id) {
                          matchedTask = task;
                          break;
                        }
                      }
                    }

                    return GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.task_alt_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.focusSelectTask,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Task?>(
                            initialValue: matchedTask,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.darkSurfaceSubtle
                                  : AppColors.surfaceSubtle,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<Task?>(
                                value: null,
                                child: Text('No task selected (General Focus)'),
                              ),
                              ...tasks.map(
                                (t) => DropdownMenuItem<Task?>(
                                  value: t,
                                  child: Text(
                                    t.title,
                                    overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
