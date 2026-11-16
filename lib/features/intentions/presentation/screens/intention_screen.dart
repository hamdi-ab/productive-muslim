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
}
