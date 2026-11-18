import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/domain/models/muhasabah_entry.dart';
import 'package:productive_muslim/domain/repositories/muhasabah_repository.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_adhkar_bookend_card.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_atmosphere_background.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_ayah_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Serene evening Muhasabah view for personal reflection, gratitude, and lessons learned.
///
/// Features:
/// - Support for single prompt, multiple prompts, or pure free writing in one reflection session
/// - Preserves each prompt and its corresponding answer without losing the free-writing path
/// - Preserves original createdAt timestamp on edits
/// - Sourced and verified Umar ibn al-Khattab (RA) quotation banner
/// - Immediate saving without any requirement of completed intentions
/// - Chronological list of today's saved reflections with edit/delete actions
/// - Zero gamification, zero percentage gauges, zero streaks, zero guilt empty states
class MuhasabahView extends StatefulWidget {
  const MuhasabahView({super.key});

  @override
  State<MuhasabahView> createState() => _MuhasabahViewState();
}

class _MuhasabahViewState extends State<MuhasabahView> {
  final TextEditingController _freeController = TextEditingController();
  final Map<String, TextEditingController> _promptControllers = {};
  final Set<String> _selectedPromptKeys = {};
  final Set<String> _selectedTags = {};
  int? _editingEntryId;
  int? _editingCreatedAt;
  bool _isSaving = false;

  static const List<String> _availableTags = [
    '#Shukr',
    '#Tawakkul',
    '#Istighfar',
    '#Sabr',
    '#Ihsan',
    '#Gratitude',
  ];

  @override
  void initState() {
    super.initState();
    _freeController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    setState(() {});
  }

  TextEditingController _getPromptController(String key) {
    return _promptControllers.putIfAbsent(key, () {
      final c = TextEditingController();
      c.addListener(_onContentChanged);
      return c;
    });
  }

  @override
  void dispose() {
    _freeController.removeListener(_onContentChanged);
    _freeController.dispose();
    for (final c in _promptControllers.values) {
      c.removeListener(_onContentChanged);
      c.dispose();
    }
    super.dispose();
  }

  MuhasabahRepository? _resolveRepo(BuildContext context) {
    try {
      return context.read<MuhasabahRepository>();
    } catch (_) {
      if (getIt.isRegistered<MuhasabahRepository>()) {
        return getIt<MuhasabahRepository>();
      }
    }
    return null;
  }

  String _getPromptText(AppLocalizations l10n, String? key) {
    switch (key) {
      case 'gratitude':
        return l10n.muhasabahPromptGratitude;
      case 'patience':
        return l10n.muhasabahPromptPatience;
      case 'forgiveness':
        return l10n.muhasabahPromptForgiveness;
      case 'ihsan':
        return l10n.muhasabahPromptIhsan;
      case 'intention':
        return l10n.muhasabahPromptIntention;
      default:
        return '';
    }
  }

  void _onPromptSelected(String key) {
    AppHaptics.selectionClick();
    setState(() {
      if (key == 'free') {
        if (_selectedPromptKeys.contains('free')) {
          _selectedPromptKeys.remove('free');
        } else {
          _selectedPromptKeys.add('free');
        }
        return;
      }

      if (_selectedPromptKeys.contains(key)) {
        _selectedPromptKeys.remove(key);
      } else {
        _selectedPromptKeys.add(key);
        _getPromptController(key);
        // Suggest matching tag
        switch (key) {
          case 'gratitude':
            _selectedTags.add('#Shukr');
            break;
          case 'patience':
            _selectedTags.add('#Sabr');
            break;
          case 'forgiveness':
            _selectedTags.add('#Istighfar');
            break;
          case 'ihsan':
            _selectedTags.add('#Ihsan');
            break;
          case 'intention':
            _selectedTags.add('#Tawakkul');
            break;
        }
      }
    });
  }

  void _toggleTag(String tag) {
    AppHaptics.selectionClick();
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  bool get _hasAnyContent {
    if (_freeController.text.trim().isNotEmpty) return true;
    for (final key in _selectedPromptKeys) {
      if (key != 'free') {
        final c = _promptControllers[key];
        if (c != null && c.text.trim().isNotEmpty) return true;
      }
    }
    return false;
  }

  void _clearEditor() {
    _freeController.clear();
    for (final c in _promptControllers.values) {
      c.clear();
    }
    _selectedPromptKeys.clear();
    _selectedTags.clear();
    _editingEntryId = null;
    _editingCreatedAt = null;
  }

  Future<void> _saveReflection(
    MuhasabahRepository repo,
    String today,
    AppLocalizations l10n,
  ) async {
    if (!_hasAnyContent || _isSaving) return;

    AppHaptics.mediumImpact();
    setState(() => _isSaving = true);

    final tagsString = _selectedTags.isEmpty ? null : _selectedTags.join(' ');
    final now = DateTime.now().millisecondsSinceEpoch;

    // Collect answered prompt responses
    final promptResponses = <MuhasabahPromptResponse>[];
    final activePromptKeys = _selectedPromptKeys
        .where((k) => k != 'free')
        .toList();

    for (final key in activePromptKeys) {
      final c = _promptControllers[key];
      final answer = c?.text.trim() ?? '';
      if (answer.isNotEmpty) {
        promptResponses.add(
          MuhasabahPromptResponse(
            promptId: key,
            promptText: _getPromptText(l10n, key),
            response: answer,
          ),
        );
      }
    }

    final freeText = _freeController.text.trim();
    final contentToSave = MuhasabahEntry.encodeContent(
      prompts: promptResponses,
      freeWriting: freeText.isNotEmpty ? freeText : null,
    );

    final promptIdString = promptResponses.isEmpty
        ? null
        : promptResponses.map((p) => p.promptId).whereType<String>().join(',');
    final promptTextString = promptResponses.isEmpty
        ? null
        : promptResponses
              .map((p) => p.promptText)
              .whereType<String>()
              .join(' | ');

    try {
      if (_editingEntryId != null) {
        await repo.updateEntry(
          MuhasabahEntry(
            id: _editingEntryId!,
            date: today,
            promptId: promptIdString,
            promptText: promptTextString,
            content: contentToSave,
            tags: tagsString,
            createdAt: _editingCreatedAt ?? now,
            updatedAt: now,
          ),
        );
      } else {
        await repo.insertEntry(
          MuhasabahEntry(
            id: 0,
            date: today,
            promptId: promptIdString,
            promptText: promptTextString,
            content: contentToSave,
            tags: tagsString,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      _clearEditor();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.muhasabahReflectionSavedToast),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _editEntry(MuhasabahEntry entry) {
    AppHaptics.selectionClick();
    setState(() {
      _clearEditor();
      _editingEntryId = entry.id;
      _editingCreatedAt = entry.createdAt;

      final decoded = entry.decodedContent;
      for (final p in decoded.prompts) {
        if (p.promptId != null) {
          _selectedPromptKeys.add(p.promptId!);
          _getPromptController(p.promptId!).text = p.response;
        }
      }

      if (decoded.freeWriting != null && decoded.freeWriting!.isNotEmpty) {
        _freeController.text = decoded.freeWriting!;
        if (decoded.prompts.isNotEmpty) {
          _selectedPromptKeys.add('free');
        }
      }

      if (entry.tags != null) {
        _selectedTags.addAll(
          entry.tags!.split(' ').where((t) => t.trim().isNotEmpty),
        );
      }
    });
  }

  Future<void> _confirmDelete(
    MuhasabahRepository repo,
    MuhasabahEntry entry,
    AppLocalizations l10n,
  ) async {
    AppHaptics.lightImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.muhasabahDeleteConfirmTitle),
        content: Text(l10n.muhasabahDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      AppHaptics.mediumImpact();
      await repo.deleteEntry(entry.id);
      if (_editingEntryId == entry.id) {
        setState(() {
          _clearEditor();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final repo = _resolveRepo(context);

    return Stack(
      children: [
        IntentionAtmosphereBackground(isDark: isDark),
        ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          children: [
            _buildContemplationBanner(isDark, isAr, l10n),
            const SizedBox(height: AppSpacing.md),
            _buildPromptSelector(isDark, isAr, l10n),
            const SizedBox(height: AppSpacing.md),
            if (repo != null)
              _buildReflectionInputCard(isDark, isAr, l10n, repo, today),
            const SizedBox(height: AppSpacing.md),
            if (repo != null)
              _buildSavedReflectionsSection(isDark, isAr, l10n, repo, today),
            const SizedBox(height: AppSpacing.md),
            IntentionAdhkarBookendCard(isDark: isDark),
            const SizedBox(height: AppSpacing.md),
            IntentionAyahCard(isDark: isDark),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ],
    );
  }

  Widget _buildContemplationBanner(
    bool isDark,
    bool isAr,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F261E), const Color(0xFF0A1813)]
              : [const Color(0xFF0F4C3A), const Color(0xFF165B46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C3A)
                .withValues(alpha: isDark ? 0.3 : 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.nights_stay_rounded,
                  size: 16,
                  color: AppColors.secondaryLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.muhasabahHeaderTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'حَاسِبُوا أَنْفُسَكُمْ',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'amiri',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isAr
                ? '«حَاسِبُوا أَنْفُسَكُمْ قَبْلَ أَنْ تُحَاسَبُوا، وَزِنُوا أَنْفُسَكُمْ قَبْلَ أَنْ تُوزَنُوا»'
                : '“Take account of yourselves before you are taken to account, and weigh your deeds before they are weighed.”',
            style: TextStyle(
              fontFamily: isAr ? 'amiri' : null,
              fontSize: isAr ? 14 : 12.5,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.92),
              fontStyle: isAr ? FontStyle.normal : FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAr
                ? '— عمر بن الخطاب رضي الله عنه · سنن الترمذي (2459)، كتاب الزهد للإمام أحمد (177)'
                : '— Umar ibn al-Khattab (RA) · Sunan al-Tirmidhi (2459), Kitab al-Zuhd by Ahmad (177)',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryLight,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSelector(bool isDark, bool isAr, AppLocalizations l10n) {
    final prompts = [
      (
        key: 'free',
        label: l10n.muhasabahPromptFree,
        icon: Icons.edit_note_rounded,
      ),
      (
        key: 'gratitude',
        label: isAr ? 'الشكر والنعم' : 'Gratitude',
        icon: Icons.favorite_rounded,
      ),
      (
        key: 'patience',
        label: isAr ? 'الصبر والتوكل' : 'Patience',
        icon: Icons.shield_rounded,
      ),
      (
        key: 'forgiveness',
        label: isAr ? 'الاستغفار' : 'Forgiveness',
        icon: Icons.spa_rounded,
      ),
      (
        key: 'ihsan',
        label: isAr ? 'الإحسان' : 'Ihsan',
        icon: Icons.auto_awesome_rounded,
      ),
      (
        key: 'intention',
        label: isAr ? 'تجديد النية' : 'Renew Niyyah',
        icon: Icons.lightbulb_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.psychology_alt_outlined,
              size: 16,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.muhasabahPromptsTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: prompts.map((p) {
              final isSelected = _selectedPromptKeys.contains(p.key);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AppPressable(
                  onTap: () => _onPromptSelected(p.key),
                  pressedScale: 0.94,
                  haptic: AppHapticFeedback.selection,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkSurface : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondary
                            : (isDark ? Colors.white12 : Colors.black12),
                        width: isSelected ? 1.4 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          p.icon,
                          size: 14,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          p.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white
                                      : AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionInputCard(
    bool isDark,
    bool isAr,
    AppLocalizations l10n,
    MuhasabahRepository repo,
    String today,
  ) {
    final isEditing = _editingEntryId != null;
    final activePromptKeys = _selectedPromptKeys
        .where((k) => k != 'free')
        .toList();

    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? const Color(0x2610B981) : const Color(0x1A0F4C3A),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          size: 16,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isEditing
                              ? (isAr ? 'تعديل التأمل' : 'Edit Reflection')
                              : l10n.reflection,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isEditing)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _clearEditor();
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Render focused input for each active prompt
            for (final pKey in activePromptKeys) ...[
              _buildPromptInputSection(pKey, isDark, isAr, l10n),
              const SizedBox(height: AppSpacing.sm),
            ],

            // Free writing section
            if (activePromptKeys.isNotEmpty) ...[
              Text(
                isAr ? 'تأملات حرة إضافية' : 'Additional Free Reflections',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
            ],
            TextField(
              controller: _freeController,
              decoration: InputDecoration(
                hintText: l10n.muhasabahInputHint,
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceSubtle
                    : AppColors.surfaceSubtle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
              minLines: 3,
              maxLines: 6,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Spiritual Tag Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return AppPressable(
                  onTap: () => _toggleTag(tag),
                  pressedScale: 0.94,
                  haptic: AppHapticFeedback.selection,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : (isDark
                                ? AppColors.darkSurfaceSubtle
                                : const Color(0xFFF2F5F3)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.white12 : Colors.black12),
                        width: isSelected ? 1.2 : 0.8,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? (isDark
                                  ? AppColors.secondaryLight
                                  : AppColors.primaryDark)
                            : (isDark
                                  ? Colors.white70
                                  : AppColors.textSecondary),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Save Reflection Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                onPressed: _hasAnyContent && !_isSaving
                    ? () => _saveReflection(repo, today, l10n)
                    : null,
                label: Text(
                  isEditing
                      ? (isAr ? 'حفظ التعديل' : 'Update Reflection')
                      : l10n.muhasabahSaveAction,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptInputSection(
    String pKey,
    bool isDark,
    bool isAr,
    AppLocalizations l10n,
  ) {
    final controller = _getPromptController(pKey);
    final question = _getPromptText(l10n, pKey);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132A22) : const Color(0xFFE8F5EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: isAr ? 'إجابتك...' : 'Your response...',
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceSubtle : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.2,
                ),
              ),
            ),
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildSavedReflectionsSection(
    bool isDark,
    bool isAr,
    AppLocalizations l10n,
    MuhasabahRepository repo,
    String today,
  ) {
    return StreamBuilder<List<MuhasabahEntry>>(
      stream: repo.watchEntriesForDate(today),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.muhasabahSavedToday,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (entries.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${entries.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.secondaryLight
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (entries.isEmpty)
              _buildGentleEmptyState(isDark, l10n)
            else
              ...entries.map(
                (entry) =>
                    _buildSavedEntryCard(entry, isDark, isAr, l10n, repo),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGentleEmptyState(bool isDark, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.muhasabahEmptyMessage,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedEntryCard(
    MuhasabahEntry entry,
    bool isDark,
    bool isAr,
    AppLocalizations l10n,
    MuhasabahRepository repo,
  ) {
    final entryTime = DateTime.fromMillisecondsSinceEpoch(entry.createdAt);
    final timeFormatted = DateFormat.jm().format(entryTime);
    final tags =
        entry.tags?.split(' ').where((t) => t.isNotEmpty).toList() ?? [];
    final decoded = entry.decodedContent;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        timeFormatted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white60
                              : AppColors.textSecondary,
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
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: l10n.edit,
                    onPressed: () => _editEntry(entry),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: l10n.delete,
                    onPressed: () => _confirmDelete(repo, entry, l10n),
                  ),
                ],
              ),
            ],
          ),

          // Render structured prompts
          if (decoded.prompts.isNotEmpty) ...[
            for (final p in decoded.prompts) ...[
              const SizedBox(height: 6),
              if (p.promptText != null && p.promptText!.isNotEmpty)
                Text(
                  'Q: ${p.promptText}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.secondaryLight
                        : AppColors.primary,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                p.response,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ],

          // Render free writing notes
          if (decoded.freeWriting != null &&
              decoded.freeWriting!.isNotEmpty) ...[
            const SizedBox(height: 6),
            if (decoded.prompts.isNotEmpty)
              Text(
                isAr ? 'خواطر حرة:' : 'Free Reflection:',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            Text(
              decoded.freeWriting!,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],

          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.secondaryLight
                          : AppColors.primaryDark,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
