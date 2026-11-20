import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/domain/models/adhkar_routine.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_my_routines_section.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class AdhkarRoutinesScreen extends StatelessWidget {
  const AdhkarRoutinesScreen({super.key});

  void _openRoutineReader(BuildContext context, AdhkarRoutine routine) {
    AppHaptics.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdhkarScreen(initialRoutineId: routine.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: ProductiveAppBar(
        title: l10n.adhkarMyRoutinesTitle,
        subtitle: l10n.adhkarMyRoutinesSubtitle,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: l10n.adhkarCreateRoutineButton,
            onPressed: () {
              AppHaptics.selectionClick();
              context.push(AppRoutes.adhkarRoutineEdit);
            },
          ),
        ],
      ),
      body: AdhkarMyRoutinesSection(
        onStartRoutine: (routine) => _openRoutineReader(context, routine),
      ),
    );
  }
}
