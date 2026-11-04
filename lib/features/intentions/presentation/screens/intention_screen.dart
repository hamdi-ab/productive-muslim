import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/features/intentions/logic/intention_bloc.dart';
import 'package:productive_muslim/features/intentions/logic/intention_event.dart';
import 'package:productive_muslim/features/intentions/logic/intention_state.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class IntentionScreen extends StatefulWidget {
  const IntentionScreen({super.key});

  @override
  State<IntentionScreen> createState() => _IntentionScreenState();
}

class _IntentionScreenState extends State<IntentionScreen> {
  final _titleController = TextEditingController();
  final _reflectionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final hasParentScaffold = Scaffold.maybeOf(context) != null;

    return BlocProvider(
      create: (context) =>
          IntentionBloc(context.read<IntentionRepository>())
            ..add(IntentionEntriesLoaded(today)),
      child: BlocBuilder<IntentionBloc, IntentionState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF0B1512)
                : const Color(0xFFF8FAF9),
            appBar: hasParentScaffold
                ? null
                : ProductiveAppBar(
                    title: l10n.journal,
                    subtitle: DateFormat.yMMMMd(
                      Localizations.localeOf(context).toString(),
                    ).format(DateTime.now()),
                    showBackButton: true,
                  ),
            floatingActionButton: AppPressable(
              onTap: () => _showAddDialog(context, today),
              pressedScale: 0.90,
              haptic: AppHapticFeedback.light,
              child: FloatingActionButton(
                onPressed: () => _showAddDialog(context, today),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
              ),
            ),
            body: Stack(
              children: [
                // Subtle Islamic Geometric Watermark Lattice
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _IslamicLatticeBackgroundPainter(isDark: isDark),
                    ),
                  ),
                ),

                // Celestial Ambient Glow Auras matching Stitch Luxury System
                Positioned(
                  top: -60,
                  left: MediaQuery.of(context).size.width / 2 - 120,
                  child: IgnorePointer(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(
                              alpha: isDark ? 0.22 : 0.08,
                            ),
                            AppColors.primary.withValues(
                              alpha: isDark ? 0.05 : 0.02,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 80,
                  right: -40,
                  child: IgnorePointer(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.secondary.withValues(
                              alpha: isDark ? 0.12 : 0.06,
                            ),
                            AppColors.secondary.withValues(
                              alpha: isDark ? 0.02 : 0.01,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Screen Content
                state is IntentionLoaded
                    ? ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        children: [
                          // Bismillah & Sacred Purpose Ribbon Pill
                          Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
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
                                    const Text(
                                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontFamily: 'amiri',
                                        fontSize: 13,
                                        color: AppColors.secondaryDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: AppColors.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'DAILY NIYYAH & JOURNAL',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                        color: isDark
                                            ? Colors.white70
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // In-Page Header when hosted in bottom navigation shell
                          if (hasParentScaffold) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.journal,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Intention Setting & Evening Muhasabah',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white60
                                                : Colors.black54,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.darkSurfaceSubtle
                                              : AppColors.surfaceSubtle,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: AppColors.secondary
                                                .withValues(alpha: 0.35),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_rounded,
                                              size: 13,
                                              color: AppColors.secondary,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              DateFormat.MMMd(
                                                Localizations.localeOf(context)
                                                    .toString(),
                                              ).format(DateTime.now()),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],

                          // Hero Prophetic Intention Banner
                          _buildPropheticIntentionBanner(
                            context,
                            state.entries,
                            isDark,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Today's Intentions Section
                          _buildTodayCard(
                            context,
                            today,
                            state.entries,
                            isDark,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Evening Muhasabah & Reflection Card
                          _buildReflectionCard(context, state.entries, isDark),
                          const SizedBox(height: AppSpacing.md),

                          // Ayah of Barakah Callout
                          _buildAyahOfBarakahCard(context, isDark),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      )
                    : state is IntentionLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : state is IntentionError
                    ? _ErrorState(message: state.message)
                    : const Center(child: SizedBox.shrink()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropheticIntentionBanner(
    BuildContext context,
    List<IntentionEntry> entries,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final completed = entries.where((e) => e.completed).length;
    final total = entries.length;
    final ratio = total == 0 ? 0.0 : completed / total;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF082E23), Color(0xFF0F4C3A), Color(0xFF133E30)],
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
            color: const Color(0xFF082E23).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Mosque Arch Emblem Watermark
          Positioned(
            right: -12,
            bottom: -16,
            child: IgnorePointer(
              child: Icon(
                Icons.mosque_rounded,
                size: 96,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 14,
                            color: AppColors.secondaryLight,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'PROPHETIC FOUNDATION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: AppColors.secondary.withValues(
                                  alpha: 0.95,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            total > 0 && completed == total
                                ? 'Al-Ihsan Fulfilled'
                                : 'Pure Niyyah',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '«إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ»',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '“Actions are judged only by their intentions, and every person shall have what they intended.”',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        total == 0
                            ? 'No intentions logged yet'
                            : '$completed / $total ${l10n.completed}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(ratio * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: ratio.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(
    BuildContext context,
    String today,
    List<IntentionEntry> entries,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

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
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.todayIntentions,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entries.length} ${entries.length == 1 ? 'Entry' : 'Entries'}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (entries.isEmpty)
              _buildEmptyIntentionsState(context, today, isDark)
            else
              Column(
                children: entries
                    .map((entry) => _buildIntentionTile(context, entry, isDark))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyIntentionsState(
    BuildContext context,
    String today,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSubtle : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noIntentionsToday,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Consecrate your daily acts to Allah to invite continuous barakah.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildPresetChip(context, today, '🕋 Fajr on Time'),
              _buildPresetChip(context, today, '💼 Work as Worship'),
              _buildPresetChip(context, today, '🤝 Mercy to Family'),
              _buildPresetChip(context, today, '📖 Quran Reflection'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(BuildContext context, String today, String title) {
    return AppPressable(
      onTap: () {
        AppHaptics.lightImpact();
        context.read<IntentionBloc>().add(
          IntentionCreated(
            IntentionEntry(
              id: 0,
              date: today,
              title: title,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ),
          ),
        );
      },
      pressedScale: 0.94,
      haptic: AppHapticFeedback.light,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildIntentionTile(
    BuildContext context,
    IntentionEntry entry,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSubtle : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.completed
              ? AppColors.success.withValues(alpha: 0.35)
              : (isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.06)),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: AppPressable(
          onTap: () {
            context.read<IntentionBloc>().add(IntentionToggled(entry));
          },
          pressedScale: 0.85,
          haptic: AppHapticFeedback.light,
          borderRadius: BorderRadius.circular(24),
          child: Tooltip(
            message: entry.completed
                ? l10n.habitUnmark
                : l10n.habitMarkComplete,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  entry.completed
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  key: ValueKey('intention_${entry.id}_${entry.completed}'),
                  color: entry.completed
                      ? AppColors.success
                      : (isDark ? Colors.white60 : AppColors.primary),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration: entry.completed ? TextDecoration.lineThrough : null,
            color: entry.completed
                ? AppColors.textDisabled
                : (isDark ? Colors.white : AppColors.textPrimary),
          ),
          child: Text(
            entry.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: entry.statement != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  entry.statement!,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        trailing: AppPressable(
          onTap: () {
            context.read<IntentionBloc>().add(IntentionDeleted(entry.id));
          },
          pressedScale: 0.85,
          haptic: AppHapticFeedback.medium,
          borderRadius: BorderRadius.circular(20),
          child: Tooltip(
            message: l10n.delete,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.delete_outline,
                size: 20,
                color: AppColors.textDisabled,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAyahOfBarakahCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16241C) : const Color(0xFFFAF8F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_quote_rounded,
                size: 16,
                color: AppColors.secondaryDark,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'AYAH OF BARAKAH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.secondaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'amiri',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryDark,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '“And whoever relies upon Allah — then He is sufficient for him.”',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Surah At-Talaq: 3',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard(
    BuildContext context,
    List<IntentionEntry> entries,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final completed = entries.where((e) => e.completed).toList();
    final total = entries.length;
    final ratio = total == 0 ? 0.0 : completed.length / total;

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
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.nights_stay_rounded,
                    size: 16,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.reflection,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                        fontSize: 14,
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${completed.length} / $total ${l10n.completed}',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                color: AppColors.secondary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildTagChip('#Tawakkul'),
                _buildTagChip('#Ihsan'),
                _buildTagChip('#WorkAsWorship'),
                _buildTagChip('#Sadaqah'),
                _buildTagChip('#Gratitude'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _reflectionController,
              decoration: InputDecoration(
                hintText: l10n.reflectionHint,
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
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
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
                icon: const Icon(Icons.check_rounded, size: 18),
                onPressed: completed.isEmpty
                    ? null
                    : () {
                        AppHaptics.mediumImpact();
                        final bloc = context.read<IntentionBloc>();
                        for (final entry in completed) {
                          bloc.add(
                            IntentionReflectionSaved(
                              entry.id,
                              _reflectionController.text,
                            ),
                          );
                        }
                      },
                label: Text(l10n.saveReflection),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return AppPressable(
      onTap: () {
        AppHaptics.selectionClick();
        final current = _reflectionController.text;
        if (!current.contains(tag)) {
          _reflectionController.text = current.isEmpty ? tag : '$current $tag';
        }
      },
      pressedScale: 0.94,
      haptic: AppHapticFeedback.selection,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
        child: Text(
          tag,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, String today) {
    _titleController.clear();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF13221C) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? const Color(0x3310B981) : const Color(0x260F4C3A),
            width: 1.2,
          ),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.newIntention),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildDialogSuggestion('Work as Worship'),
                _buildDialogSuggestion('Patience (Sabr)'),
                _buildDialogSuggestion('Seeking Knowledge'),
                _buildDialogSuggestion('Family Mercy'),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.intentionTitle,
                prefixIcon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_titleController.text.trim().isNotEmpty) {
                AppHaptics.lightImpact();
                context.read<IntentionBloc>().add(
                  IntentionCreated(
                    IntentionEntry(
                      id: 0,
                      date: today,
                      title: _titleController.text.trim(),
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                    ),
                  ),
                );
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogSuggestion(String text) {
    return InkWell(
      onTap: () {
        AppHaptics.selectionClick();
        _titleController.text = text;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.read<IntentionBloc>().add(
              IntentionEntriesLoaded(_todayStr()),
            ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

class _IslamicLatticeBackgroundPainter extends CustomPainter {
  final bool isDark;
  const _IslamicLatticeBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? const Color(0xFF10B981) : AppColors.primary)
          .withValues(alpha: isDark ? 0.025 : 0.015)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const step = 56.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        canvas.drawCircle(Offset(x, y), step * 0.35, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicLatticeBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
