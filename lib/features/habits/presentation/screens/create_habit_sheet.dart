import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/constants/app_life_areas.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/arabic_typography.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/features/habits/logic/habit_bloc.dart';
import 'package:productive_muslim/features/habits/logic/habit_event.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class CreateHabitSheet extends StatefulWidget {
  final VoidCallback? onSwitchToTask;

  const CreateHabitSheet({super.key, this.onSwitchToTask});

  @override
  State<CreateHabitSheet> createState() => _CreateHabitSheetState();
}

class _CreateHabitSheetState extends State<CreateHabitSheet> {
  final _nameController = TextEditingController();
  String _category = 'spiritual';
  String _frequency = 'daily';
  String? _targetDays;
  String _prayerAnchor = 'isha';
  String _targetCount = '10 Ayahs';
  bool _canSave = false;

  static const _categories = [
    ('spiritual', AppLifeArea.spiritual, 'Ruh', Icons.mosque_rounded),
    ('physical', AppLifeArea.physical, 'Jism', Icons.fitness_center_rounded),
    ('personal_dev', AppLifeArea.personalDev, 'Aql', Icons.psychology_rounded),
    ('work', AppLifeArea.work, 'Amal', Icons.work_rounded),
    ('social', AppLifeArea.social, 'Ummah', Icons.groups_rounded),
  ];

  static const _prayerAnchors = [
    ('fajr', 'Right after Fajr', Icons.wb_twilight_rounded),
    ('duha', 'Duha Window', Icons.wb_sunny_rounded),
    ('dhuhr', 'Right after Dhuhr', Icons.light_mode_rounded),
    ('asr', 'Right after Asr', Icons.wb_sunny_outlined),
    ('maghrib', 'Right after Maghrib', Icons.nights_stay_outlined),
    ('isha', 'Right after Isha', Icons.bedtime_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      final canSaveNow = _nameController.text.trim().isNotEmpty;
      if (canSaveNow != _canSave) {
        setState(() => _canSave = canSaveNow);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectFrequency(String freq, String? target) {
    AppHaptics.selectionClick();
    setState(() {
      _frequency = freq;
      _targetDays = target;
    });
  }

  void _selectPrayerAnchor(String anchor) {
    AppHaptics.selectionClick();
    setState(() => _prayerAnchor = anchor);
  }

  void _cycleTargetCount() {
    AppHaptics.selectionClick();
    const targets = [
      '1 Session',
      '5 Mins',
      '10 Ayahs',
      '1 Juz',
      '33 Tasbeeh',
      '100 Istighfar',
    ];
    final currentIndex = targets.indexOf(_targetCount);
    final nextIndex = (currentIndex + 1) % targets.length;
    setState(() => _targetCount = targets[nextIndex]);
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    context.read<HabitBloc>().add(
      HabitCreated(
        Habit(
          id: 0,
          name: name,
          category: _category,
          frequency: _frequency,
          targetDays: _targetDays,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
    Navigator.pop(context);
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
                                    fontSize: 15,
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
                            l10n.newHabit,
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

              // Scrollable Form Body
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
                      // Habit Name Header
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    l10n.habitAddName,
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
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Sunnah Routine',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.secondary
                                    : AppColors.secondaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Habit Title TextField
                      TextField(
                        controller: _nameController,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., Recite 10 Ayahs of Surah Al-Mulk before sleeping',
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
                            Icons.auto_stories_rounded,
                            size: 19,
                            color: AppColors.secondary,
                          ),
                          suffixIcon: _nameController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _nameController.clear();
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
                        onSubmitted: (_) {
                          if (_canSave) _save();
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Category / Life Area Sphere Section
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.habitAddCategory,
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((area) {
                            final isSelected = _category == area.$1;
                            final labels = {
                              'spiritual': '${l10n.sphereSpiritual} (Ruh)',
                              'physical': '${l10n.spherePhysical} (Jism)',
                              'personal_dev': '${l10n.personalDev} (Aql)',
                              'work': '${l10n.work} (Amal)',
                              'social': '${l10n.sphereSocial} (Ummah)',
                            };

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
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.primary.withValues(
                                  alpha: 0.22,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.primaryLight
                                        : (isDark
                                              ? AppColors.borderDark
                                              : AppColors.borderLight),
                                    width: isSelected ? 1.2 : 0.8,
                                  ),
                                ),
                                onSelected: (_) {
                                  AppHaptics.selectionClick();
                                  setState(() => _category = area.$1);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Sunnah Frequency & Rhythm
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Frequency & Prophetic Rhythm',
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
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Sunnah Cycle',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.2,
                        children: [
                          _buildFrequencyCard(
                            id: 'daily',
                            title: 'Daily Routine',
                            subtitle: 'Every day without fail',
                            isSelected: _frequency == 'daily',
                            onTap: () => _selectFrequency('daily', null),
                            isDark: isDark,
                          ),
                          _buildFrequencyCard(
                            id: 'mon_thu',
                            title: 'Mon & Thu Sunnah',
                            subtitle: 'Fasting / Extra Dhikr',
                            isSelected: _frequency == 'mon_thu',
                            onTap: () => _selectFrequency('mon_thu', '1,4'),
                            isDark: isDark,
                          ),
                          _buildFrequencyCard(
                            id: 'jumuah',
                            title: 'Jumu\'ah Sunnah',
                            subtitle: 'Kahf, Salawat & Ghusl',
                            isSelected: _frequency == 'jumuah',
                            onTap: () => _selectFrequency('jumuah', '5'),
                            isDark: isDark,
                          ),
                          _buildFrequencyCard(
                            id: 'custom',
                            title: 'Custom Days',
                            subtitle: 'Tailored weekly cycle',
                            isSelected: _frequency == 'custom',
                            onTap: () =>
                                _selectFrequency('custom', '1,2,3,4,5'),
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Prayer Anchor Hook (Habit Stacking)
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.anchor_rounded,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Anchor to Daily Prayer',
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
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Habit Stacking',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _prayerAnchors.map((item) {
                            final (id, label, icon) = item;
                            final isSelected = _prayerAnchor == id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                avatar: Icon(
                                  icon,
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
                                onSelected: (_) => _selectPrayerAnchor(id),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Metric Target & Istiqamah Cards
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _cycleTargetCount,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceSubtle
                                      : AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Target',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _targetCount,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryLight,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.tune_rounded,
                                            size: 14,
                                            color: AppColors.primaryLight,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceSubtle
                                    : AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Istiqamah Goal',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '40 Days',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.verified_rounded,
                                          size: 14,
                                          color: AppColors.secondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Primary Action CTA: Start Habit Streak (Istiqamah)
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
                                ? AppColors.secondary.withValues(alpha: 0.6)
                                : Colors.transparent,
                            width: 1,
                          ),
                          boxShadow: _canSave
                              ? [
                                  BoxShadow(
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.25,
                                    ),
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
                                        Icons.verified_user_rounded,
                                        size: 20,
                                        color: _canSave
                                            ? AppColors.secondary
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Start Habit Streak (Istiqamah)',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: _canSave
                                              ? AppColors.secondary
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

                      // Prophetic Consistency Hadith Quote
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '"The most beloved of deeds to Allah are those that are most consistent, even if small."',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            height: 1.3,
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

  Widget _buildFrequencyCard({
    required String id,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.22)
              : (isDark
                    ? AppColors.darkSurfaceSubtle
                    : AppColors.surfaceSubtle),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.3 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondary
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary),
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected
                          ? (isDark ? AppColors.secondary : AppColors.primary)
                          : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
    );
  }
}
