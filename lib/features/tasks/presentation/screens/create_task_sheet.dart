import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/constants/app_life_areas.dart';
import 'package:productive_muslim/core/constants/app_prayer_slots.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/arabic_typography.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/domain/models/task.dart';
import 'package:productive_muslim/features/tasks/logic/task_bloc.dart';
import 'package:productive_muslim/features/tasks/logic/task_event.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class CreateTaskSheet extends StatefulWidget {
  final String date;
  final VoidCallback? onSwitchToHabit;

  const CreateTaskSheet({super.key, required this.date, this.onSwitchToHabit});

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _lifeArea = 'spiritual';
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedPrayerSlot;
  int? _selectedFocusSprintMinutes;
  final Set<String> _selectedQualities = {'Ihsan', 'Ikhlas'};
  bool _repeatDaily = false;
  bool _repeatWeekly = false;
  bool _showAdvanced = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSave => _titleController.text.trim().isNotEmpty;

  int? _timeToMinutes(TimeOfDay? time) {
    if (time == null) return null;
    return time.hour * 60 + time.minute;
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 10, minute: 0));

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        _selectedPrayerSlot = null;
        if (isStart) {
          _startTime = picked;
          _endTime ??= TimeOfDay(
            hour: (picked.hour + 1) % 24,
            minute: picked.minute,
          );
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _selectPrayerSlot(BarakahSlot slot) async {
    AppHaptics.selectionClick();
    int startMins = slot.defaultStartMinutes;
    int endMins = slot.defaultEndMinutes;

    try {
      if (getIt.isRegistered<PrayerTimeService>()) {
        final prayerService = getIt<PrayerTimeService>();
        final pos = await prayerService.getCurrentPosition();
        if (pos != null) {
          DateTime? taskDate;
          try {
            taskDate = DateTime.parse(widget.date);
          } catch (_) {}
          final pt = prayerService.getPrayerTimes(pos, date: taskDate);
          final calculated = prayerService.getSlotMinutes(slot.id, pt);
          startMins = calculated.startMinutes;
          endMins = calculated.endMinutes;
        }
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _selectedPrayerSlot = slot.id;
      _startTime = TimeOfDay(
        hour: (startMins ~/ 60) % 24,
        minute: startMins % 60,
      );
      _endTime = TimeOfDay(hour: (endMins ~/ 60) % 24, minute: endMins % 60);
      _selectedFocusSprintMinutes = null;
    });
  }

  void _selectFocusSprint(int minutes) {
    AppHaptics.selectionClick();
    setState(() {
      _selectedFocusSprintMinutes = minutes;
      final start = _startTime ?? TimeOfDay.now();
      _startTime = start;
      final totalEndMinutes =
          (start.hour * 60 + start.minute + minutes) % (24 * 60);
      _endTime = TimeOfDay(
        hour: totalEndMinutes ~/ 60,
        minute: totalEndMinutes % 60,
      );
    });
  }

  void _clearTime() {
    AppHaptics.lightImpact();
    setState(() {
      _selectedPrayerSlot = null;
      _selectedFocusSprintMinutes = null;
      _startTime = null;
      _endTime = null;
    });
  }

  void _toggleQuality(String quality) {
    AppHaptics.selectionClick();
    setState(() {
      if (_selectedQualities.contains(quality)) {
        _selectedQualities.remove(quality);
      } else {
        _selectedQualities.add(quality);
      }
    });
  }

  void _renewIntentionPrompt() {
    AppHaptics.lightImpact();
    if (_titleController.text.isEmpty) {
      _titleController.text = 'Deep Work: System Focus with Ihsan';
    }
    if (_notesController.text.isEmpty) {
      _notesController.text = 'O Allah, I dedicate this work to seek Your pleasure, halal sustenance, and to benefit the Ummah with excellence.';
    }
    setState(() {});
  }

  void _save() {
    if (!_canSave) return;

    final notesText = _notesController.text.trim();
    final task = Task(
      id: 0,
      title: _titleController.text.trim(),
      lifeArea: _lifeArea,
      startMinutes: _timeToMinutes(_startTime),
      endMinutes: _timeToMinutes(_endTime),
      date: widget.date,
      repeatDaily: _repeatDaily,
      repeatWeekly: _repeatWeekly,
      notes: notesText.isEmpty ? null : notesText,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    context.read<TaskBloc>().add(TaskCreated(task));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1512) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark
              ? const Color(0xFF404944).withValues(alpha: 0.5)
              : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.35 : 0.12,
            ),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ambient Spiritual Top Accent Hairline
              Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 48),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFFE9C349).withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF8A938D).withValues(alpha: 0.35)
                        : AppColors.textSecondary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Spiritual Sanctuary Header Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                  textDirection: TextDirection.rtl,
                                  style: ArabicFontFamily.amiri.getTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFE9C349),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE9C349),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.newTask,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFDAE5E0)
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF222C29)
                            : AppColors.surfaceSubtle,
                        foregroundColor: isDark
                            ? const Color(0xFFDAE5E0)
                            : AppColors.textPrimary,
                        padding: const EdgeInsets.all(6),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // Scrollable Form Fields
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    bottomPadding > 0
                        ? bottomPadding + AppSpacing.md
                        : AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Task Title Input
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              l10n.taskTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '*',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Title TextField (1 of 2)
                      TextField(
                        controller: _titleController,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'e.g., Deep Work: Complete System Architecture',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary.withValues(
                                    alpha: 0.6,
                                  )
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.6,
                                  ),
                          ),
                          prefixIcon: const Icon(
                            Icons.edit_note_rounded,
                            size: 20,
                            color: AppColors.primaryLight,
                          ),
                          suffixIcon: _titleController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _titleController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF141E1A)
                              : AppColors.surfaceSubtle,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF404944)
                                        .withValues(alpha: 0.5)
                                  : AppColors.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF404944)
                                        .withValues(alpha: 0.5)
                                  : AppColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF4EDEA3),
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Life Area / 3 Spheres Dimension Section
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.lifeArea,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Islamic Holism',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _LifeAreaSelector(
                        selected: _lifeArea,
                        onChanged: (area) => setState(() => _lifeArea = area),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Prayer-Anchored Routine Window Section
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    l10n.prayerSlot,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.wb_sunny_rounded,
                                    size: 10,
                                    color: AppColors.secondary,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Sunnah Routine',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: BarakahSlot.all.map((slot) {
                            final isSelected = _selectedPrayerSlot == slot.id;
                            final label = switch (slot.id) {
                              'early_morning' => l10n.slotEarlyMorning,
                              'duha' => l10n.slotDuha,
                              'dhuhr' => l10n.slotDhuhr,
                              'asr' => l10n.slotAsr,
                              'maghrib' => l10n.slotMaghrib,
                              'isha' => l10n.slotIsha,
                              _ => slot.id,
                            };

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                avatar: Icon(
                                  slot.icon,
                                  size: 15,
                                  color: isSelected
                                      ? (isDark
                                            ? AppColors.secondary
                                            : AppColors.primary)
                                      : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary),
                                ),
                                label: Text(label),
                                selected: isSelected,
                                selectedColor: AppColors.primary.withValues(
                                  alpha: 0.22,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.secondary.withValues(
                                            alpha: 0.7,
                                          )
                                        : (isDark
                                              ? AppColors.borderDark
                                              : AppColors.borderLight),
                                    width: isSelected ? 1.2 : 0.8,
                                  ),
                                ),
                                onSelected: (_) => _selectPrayerSlot(slot),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Scheduled Time Section
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.taskScheduled,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                            ),
                          ),
                          if (_startTime != null || _endTime != null) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: TextButton.icon(
                                  onPressed: _clearTime,
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                  ),
                                  label: Text(
                                    l10n.cancel,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    foregroundColor: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeButton(
                              label: l10n.taskStartTime,
                              time: _startTime,
                              onTap: () => _pickTime(isStart: true),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _TimeButton(
                              label: l10n.taskEndTime,
                              time: _endTime,
                              onTap: () => _pickTime(isStart: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Notes & Intention Dua input (TextField 2 of 2)
                      Row(
                        children: [
                          const Icon(
                            Icons.edit_note_rounded,
                            size: 15,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Intention (Niyyah) & Notes',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: InkWell(
                                onTap: _renewIntentionPrompt,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 11,
                                        color: AppColors.secondary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Auto-fill Niyyah',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryLight,
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
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _notesController,
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'O Allah, I dedicate this work to serve You, seek halal sustenance, and benefit others...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: isDark
                                ? AppColors.darkTextSecondary.withValues(
                                    alpha: 0.5,
                                  )
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.6,
                                  ),
                          ),
                          labelText: l10n.taskNotes,
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF141E1A)
                              : AppColors.surfaceSubtle,
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF404944)
                                        .withValues(alpha: 0.5)
                                  : AppColors.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF404944)
                                        .withValues(alpha: 0.5)
                                  : AppColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF4EDEA3),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Progressive Disclosure Accordion: Focus Sprint, Qualities & Repeat
                      InkWell(
                        onTap: () {
                          AppHaptics.lightImpact();
                          setState(() => _showAdvanced = !_showAdvanced);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF141E1A)
                                : AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF404944)
                                        .withValues(alpha: 0.4)
                                  : AppColors.borderLight,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 16,
                                color: isDark
                                    ? AppColors.secondary
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Focus Sprint, Qualities & Repeat',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _showAdvanced
                                          ? 'Tap to collapse options'
                                          : 'Khushu sprints, Barakah qualities, repeat rules',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _showAdvanced
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                                size: 20,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_showAdvanced) ...[
                        const SizedBox(height: AppSpacing.md),

                        // Khushu' Focus Sprints
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Khushu' Focus Sprint",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Mindful Single-Tasking',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            _buildSprintChip(15, '15m', 'Micro', isDark),
                            const SizedBox(width: 8),
                            _buildSprintChip(
                              25,
                              '25m',
                              'Barakah',
                              isDark,
                              isIdeal: true,
                            ),
                            const SizedBox(width: 8),
                            _buildSprintChip(45, '45m', 'Deep', isDark),
                            const SizedBox(width: 8),
                            _buildSprintChip(90, '90m', 'Mastery', isDark),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Barakah Quality Alignment (9 Qualities framework)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Barakah Quality Alignment',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Spiritual Fuel',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildQualityChip(
                              'Ihsan',
                              l10n.qualityIhsan,
                              Icons.star_rounded,
                              isDark,
                            ),
                            _buildQualityChip(
                              'Ikhlas',
                              l10n.qualityIkhlas,
                              Icons.favorite_rounded,
                              isDark,
                            ),
                            _buildQualityChip(
                              'Sabr',
                              l10n.qualitySabr,
                              Icons.spa_rounded,
                              isDark,
                            ),
                            _buildQualityChip(
                              'Tawakkul',
                              l10n.qualityTawakkul,
                              Icons.shield_rounded,
                              isDark,
                            ),
                            _buildQualityChip(
                              'Istiqamah',
                              'Istiqamah',
                              Icons.trending_up_rounded,
                              isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Repeat Section
                        Text(
                          l10n.taskRepeat,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: 6,
                          children: [
                            FilterChip(
                              avatar: Icon(
                                Icons.repeat_rounded,
                                size: 15,
                                color: _repeatDaily
                                    ? AppColors.primaryLight
                                    : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary),
                              ),
                              label: Text(l10n.taskRepeatDaily),
                              selected: _repeatDaily,
                              selectedColor: AppColors.primary.withValues(
                                alpha: 0.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (selected) {
                                AppHaptics.selectionClick();
                                setState(() => _repeatDaily = selected);
                              },
                            ),
                            FilterChip(
                              avatar: Icon(
                                Icons.calendar_view_week_rounded,
                                size: 15,
                                color: _repeatWeekly
                                    ? AppColors.primaryLight
                                    : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary),
                              ),
                              label: Text(l10n.taskRepeatWeekly),
                              selected: _repeatWeekly,
                              selectedColor: AppColors.primary.withValues(
                                alpha: 0.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (selected) {
                                AppHaptics.selectionClick();
                                setState(() => _repeatWeekly = selected);
                              },
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),

                      // Primary CTA Button: Bismillah — Create Task
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: _canSave
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF0F4C3A),
                                    Color(0xFF135A46),
                                    Color(0xFF0F4C3A),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          color: _canSave
                              ? null
                              : Colors.grey.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _canSave
                                ? const Color(0xFFE9C349).withValues(alpha: 0.6)
                                : Colors.transparent,
                            width: 1,
                          ),
                          boxShadow: _canSave
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFE9C349)
                                        .withValues(alpha: 0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _canSave ? _save : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.bolt_rounded,
                                        size: 20,
                                        color: _canSave
                                            ? const Color(0xFFE9C349)
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Bismillah — ${l10n.save}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _canSave
                                              ? const Color(0xFFE9C349)
                                              : Colors.grey,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Sync notice caption
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sync_rounded,
                                size: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Will sync with daily Barakah agenda',
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSprintChip(
    int minutes,
    String title,
    String subtitle,
    bool isDark, {
    bool isIdeal = false,
  }) {
    final isSelected = _selectedFocusSprintMinutes == minutes;
    return Expanded(
      child: InkWell(
        onTap: () => _selectFocusSprint(minutes),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.25)
                : (isDark
                      ? AppColors.darkSurfaceSubtle
                      : AppColors.surfaceSubtle),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.secondary
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: isSelected ? 1.4 : 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isIdeal)
                Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'IDEAL',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (isDark ? AppColors.secondary : AppColors.primary)
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQualityChip(
    String key,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _selectedQualities.contains(key);
    return InkWell(
      onTap: () => _toggleQuality(key),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : (isDark ? AppColors.darkBackground : AppColors.surfaceSubtle),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary.withValues(alpha: 0.7)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? AppColors.secondary
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LifeAreaSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _LifeAreaSelector({required this.selected, required this.onChanged});

  static const _areas = [
    ('spiritual', AppLifeArea.spiritual, 'Ruh', Icons.mosque_rounded),
    ('physical', AppLifeArea.physical, 'Jism', Icons.fitness_center_rounded),
    ('personal_dev', AppLifeArea.personalDev, 'Aql', Icons.psychology_rounded),
    ('work', AppLifeArea.work, 'Amal', Icons.work_rounded),
    ('social', AppLifeArea.social, 'Ummah', Icons.groups_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = {
      'spiritual': '${l10n.sphereSpiritual} (Ruh)',
      'physical': '${l10n.spherePhysical} (Jism)',
      'personal_dev': '${l10n.personalDev} (Aql)',
      'work': '${l10n.work} (Amal)',
      'social': '${l10n.sphereSocial} (Ummah)',
    };

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _areas.map((area) {
          final isSelected = selected == area.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              avatar: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: area.$2,
                  shape: BoxShape.circle,
                ),
              ),
              label: Text(
                labels[area.$1] ?? area.$1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary.withValues(alpha: 0.22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryLight
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: isSelected ? 1.2 : 0.8,
                ),
              ),
              onSelected: (_) {
                AppHaptics.selectionClick();
                onChanged(area.$1);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayText = time != null
        ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
        : label;

    final isSet = time != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md - 2,
        ),
        decoration: BoxDecoration(
          color: isSet
              ? AppColors.primary.withValues(alpha: 0.12)
              : (isDark
                    ? AppColors.darkSurfaceSubtle
                    : AppColors.surfaceSubtle),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSet
                ? AppColors.primaryLight.withValues(alpha: 0.5)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 17,
                color: isSet
                    ? AppColors.primaryLight
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                displayText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSet ? FontWeight.bold : FontWeight.w500,
                  color: isSet
                      ? (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary)
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
