import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';
import 'package:productive_muslim/features/intentions/logic/intention_bloc.dart';
import 'package:productive_muslim/features/intentions/logic/intention_event.dart';
import 'package:productive_muslim/features/intentions/logic/intention_state.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_adhkar_bookend_card.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_atmosphere_background.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_ayah_card.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_create_dialog.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_error_state.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_prophetic_banner.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_reflection_card.dart';
import 'package:productive_muslim/features/intentions/presentation/widgets/intention_today_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Screen for tracking daily sacred intentions (Niyyah) and evening Muhasabah.
class IntentionScreen extends StatelessWidget {
  const IntentionScreen({super.key});

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
              onTap: () =>
                  showAddIntentionDialog(context: context, today: today),
              pressedScale: 0.90,
              haptic: AppHapticFeedback.light,
              child: FloatingActionButton(
                onPressed: () =>
                    showAddIntentionDialog(context: context, today: today),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
              ),
            ),
            body: Stack(
              children: [
                // Atmospheric geometric lattice & celestial auras
                IntentionAtmosphereBackground(isDark: isDark),

                // Main Content
                if (state is IntentionLoaded)
                  ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    children: [
                      // Sacred Purpose Ribbon Pill
                      _buildSacredRibbon(isDark),

                      // In-Page Header when hosted in bottom navigation shell
                      if (hasParentScaffold) ...[
                        _buildInPageHeader(context, l10n, isDark),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      // Prophetic Hadith Banner
                      PropheticIntentionBanner(
                        entries: state.entries,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Today's Intentions Section
                      IntentionTodayCard(
                        today: today,
                        entries: state.entries,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Evening Muhasabah & Reflection Card
                      IntentionReflectionCard(
                        entries: state.entries,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Bookend Adhkar & Intention Card
                      IntentionAdhkarBookendCard(isDark: isDark),
                      const SizedBox(height: AppSpacing.md),

                      // Ayah of Barakah Callout
                      IntentionAyahCard(isDark: isDark),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  )
                else if (state is IntentionLoading)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                else if (state is IntentionError)
                  IntentionErrorState(message: state.message)
                else
                  const Center(child: SizedBox.shrink()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSacredRibbon(bool isDark) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceSubtle
                : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppColors.secondary.withValues(alpha: 0.35)
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
                  color: isDark ? Colors.white70 : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInPageHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: isDark ? Colors.white60 : Colors.black54,
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
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.35),
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
                        Localizations.localeOf(context).toString(),
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
    );
  }
}
