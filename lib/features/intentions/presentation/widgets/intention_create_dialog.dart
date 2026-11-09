import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart';
import 'package:productive_muslim/features/intentions/logic/intention_bloc.dart';
import 'package:productive_muslim/features/intentions/logic/intention_event.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Shows the elevated dialog to create a new intention with quick presets.
Future<void> showAddIntentionDialog({
  required BuildContext context,
  required String today,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AddIntentionDialog(today: today),
  );
}

/// Dialog for creating or customizing an intention with inspiration presets.
class AddIntentionDialog extends StatefulWidget {
  final String today;

  const AddIntentionDialog({super.key, required this.today});

  @override
  State<AddIntentionDialog> createState() => _AddIntentionDialogState();
}

class _AddIntentionDialogState extends State<AddIntentionDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _statementController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _statementController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _statementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final selectedPreset = _titleController.text;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF10221B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: AppColors.secondary.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF082E23), Color(0xFF0F4C3A), Color(0xFF133E30)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(
            bottom: BorderSide(
              color: AppColors.secondary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: IgnorePointer(
                child: Icon(
                  Icons.mosque_rounded,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'بِسْمِ اللَّهِ',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'amiri',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryLight,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'DAILY NIYYAH',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.secondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.newIntention,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Consecrate your action purely for Allah for continuous barakah.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Quick Presets
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 14,
                    color: AppColors.secondaryDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'QUICK INSPIRATION PRESETS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isDark
                          ? AppColors.secondaryLight
                          : AppColors.secondaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildElevatedDialogChip(
                    icon: Icons.work_outline_rounded,
                    text: 'Work as Worship',
                    isSelected: selectedPreset == 'Work as Worship',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _titleController.text = 'Work as Worship';
                        if (_statementController.text.isEmpty) {
                          _statementController.text =
                              'To excel in my work with Ihsan and honesty';
                        }
                      });
                    },
                  ),
                  _buildElevatedDialogChip(
                    icon: Icons.favorite_border_rounded,
                    text: 'Patience (Sabr)',
                    isSelected: selectedPreset == 'Patience (Sabr)',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _titleController.text = 'Patience (Sabr)';
                        if (_statementController.text.isEmpty) {
                          _statementController.text =
                              'To respond with gentle forbearance and calm';
                        }
                      });
                    },
                  ),
                  _buildElevatedDialogChip(
                    icon: Icons.menu_book_rounded,
                    text: 'Seeking Knowledge',
                    isSelected: selectedPreset == 'Seeking Knowledge',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _titleController.text = 'Seeking Knowledge';
                        if (_statementController.text.isEmpty) {
                          _statementController.text =
                              'To seek beneficial knowledge for Allah\'s sake';
                        }
                      });
                    },
                  ),
                  _buildElevatedDialogChip(
                    icon: Icons.people_outline_rounded,
                    text: 'Family Mercy',
                    isSelected: selectedPreset == 'Family Mercy',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _titleController.text = 'Family Mercy';
                        if (_statementController.text.isEmpty) {
                          _statementController.text =
                              'To bring joy and support to my family today';
                        }
                      });
                    },
                  ),
                  _buildElevatedDialogChip(
                    icon: Icons.mosque_outlined,
                    text: 'Fajr on Time',
                    isSelected: selectedPreset == 'Fajr on Time',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _titleController.text = 'Fajr on Time';
                      });
                    },
                  ),
                  _buildElevatedDialogChip(
                    icon: Icons.wb_sunny_outlined,
                    text: 'Morning Adhkar',
                    isSelected: selectedPreset == 'Morning Adhkar',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _titleController.text = 'Morning Adhkar';
                        if (_statementController.text.isEmpty) {
                          _statementController.text = 'To begin my day in protection and remembrance of Allah';
                        }
                      });
                    },
                  ),
                  _buildElevatedDialogChip(
                    icon: Icons.repeat_rounded,
                    text: '100x Istighfar',
                    isSelected: selectedPreset == '100x Istighfar',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _titleController.text = '100x Istighfar';
                        if (_statementController.text.isEmpty) {
                          _statementController.text = 'To purify my heart and seek divine barakah during pauses';
                        }
                      });
                    },
                  ),
                  _buildElevatedDialogChip(
                    icon: Icons.nights_stay_outlined,
                    text: 'Evening Adhkar',
                    isSelected: selectedPreset == 'Evening Adhkar',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _titleController.text = 'Evening Adhkar';
                        if (_statementController.text.isEmpty) {
                          _statementController.text = 'To seal my day in gratitude and prophetic remembrance';
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section: Intention Title Field
              Text(
                'INTENTION TITLE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.intentionTitle,
                  prefixIcon: const Icon(
                    Icons.edit_note_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  suffixIcon: _titleController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () {
                            setState(() => _titleController.clear());
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceSubtle
                      : const Color(0xFFF6FAF7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white12
                          : AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white12
                          : AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Section: Statement (Optional) Field
              Text(
                'PURPOSE & NIYYAH STATEMENT (OPTIONAL)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _statementController,
                decoration: InputDecoration(
                  hintText: 'e.g. Seeking Allah\'s pleasure & barakah',
                  prefixIcon: const Icon(
                    Icons.format_quote_rounded,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceSubtle
                      : const Color(0xFFF6FAF7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white12
                          : AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white12
                          : AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.secondary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Footnote Wisdom Callout
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E281F)
                      : const Color(0xFFFAF8F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: AppColors.secondaryDark,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '“The intention of the believer is better than his action.”',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  AppHaptics.lightImpact();
                  Navigator.of(context).pop();
                },
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check_rounded, size: 18),
                onPressed: () {
                  if (_titleController.text.trim().isNotEmpty) {
                    AppHaptics.mediumImpact();
                    final statement = _statementController.text.trim();
                    context.read<IntentionBloc>().add(
                      IntentionCreated(
                        IntentionEntry(
                          id: 0,
                          date: widget.today,
                          title: _titleController.text.trim(),
                          statement: statement.isNotEmpty ? statement : null,
                          createdAt: DateTime.now().millisecondsSinceEpoch,
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
                label: Text(
                  l10n.save,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildElevatedDialogChip({
    required IconData icon,
    required String text,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return AppPressable(
      onTap: () {
        AppHaptics.selectionClick();
        onTap();
      },
      pressedScale: 0.94,
      haptic: AppHapticFeedback.selection,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark
                    ? AppColors.darkSurfaceSubtle
                    : const Color(0xFFF0F4F1)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : (isDark
                      ? const Color(0x3310B981)
                      : AppColors.primary.withValues(alpha: 0.15)),
            width: isSelected ? 1.2 : 0.8,
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
              isSelected ? Icons.check_circle_rounded : icon,
              size: 13,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.primaryLight : AppColors.primary),
            ),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.primaryDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
