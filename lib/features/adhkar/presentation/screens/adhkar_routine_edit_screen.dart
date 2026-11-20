import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/domain/models/adhkar_routine.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_library_picker_sheet.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class AdhkarRoutineEditScreen extends StatefulWidget {
  final AdhkarRoutine? routine;

  const AdhkarRoutineEditScreen({super.key, this.routine});

  @override
  State<AdhkarRoutineEditScreen> createState() =>
      _AdhkarRoutineEditScreenState();
}

class _AdhkarRoutineEditScreenState extends State<AdhkarRoutineEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final List<String> _selectedItemIds;
  TimeOfDay? _preferredTime;
  late final Set<int> _selectedWeekdays;
  bool _isSaving = false;

  AdhkarRepository? get _adhkarRepo =>
      getIt.isRegistered<AdhkarRepository>() ? getIt<AdhkarRepository>() : null;

  bool get _isEditing => widget.routine != null;

  @override
  void initState() {
    super.initState();
    final r = widget.routine;
    _nameController = TextEditingController(text: r?.name ?? '');
    _selectedItemIds = List<String>.from(r?.itemIds ?? []);
    if (r?.preferredTime != null && r!.preferredTime!.contains(':')) {
      final parts = r.preferredTime!.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      _preferredTime = TimeOfDay(hour: hour, minute: minute);
    }
    _selectedWeekdays = Set<int>.from(r?.weekdays ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  DhikrItem? _getItem(String id) {
    return _adhkarRepo?.getById(id, includePendingReview: true) ??
        AdhkarCatalog.getById(id, includePendingReview: true);
  }

  Future<void> _pickTime() async {
    AppHaptics.selectionClick();
    final initial = _preferredTime ?? const TimeOfDay(hour: 6, minute: 30);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null && mounted) {
      setState(() => _preferredTime = picked);
    }
  }

  void _clearTime() {
    AppHaptics.selectionClick();
    setState(() => _preferredTime = null);
  }

  void _toggleWeekday(int day) {
    AppHaptics.selectionClick();
    setState(() {
      if (_selectedWeekdays.contains(day)) {
        _selectedWeekdays.remove(day);
      } else {
        _selectedWeekdays.add(day);
      }
    });
  }

  void _removeItem(int index) {
    AppHaptics.lightImpact();
    setState(() {
      _selectedItemIds.removeAt(index);
    });
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    AppHaptics.lightImpact();
    setState(() {
      final item = _selectedItemIds.removeAt(oldIndex);
      _selectedItemIds.insert(newIndex, item);
    });
  }

  void _openAdhkarPicker() {
    AppHaptics.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AdhkarLibraryPickerSheet(
        alreadySelectedIds: _selectedItemIds.toSet(),
        onItemSelected: (item) {
          if (_selectedItemIds.contains(item.id)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.adhkarRoutineDuplicateItemError,
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }
          setState(() {
            _selectedItemIds.add(item.id);
          });
        },
      ),
    );
  }

  Future<void> _saveRoutine() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.adhkarRoutineNoItemsError),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    AppHaptics.selectionClick();

    final now = DateTime.now();
    final timeStr = _preferredTime != null
        ? '${_preferredTime!.hour.toString().padLeft(2, '0')}:${_preferredTime!.minute.toString().padLeft(2, '0')}'
        : null;
    final sortedWeekdays = _selectedWeekdays.toList()..sort();

    final routineToSave = AdhkarRoutine(
      id: widget.routine?.id ?? 'routine_${now.millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      itemIds: List.from(_selectedItemIds),
      preferredTime: timeStr,
      weekdays: sortedWeekdays,
      createdAt: widget.routine?.createdAt ?? now,
      updatedAt: now,
      retiredItemIds: widget.routine?.retiredItemIds ?? const [],
    );

    try {
      if (_adhkarRepo != null) {
        if (_isEditing) {
          await _adhkarRepo!.updateRoutineWithProgressPreservation(
            routineToSave,
          );
        } else {
          await _adhkarRepo!.saveRoutine(routineToSave);
        }
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adhkarRoutineDeleteConfirmTitle),
        content: Text(l10n.adhkarRoutineDeleteConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.adhkarRoutineDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.routine != null && mounted) {
      if (_adhkarRepo != null) {
        await _adhkarRepo!.deleteRoutine(widget.routine!.id);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: ProductiveAppBar(
        title: _isEditing
            ? l10n.adhkarEditRoutineTitle
            : l10n.adhkarNewRoutineTitle,
        showBackButton: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              tooltip: l10n.adhkarRoutineDelete,
              onPressed: _confirmDelete,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _saveRoutine,
              child: Text(
                l10n.adhkarRoutineSave,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Routine Name
            Text(
              l10n.adhkarRoutineNameLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: l10n.adhkarRoutineNameHint,
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.adhkarRoutineNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Selected Remembrances Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.adhkarRoutineItemsTitle} (${_selectedItemIds.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_selectedItemIds.length > 1) ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.adhkarRoutineReorderHelp,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _openAdhkarPicker,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: Text(l10n.adhkarRoutineAddItems),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Remembrances List
            if (_selectedItemIds.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Center(
                  child: Text(
                    l10n.adhkarRoutineNoItemsError,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedItemIds.length,
                onReorderItem: _onReorderItem,
                itemBuilder: (context, index) {
                  final id = _selectedItemIds[index];
                  final item = _getItem(id);
                  return Container(
                    key: ValueKey(id),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: isDark
                            ? AppColors.primaryLight.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        item?.arabic ?? '[$id]',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        item?.translationEn ?? item?.titleEn ?? id,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            tooltip: l10n.delete,
                            onPressed: () => _removeItem(index),
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(
                              Icons.drag_handle_rounded,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.lg),

            // Schedule (Optional)
            Text(
              l10n.adhkarRoutineScheduleOptional,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.adhkarRoutineScheduleDesc,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Preferred Time Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 20,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.adhkarRoutinePreferredTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _preferredTime != null
                              ? _preferredTime!.format(context)
                              : l10n.adhkarRoutineNoTime,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_preferredTime != null)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      tooltip: l10n.adhkarRoutineClearTime,
                      onPressed: _clearTime,
                    ),
                  OutlinedButton(
                    onPressed: _pickTime,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(
                      _preferredTime != null
                          ? l10n.edit
                          : (Localizations.localeOf(context).languageCode ==
                                    'ar'
                                ? 'تحديد'
                                : 'Set'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Preferred Weekdays
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.adhkarRoutinePreferredDays,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (int day = 1; day <= 7; day++)
                        FilterChip(
                          selected: _selectedWeekdays.contains(day),
                          label: Text(_weekdayLabel(day)),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: _selectedWeekdays.contains(day)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) => _toggleWeekday(day),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  String _weekdayLabel(int day) {
    switch (day) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}
