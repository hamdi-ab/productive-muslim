import 'dart:async';

import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/models/tasbih_state.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_background_atmosphere.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_library_picker_sheet.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

enum _RemembranceSwitchAction { resetToZero, keepAsGeneral, cancel }

class TasbihScreen extends StatefulWidget {
  final bool? isReviewModeEnabled;

  const TasbihScreen({super.key, this.isReviewModeEnabled});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  AdhkarRepository? get _adhkarRepo =>
      getIt.isRegistered<AdhkarRepository>() ? getIt<AdhkarRepository>() : null;

  TasbihState _state = TasbihState.initial();
  bool _isLoading = true;
  bool _hapticsEnabled = true;
  StreamSubscription<TasbihState>? _sub;

  bool get _isReviewMode =>
      widget.isReviewModeEnabled ?? (_adhkarRepo?.isReviewModeEnabled ?? false);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (_adhkarRepo != null) {
      final initial = await _adhkarRepo!.getTasbihState();
      if (mounted) {
        setState(() {
          _state = initial;
          _isLoading = false;
        });
      }
      _sub = _adhkarRepo!.watchTasbihState().listen((updated) {
        if (mounted) {
          setState(() {
            _state = updated;
            _isLoading = false;
          });
        }
      });
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  DhikrItem? _resolveDhikrItem(String? dhikrId) {
    if (dhikrId == null || dhikrId.isEmpty) return null;
    if (_adhkarRepo != null) {
      return _adhkarRepo!.getById(dhikrId, includePendingReview: _isReviewMode);
    }
    return AdhkarCatalog.getById(dhikrId, includePendingReview: _isReviewMode);
  }

  bool _isRetiredOrUnapproved(String? dhikrId) {
    if (dhikrId == null || dhikrId.isEmpty) return false;
    final item = _resolveDhikrItem(dhikrId);
    if (item == null) return true;
    if (item.isPendingReview && !_isReviewMode) return true;
    return false;
  }

  Future<void> _increment() async {
    final prev = _state.currentCount;
    final next = prev + 1;
    final updated = _state.copyWith(
      currentCount: next,
      lastCount: prev,
      updatedAt: DateTime.now(),
    );

    setState(() => _state = updated);

    if (_hapticsEnabled) {
      if (updated.hasTarget && next == updated.targetCount) {
        AppHaptics.mediumImpact();
      } else {
        AppHaptics.lightImpact();
      }
    }

    await _saveState(updated);
  }

  Future<void> _undo() async {
    if (_state.currentCount <= 0) return;
    AppHaptics.selectionClick();

    final next = _state.currentCount - 1;
    final updated = _state.copyWith(
      currentCount: next,
      clearLastCount: true,
      updatedAt: DateTime.now(),
    );

    setState(() => _state = updated);
    await _saveState(updated);
  }

  Future<void> _confirmReset() async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.tasbihResetConfirmTitle,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.tasbihResetConfirmDesc,
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              MaterialLocalizations.of(context).cancelButtonLabel,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            key: const Key('tasbih_reset_confirm_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.tasbihReset),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      AppHaptics.heavyImpact();
      await _executeReset();
    }
  }

  void _showPersistenceError({required VoidCallback onRetry}) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('tasbih_save_error_snackbar'),
        content: Text(l10n.tasbihSaveError),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          key: const Key('tasbih_retry_save_button'),
          label: l10n.retry,
          onPressed: onRetry,
        ),
      ),
    );
  }

  Future<void> _executeReset() async {
    if (_adhkarRepo != null) {
      try {
        await _adhkarRepo!.resetTasbihCount();
      } catch (_) {
        _showPersistenceError(onRetry: _executeReset);
        return;
      }
    }
    final updated = _state.copyWith(
      currentCount: 0,
      clearLastCount: true,
      updatedAt: DateTime.now(),
    );
    if (mounted) {
      setState(() => _state = updated);
    }
  }

  Future<void> _saveState(TasbihState state) async {
    if (_adhkarRepo != null) {
      try {
        await _adhkarRepo!.saveTasbihState(state);
      } catch (_) {
        _showPersistenceError(onRetry: () => _saveState(_state));
      }
    }
  }

  Future<void> _applyRemembranceChange({
    String? newDhikrId,
    String? newCustomLabel,
    required bool resetCount,
  }) async {
    final updated = _state.copyWith(
      currentCount: resetCount ? 0 : _state.currentCount,
      clearLastCount: resetCount,
      dhikrId: newDhikrId,
      clearDhikr: newDhikrId == null,
      customLabel: newCustomLabel,
      clearCustomLabel: newCustomLabel == null,
      updatedAt: DateTime.now(),
    );
    if (mounted) {
      setState(() => _state = updated);
    }
    await _saveState(updated);
  }

  Future<void> _promptRemembranceChange({
    String? newDhikrId,
    String? newCustomLabel,
  }) async {
    // If setting empty/null, clear remembrance and keep count as free counter
    if (newDhikrId == null && newCustomLabel == null) {
      final updated = _state.copyWith(
        clearDhikr: true,
        clearCustomLabel: true,
        updatedAt: DateTime.now(),
      );
      if (mounted) {
        setState(() => _state = updated);
      }
      await _saveState(updated);
      return;
    }

    // If selecting the exact same remembrance, do nothing
    if (newDhikrId != null && newDhikrId == _state.dhikrId) return;
    if (newCustomLabel != null &&
        newCustomLabel == _state.customLabel &&
        _state.dhikrId == null) {
      return;
    }

    // If count is 0, switch immediately without prompting
    if (_state.currentCount <= 0) {
      await _applyRemembranceChange(
        newDhikrId: newDhikrId,
        newCustomLabel: newCustomLabel,
        resetCount: false,
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final action = await showDialog<_RemembranceSwitchAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.tasbihSwitchConfirmTitle,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.tasbihSwitchConfirmDesc(_state.currentCount),
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            key: const Key('tasbih_switch_cancel_button'),
            onPressed: () =>
                Navigator.pop(ctx, _RemembranceSwitchAction.cancel),
            child: Text(
              MaterialLocalizations.of(context).cancelButtonLabel,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          OutlinedButton(
            key: const Key('tasbih_switch_keep_button'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () =>
                Navigator.pop(ctx, _RemembranceSwitchAction.keepAsGeneral),
            child: Text(l10n.tasbihSwitchKeepAsGeneral),
          ),
          ElevatedButton(
            key: const Key('tasbih_switch_reset_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () =>
                Navigator.pop(ctx, _RemembranceSwitchAction.resetToZero),
            child: Text(l10n.tasbihSwitchResetToZero),
          ),
        ],
      ),
    );

    if (action == _RemembranceSwitchAction.resetToZero) {
      await _applyRemembranceChange(
        newDhikrId: newDhikrId,
        newCustomLabel: newCustomLabel,
        resetCount: true,
      );
    } else if (action == _RemembranceSwitchAction.keepAsGeneral) {
      final updated = _state.copyWith(
        clearDhikr: true,
        clearCustomLabel: true,
        updatedAt: DateTime.now(),
      );
      if (mounted) {
        setState(() => _state = updated);
      }
      await _saveState(updated);
    }
  }

  void _openRemembranceSelectionModal() {
    AppHaptics.selectionClick();
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.tasbihSelectRemembranceModalTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                key: const Key('tasbih_choose_library_option'),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  l10n.tasbihSelectFromLibrary,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  l10n.adhkarExploreSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _openLibraryPicker();
                },
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('tasbih_custom_label_option'),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.secondaryDark,
                    size: 20,
                  ),
                ),
                title: Text(
                  l10n.tasbihEnterPersonalLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  l10n.tasbihPersonalLabelNotice,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _openCustomLabelDialog();
                },
              ),
              if (_state.hasDhikr || _state.hasCustomLabel) ...[
                const Divider(height: 1),
                ListTile(
                  key: const Key('tasbih_clear_remembrance_option'),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.clear_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    l10n.tasbihClearSelection,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final updated = _state.copyWith(
                      clearDhikr: true,
                      clearCustomLabel: true,
                      updatedAt: DateTime.now(),
                    );
                    setState(() => _state = updated);
                    await _saveState(updated);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openLibraryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AdhkarLibraryPickerSheet(
        includePendingReview: _isReviewMode,
        alreadySelectedIds: _state.dhikrId != null ? {_state.dhikrId!} : {},
        onItemSelected: (item) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _promptRemembranceChange(newDhikrId: item.id);
            }
          });
        },
      ),
    );
  }

  void _openCustomLabelDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Only prefill if a genuine prior user custom label exists.
    // Never prefill with rawId / dhikrId.
    final controller = TextEditingController(text: _state.customLabel ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.tasbihEnterPersonalLabel,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFFB45309),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.tasbihPersonalLabelNotice,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextField(
              key: const Key('tasbih_custom_label_input'),
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.tasbihPersonalLabelHint,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              MaterialLocalizations.of(context).cancelButtonLabel,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            key: const Key('tasbih_custom_label_save_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final text = controller.text.trim();
              Navigator.pop(ctx);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _promptRemembranceChange(
                    newCustomLabel: text.isNotEmpty ? text : null,
                  );
                }
              });
            },
            child: Text(l10n.adhkarRoutineSave),
          ),
        ],
      ),
    );
  }

  void _openTargetSettingModal() {
    AppHaptics.selectionClick();
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(
      text: _state.targetCount?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.sm,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.tasbihPersonalTargetModalTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryLight.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n.tasbihPersonalTargetDesc,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTargetPresetChip(
                    ctx,
                    label: l10n.tasbihNoTarget,
                    value: null,
                  ),
                  _buildTargetPresetChip(ctx, label: '33', value: 33),
                  _buildTargetPresetChip(ctx, label: '100', value: 100),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.tasbihCustomTarget,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                key: const Key('tasbih_custom_target_input'),
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: l10n.tasbihEnterTargetNumber,
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_state.hasTarget)
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('tasbih_clear_target_button'),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final updated = _state.copyWith(
                            clearTarget: true,
                            updatedAt: DateTime.now(),
                          );
                          setState(() => _state = updated);
                          await _saveState(updated);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(l10n.tasbihClearTarget),
                      ),
                    ),
                  if (_state.hasTarget) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      key: const Key('tasbih_save_target_button'),
                      onPressed: () async {
                        final parsed = int.tryParse(controller.text.trim());
                        if (parsed != null && parsed > 0) {
                          Navigator.pop(ctx);
                          final updated = _state.copyWith(
                            targetCount: parsed,
                            updatedAt: DateTime.now(),
                          );
                          setState(() => _state = updated);
                          await _saveState(updated);
                        } else {
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(l10n.tasbihSaveTarget),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetPresetChip(
    BuildContext ctx, {
    required String label,
    required int? value,
  }) {
    final isSelected = _state.targetCount == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) async {
        Navigator.pop(ctx);
        final updated = _state.copyWith(
          targetCount: value,
          clearTarget: value == null,
          updatedAt: DateTime.now(),
        );
        setState(() => _state = updated);
        await _saveState(updated);
      },
    );
  }

  String _formatDigits(BuildContext context, int number) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (!isAr) return number.toString();
    const englishToArabic = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    return number
        .toString()
        .split('')
        .map((c) => englishToArabic[c] ?? c)
        .join('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isRetired = _isRetiredOrUnapproved(_state.dhikrId);
    final dhikrItem = isRetired ? null : _resolveDhikrItem(_state.dhikrId);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: ProductiveAppBar(
        title: l10n.tasbihTitle,
        subtitle: l10n.tasbihSubtitle,
        showBackButton: true,
        actions: [
          ProductiveAppBarAction(
            key: const Key('tasbih_haptics_toggle'),
            tooltip: _hapticsEnabled
                ? l10n.tasbihHapticsEnabled
                : l10n.tasbihHapticsDisabled,
            icon: _hapticsEnabled
                ? Icons.vibration_rounded
                : Icons.mobile_off_rounded,
            onTap: () {
              setState(() => _hapticsEnabled = !_hapticsEnabled);
              AppHaptics.selectionClick();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          AdhkarBackgroundAtmosphere(isDark: isDark),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Remembrance Banner / Selector Card
                  _buildRemembranceCard(
                    context,
                    l10n: l10n,
                    isDark: isDark,
                    isAr: isAr,
                    isRetired: isRetired,
                    dhikrItem: dhikrItem,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Personal Target Pill
                  _buildTargetRow(context, l10n: l10n, isDark: isDark),
                  const SizedBox(height: AppSpacing.lg),

                  // 3. Main Circular Counter Tap Area
                  Center(
                    child: _buildCounterButton(
                      context,
                      l10n: l10n,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 4. Action Row (Undo + Reset)
                  _buildControlsRow(context, l10n: l10n, isDark: isDark),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemembranceCard(
    BuildContext context, {
    required AppLocalizations l10n,
    required bool isDark,
    required bool isAr,
    required bool isRetired,
    required DhikrItem? dhikrItem,
  }) {
    if (isRetired) {
      return Container(
        key: const Key('tasbih_retired_warning'),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: isDark ? 0.2 : 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFB45309),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.tasbihRetiredWarning,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFFB45309),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.tasbihRetiredDesc,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  key: const Key('tasbih_replace_retired_button'),
                  onPressed: _openLibraryPicker,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(l10n.tasbihSelectFromLibrary),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
                OutlinedButton(
                  key: const Key('tasbih_convert_to_custom_button'),
                  onPressed: _openCustomLabelDialog,
                  child: Text(l10n.tasbihUseAsCustomLabel),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (dhikrItem != null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            l10n.tasbihApprovedLibrary,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: TextButton(
                    key: const Key('tasbih_change_remembrance_button'),
                    onPressed: _openRemembranceSelectionModal,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      l10n.tasbihChangeRemembrance,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dhikrItem.arabic,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAr ? dhikrItem.translationAr : dhikrItem.translationEn,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    if (_state.hasCustomLabel) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    key: const Key('tasbih_personal_label_badge'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.edit_note_rounded,
                          size: 14,
                          color: AppColors.secondaryDark,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            l10n.tasbihPersonalLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: TextButton(
                    key: const Key('tasbih_change_remembrance_button'),
                    onPressed: _openRemembranceSelectionModal,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      l10n.tasbihChangeRemembrance,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _state.customLabel!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.tasbihPersonalLabelNotice,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Default: Free counter state
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryLight.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.primaryLight.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tasbihFreeCounter,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.tasbihTapToCount,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: ElevatedButton.icon(
              key: const Key('tasbih_set_remembrance_button'),
              onPressed: _openRemembranceSelectionModal,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(
                l10n.tasbihSetRemembrance,
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetRow(
    BuildContext context, {
    required AppLocalizations l10n,
    required bool isDark,
  }) {
    final hasTarget = _state.hasTarget;
    final isReached = _state.isTargetReached;

    return Center(
      child: AppPressable(
        key: const Key('tasbih_target_button'),
        onTap: _openTargetSettingModal,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isReached
                ? AppColors.primary.withValues(alpha: 0.15)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isReached
                  ? AppColors.primary
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08)),
              width: isReached ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isReached ? Icons.check_circle_rounded : Icons.flag_outlined,
                size: 15,
                color: isReached
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  hasTarget
                      ? (isReached
                            ? l10n.tasbihTargetReached(_state.targetCount!)
                            : l10n.tasbihTargetLabel(_state.targetCount!))
                      : l10n.tasbihPersonalTarget,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isReached ? FontWeight.bold : FontWeight.w500,
                    color: isReached
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterButton(
    BuildContext context, {
    required AppLocalizations l10n,
    required bool isDark,
  }) {
    final isReached = _state.isTargetReached;
    final formattedCount = _formatDigits(context, _state.currentCount);
    final size = (MediaQuery.of(context).size.width * 0.65).clamp(180.0, 230.0);

    return AppPressable(
      key: const Key('tasbih_counter_button'),
      onTap: _increment,
      pressedScale: 0.94,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: isDark
                ? [
                    AppColors.primaryDark.withValues(alpha: 0.45),
                    AppColors.darkSurface,
                  ]
                : [
                    AppColors.primaryLight.withValues(alpha: 0.25),
                    Colors.white,
                  ],
            stops: const [0.3, 1.0],
          ),
          border: Border.all(
            color: isReached
                ? AppColors.secondary
                : (isDark
                      ? AppColors.primaryLight.withValues(alpha: 0.4)
                      : AppColors.primary.withValues(alpha: 0.3)),
            width: isReached ? 3.5 : 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isReached
                  ? AppColors.secondary.withValues(alpha: 0.25)
                  : AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formattedCount,
                    style: TextStyle(
                      fontSize: 68,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.tasbihTapToCount,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsRow(
    BuildContext context, {
    required AppLocalizations l10n,
    required bool isDark,
  }) {
    final canUndo = _state.currentCount > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Undo button
        Flexible(
          child: Tooltip(
            message: l10n.tasbihUndo,
            child: AppPressable(
              key: const Key('tasbih_undo_button'),
              onTap: canUndo ? _undo : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.undo_rounded,
                      size: 18,
                      color: canUndo
                          ? (isDark ? Colors.white : AppColors.primary)
                          : Colors.grey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.tasbihUndo,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: canUndo
                              ? (isDark ? Colors.white : AppColors.primary)
                              : Colors.grey.withValues(alpha: 0.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Reset button
        Flexible(
          child: Tooltip(
            message: l10n.tasbihReset,
            child: AppPressable(
              key: const Key('tasbih_reset_button'),
              onTap: _confirmReset,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.restart_alt_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.tasbihReset,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
