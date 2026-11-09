import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/arabic_typography.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_bloc.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_event.dart';

class BarakahEntryFormCard extends StatefulWidget {
  final String today;
  final List<BarakahEntry> entries;

  const BarakahEntryFormCard({
    super.key,
    required this.today,
    required this.entries,
  });

  @override
  State<BarakahEntryFormCard> createState() => _BarakahEntryFormCardState();
}

class _BarakahEntryFormCardState extends State<BarakahEntryFormCard> {
  final Set<String> _selectedSources = {};
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _logEntry(BuildContext context) {
    context.read<BarakahBloc>().add(
      BarakahLogged(
        BarakahEntry(
          id: 0,
          date: widget.today,
          sourceIds: List<String>.unmodifiable(_selectedSources),
          note: _noteController.text.isEmpty ? null : _noteController.text,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
    setState(() {
      _selectedSources.clear();
      _noteController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Daily Experience Prompt
        _buildPromptCard(context, isDark),
        const SizedBox(height: AppSpacing.md),

        // 2. Source Filter Chips
        _buildSourceChips(isDark),
        const SizedBox(height: AppSpacing.md),

        // 3. Note Input
        _buildNoteInput(isDark),
        const SizedBox(height: AppSpacing.md),

        // 4. Log Barakah Button
        _buildLogButton(context, isDark),
        const SizedBox(height: AppSpacing.md),

        // 5. Today's History
        _buildHistory(context, isDark),
        const SizedBox(height: AppSpacing.md),

        // 6. Daily Shukr Log
        _buildDailyShukrLogSection(isDark, isAr),
      ],
    );
  }

  Widget _buildPromptCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.35)
              : AppColors.secondary.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.3 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
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
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Daily Barakah Reflection',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Ash-Sharh 94:6',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground
                  : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? AppColors.secondary.withValues(alpha: 0.2)
                    : AppColors.secondary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا • إِنَّ مَعَ الْعُسْرِ يُسْرًا',
                  textDirection: TextDirection.rtl,
                  style: ArabicFontFamily.amiri.getTextStyle(
                    fontSize: 15,
                    color: isDark
                        ? AppColors.secondary
                        : AppColors.secondaryDark,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Verily, with hardship comes ease.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Did you experience barakah in your time today?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _logEntry(context),
                  icon: const Icon(Icons.check_circle_rounded, size: 16),
                  label: const Text('Yes'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<BarakahBloc>().add(
                      BarakahSkipped(widget.today),
                    );
                  },
                  icon: const Icon(Icons.skip_next_rounded, size: 16),
                  label: const Text('Skip'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceChips(bool isDark) {
    const sources = [
      'Reading Quran',
      'Prayer on time',
      'Dhikr after salah',
      'Charity',
      'Family time',
      'Halal income',
      'Dua',
      'Knowledge',
      'Kindness',
      'Patience',
      'Gratitude',
      'Forgiveness',
      'Helping others',
      'Clean heart',
      'Early rising',
      'Healthy food',
      'Truthful speech',
      'Good example',
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.3)
              : AppColors.secondary.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.3 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
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
                      Icons.favorite_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Barakah Sources (Shukr)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
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
              if (_selectedSources.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_selectedSources.length} selected',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: sources.map((source) {
              final selected = _selectedSources.contains(source);
              return FilterChip(
                label: Text(
                  source,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: selected,
                selectedColor: AppColors.primary.withValues(alpha: 0.22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selected
                        ? AppColors.primaryLight
                        : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                    width: selected ? 1.2 : 0.8,
                  ),
                ),
                onSelected: (selected) {
                  AppHaptics.selectionClick();
                  setState(() {
                    if (selected) {
                      _selectedSources.add(source);
                    } else {
                      _selectedSources.remove(source);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput(bool isDark) {
    return TextField(
      controller: _noteController,
      decoration: InputDecoration(
        labelText: 'Add a note (optional)',
        hintText:
            'e.g., Felt deep focus after Fajr and gave sadaqah in secret...',
        prefixIcon: const Icon(
          Icons.edit_note_rounded,
          size: 20,
          color: AppColors.primaryLight,
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.darkSurfaceSubtle
            : AppColors.surfaceSubtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 1.5,
          ),
        ),
      ),
      maxLines: 2,
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildLogButton(BuildContext context, bool isDark) {
    final canLog = _selectedSources.isNotEmpty;
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: canLog ? () => _logEntry(context) : null,
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF135A46) : AppColors.primary,
          foregroundColor: canLog ? Colors.white : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: canLog
                  ? AppColors.secondary.withValues(alpha: 0.6)
                  : Colors.transparent,
            ),
          ),
        ),
        icon: Icon(
          Icons.verified_rounded,
          size: 19,
          color: canLog ? AppColors.secondary : Colors.grey,
        ),
        label: const Text(
          'Log Barakah',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildDailyShukrLogSection(bool isDark, bool isAr) {
    final items = isAr
        ? [
            'الحمد لله على الصحة والنشاط بعد صلاة الفجر',
            'الحمد لله على سلامة الأسرة واجتماع مائدة الإفطار',
            'الحمد لله على صفاء الذهن وبركة وقت العمل المركز',
          ]
        : [
            'Alhamdulillah for health and energy after Fajr prayer',
            'Alhamdulillah for family safety and peaceful meals',
            'Alhamdulillah for clarity and barakah during deep work sprint',
          ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.35)
              : AppColors.secondary.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.3 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        color: const Color(0xFF4EDEA3).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 16,
                        color: Color(0xFF4EDEA3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'سجل الشكر اليومي (شكر النعم)'
                            : 'Daily Shukr (Gratitude) Log',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  isAr ? '٣ نِعَم مسجلة' : '3 Recorded',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceSubtle
                    : AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    '☪',
                    style: TextStyle(fontSize: 15, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF4EDEA3),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHistory(BuildContext context, bool isDark) {
    if (widget.entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(
            'No barakah entries yet',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.history_rounded,
              size: 17,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 6),
            const Text(
              "Today's Entries",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...widget.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: ListTile(
              leading: entry.skipped
                  ? const Icon(Icons.remove_circle_outline)
                  : const Icon(Icons.spa_outlined, color: AppColors.success),
              title: entry.skipped
                  ? const Text('Skipped')
                  : Text(entry.sourceIds.join(', ')),
              subtitle: entry.note != null ? Text(entry.note!) : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () {
                  final bloc = context.read<BarakahBloc>();
                  bloc.add(BarakahDeleted(entry.id));
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}
