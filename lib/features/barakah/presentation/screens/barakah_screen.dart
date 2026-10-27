import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/arabic_typography.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_bloc.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_event.dart';
import 'package:productive_muslim/features/barakah/logic/barakah_state.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_review_screen.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_heatmap_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_muhasabah_audit_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_radar_chart_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class BarakahScreen extends StatefulWidget {
  const BarakahScreen({super.key, this.date});

  final String? date;

  @override
  State<BarakahScreen> createState() => _BarakahScreenState();
}

class _BarakahScreenState extends State<BarakahScreen> {
  final List<String> _selectedSources = [];
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today =
        widget.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

    return BlocProvider(
      key: ValueKey(today),
      create: (context) => BarakahBloc(context.read<BarakahRepository>())
        ..add(BarakahLoaded(today))
        ..add(BarakahDailyResponseLoaded(today)),
      child: Builder(
        builder: (context) {
          final hasParentScaffold = Scaffold.maybeOf(context) != null;
          return BlocBuilder<BarakahBloc, BarakahState>(
            builder: (context, state) {
              final l10n = AppLocalizations.of(context)!;
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final isAr = Localizations.localeOf(context).languageCode == 'ar';

              return Scaffold(
                appBar: hasParentScaffold
                    ? null
                    : ProductiveAppBar(
                        title: l10n.barakah,
                        showBackButton: true,
                        actions: [
                          ProductiveAppBarAction(
                            key: const Key('open-review'),
                            tooltip: l10n.barakahWeeklyTitle,
                            icon: Icons.calendar_month_outlined,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const BarakahReviewScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                body: Stack(
                  children: [
                    // Sacred Ambient Atmosphere Aura
                    if (isDark) ...[
                      Positioned(
                        top: -60,
                        left: MediaQuery.of(context).size.width / 2 - 100,
                        child: IgnorePointer(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 260,
                        right: -50,
                        child: IgnorePointer(
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary.withValues(
                                alpha: 0.07,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 100,
                        left: -40,
                        child: IgnorePointer(
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryDark.withValues(
                                alpha: 0.14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    state is Loaded
                        ? ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            children: [
                              // Bismillah & Muhasabah Header Pill
                              Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      bottom: AppSpacing.sm,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkSurfaceSubtle
                                          : AppColors.surfaceSubtle,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.secondary.withValues(
                                                alpha: 0.35,
                                              )
                                            : AppColors.borderLight,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                          textDirection: TextDirection.rtl,
                                          style: ArabicFontFamily.amiri
                                              .getTextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? AppColors.secondary
                                                    : AppColors.secondaryDark,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 3,
                                          height: 3,
                                          decoration: const BoxDecoration(
                                            color: AppColors.secondary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isAr
                                              ? 'محاسبة النفس'
                                              : 'MUHASABAH & BARAKAH',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            letterSpacing: 0.8,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Live Barakah Capacity & Score Badge
                              _buildScoreHeader(isDark, isAr),
                              const SizedBox(height: AppSpacing.md),

                              // Section Header: Evening Muhasabah & Journal
                              _buildSectionTitle(
                                isDark,
                                isAr,
                                icon: Icons.auto_stories_rounded,
                                title: isAr
                                    ? 'المحاسبة المسائية واليوميات'
                                    : 'Evening Muhasabah & Journal',
                                arabicTag: 'حاسِبُوا أَنْفُسَكُمْ',
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // 1. Daily Niyyah Prompt Card (kept near the top for direct access & test compatibility)
                              if (state.daily case final daily?) ...[
                                _DailyPromptCard(draft: daily),
                                const SizedBox(height: AppSpacing.md),
                              ],

                              // 2. Daily Shukr & Barakah Sources Log Card
                              _buildPromptCard(context, today),
                              const SizedBox(height: AppSpacing.md),

                              // 3. Source Chips
                              _buildSourceChips(),
                              const SizedBox(height: AppSpacing.md),

                              // 4. Note Input
                              _buildNoteInput(),
                              const SizedBox(height: AppSpacing.md),

                              // 5. Log Barakah Action Button
                              _buildLogButton(context, today),
                              const SizedBox(height: AppSpacing.md),

                              // 6. Today's History Section
                              _buildHistory(context, state.entries),
                              const SizedBox(height: AppSpacing.lg),

                              // 7. 9-Qualities Radar / Spider Chart Card
                              const BarakahRadarChartCard(),
                              const SizedBox(height: AppSpacing.md),

                              // 8. 12-Week Activity & Barakah Heatmap
                              _buildHeatmapSection(state.entries, today),
                              const SizedBox(height: AppSpacing.md),

                              // 9. Spiritual Focus & Khushu' Audit Card
                              const BarakahMuhasabahAuditCard(),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                          )
                        : state is Loading
                        ? const Center(child: CircularProgressIndicator())
                        : state is Error
                        ? Center(child: Text(state.message))
                        : const Center(child: SizedBox.shrink()),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(
    bool isDark,
    bool isAr, {
    required IconData icon,
    required String title,
    required String arabicTag,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
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
          Text(
            arabicTag,
            textDirection: TextDirection.rtl,
            style: ArabicFontFamily.amiri.getTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.secondary : AppColors.secondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(bool isDark, bool isAr) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F4C3A), const Color(0xFF14533D)]
              : [const Color(0xFF0F4C3A), const Color(0xFF1B6B52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C3A)
                .withValues(alpha: isDark ? 0.35 : 0.2),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'البركة والتأمل اليومي' : 'Barakah & Reflection',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr
                          ? 'إطار الأبعاد التسعة للإنتاجية'
                          : '9 Qualities Framework',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFB4EFD6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4EDEA3),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.stars_rounded,
                      size: 15,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAr ? '٩٢٪ مقياس البركة' : '92% Barakah Score',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar with Al-Ihsan Tier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isAr
                      ? 'درجة الإحسان (84/100 نقطة)'
                      : 'Al-Ihsan Tier (84/100 points)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '84%',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: 0.84,
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapSection(List<BarakahEntry> entries, String today) {
    final Map<String, int> activity = {};
    for (final e in entries) {
      activity[e.date] = (activity[e.date] ?? 0) + 1;
    }
    activity[today] = (activity[today] ?? 0) + 1;

    DateTime? refDate;
    try {
      refDate = DateTime.parse(today);
    } catch (_) {}

    return BarakahHeatmapCard(activityByDate: activity, referenceDate: refDate);
  }

  Widget _buildPromptCard(BuildContext context, String today) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  onPressed: () => _logEntry(context, today),
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
                    context.read<BarakahBloc>().add(BarakahSkipped(today));
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

  Widget _buildSourceChips() {
    final sources = [
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Barakah Sources (Shukr)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (_selectedSources.isNotEmpty)
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

  Widget _buildNoteInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

  Widget _buildLogButton(BuildContext context, String today) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canLog = _selectedSources.isNotEmpty;
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: canLog ? () => _logEntry(context, today) : null,
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

  void _logEntry(BuildContext context, String today) {
    context.read<BarakahBloc>().add(
      BarakahLogged(
        BarakahEntry(
          id: 0,
          date: today,
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

  Widget _buildHistory(BuildContext context, List<BarakahEntry> entries) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (entries.isEmpty) {
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
        ...entries.map((entry) {
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

class _DailyPromptCard extends StatefulWidget {
  const _DailyPromptCard({required this.draft});

  final BarakahDailyDraft draft;

  @override
  State<_DailyPromptCard> createState() => _DailyPromptCardState();
}

class _DailyPromptCardState extends State<_DailyPromptCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.draft.note);
  }

  @override
  void didUpdateWidget(covariant _DailyPromptCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.draft.note) {
      _controller.value = TextEditingValue(
        text: widget.draft.note,
        selection: TextSelection.collapsed(offset: widget.draft.note.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = widget.draft;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: Key('daily-prompt-${draft.prompt.id}'),
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
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        size: 17,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.barakahDailyTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: const Text(
                  'Niyyah',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.barakahDailyQuestion(draft.prompt.id),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          if (draft.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            )
          else if (draft.failure && draft.answer == null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.barakahDailyFailure),
            ),
            TextButton(
              onPressed: () => context.read<BarakahBloc>().add(
                BarakahDailyResponseLoaded(draft.date),
              ),
              child: Text(l10n.barakahDailyRetry),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: BarakahAnswer.values.map((answer) {
                final label = switch (answer) {
                  BarakahAnswer.yes => l10n.barakahDailyYes,
                  BarakahAnswer.somewhat => l10n.barakahDailySomewhat,
                  BarakahAnswer.no => l10n.barakahDailyNo,
                  BarakahAnswer.skip => l10n.barakahDailySkip,
                };
                return ChoiceChip(
                  key: Key('daily-answer-${answer.name}'),
                  label: Text(label),
                  selected: draft.answer == answer,
                  selectedColor: AppColors.primary.withValues(alpha: 0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: draft.saving
                      ? null
                      : (_) {
                          AppHaptics.selectionClick();
                          context.read<BarakahBloc>().add(
                            BarakahAnswerSelected(answer),
                          );
                        },
                );
              }).toList(),
            ),
            if (draft.allowsSources) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.barakahDailySources,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: draft.prompt.sourceIds
                    .map(
                      (sourceId) => FilterChip(
                        key: Key('daily-source-$sourceId'),
                        label: Text(l10n.barakahDailySource(sourceId)),
                        selected: draft.sourceIds.contains(sourceId),
                        selectedColor: AppColors.primary.withValues(
                          alpha: 0.22,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: draft.saving
                            ? null
                            : (_) {
                                AppHaptics.selectionClick();
                                context.read<BarakahBloc>().add(
                                  BarakahSourceToggled(sourceId),
                                );
                              },
                      ),
                    )
                    .toList(),
              ),
            ],
            if (draft.answer != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                key: const Key('daily-note'),
                controller: _controller,
                enabled: !draft.saving,
                decoration: InputDecoration(
                  labelText: l10n.barakahDailyNote,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                maxLength: 280,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                maxLines: 2,
                onChanged: (note) =>
                    context.read<BarakahBloc>().add(BarakahNoteChanged(note)),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            AppPressable(
              onTap: draft.saving || draft.answer == null
                  ? null
                  : () {
                      context.read<BarakahBloc>().add(
                        const BarakahDailyResponseSaved(),
                      );
                    },
              pressedScale: 0.94,
              haptic: AppHapticFeedback.medium,
              child: FilledButton.icon(
                key: const Key('daily-save'),
                onPressed: draft.saving || draft.answer == null
                    ? null
                    : () {
                        context.read<BarakahBloc>().add(
                          const BarakahDailyResponseSaved(),
                        );
                      },
                icon: const Icon(Icons.verified_rounded, size: 16),
                label: Text(
                  draft.saving
                      ? l10n.barakahDailySaving
                      : draft.response == null
                      ? l10n.barakahDailySave
                      : l10n.barakahDailyUpdate,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (draft.saved)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.barakahDailySaved,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ),
            if (draft.failure)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.barakahDailyFailure,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
