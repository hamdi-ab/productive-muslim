import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/domain/models/adhkar_routine.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_routine_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class AdhkarMyRoutinesSection extends StatelessWidget {
  final ValueChanged<AdhkarRoutine> onStartRoutine;
  final bool isCompact;
  final VoidCallback? onViewAll;

  const AdhkarMyRoutinesSection({
    super.key,
    required this.onStartRoutine,
    this.isCompact = false,
    this.onViewAll,
  });

  AdhkarRepository? get _adhkarRepo =>
      getIt.isRegistered<AdhkarRepository>() ? getIt<AdhkarRepository>() : null;

  Future<void> _confirmDelete(
    BuildContext context,
    AdhkarRoutine routine,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adhkarRoutineDeleteConfirmTitle),
        content: Text(l10n.adhkarRoutineDeleteConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.adhkarRoutineDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && _adhkarRepo != null) {
      await _adhkarRepo!.deleteRoutine(routine.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<AdhkarRoutine>>(
      stream: _adhkarRepo?.watchRoutines() ?? Stream.value(<AdhkarRoutine>[]),
      builder: (context, snapshot) {
        final routines = snapshot.data ?? [];

        if (routines.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.16)
                          : AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.playlist_add_check_rounded,
                      size: 28,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.adhkarMyRoutinesEmptyTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.adhkarMyRoutinesEmptyDesc,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(160, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      AppHaptics.selectionClick();
                      context.push(AppRoutes.adhkarRoutineEdit);
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                      l10n.adhkarCreateRoutineButton,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final displayedRoutines = isCompact
            ? routines.take(3).toList()
            : routines;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          shrinkWrap: isCompact,
          physics: isCompact
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.adhkarMyRoutinesTitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCompact && onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(l10n.adhkarViewAllRoutines),
                  )
                else
                  TextButton.icon(
                    onPressed: () {
                      AppHaptics.selectionClick();
                      context.push(AppRoutes.adhkarRoutineEdit);
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(l10n.adhkarCreateRoutineButton),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ...displayedRoutines.map(
              (routine) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: StreamBuilder<bool>(
                  stream:
                      _adhkarRepo?.watchIsRoutineCompletedToday(routine.id) ??
                      Stream.value(false),
                  builder: (context, completedSnap) {
                    final isCompleted = completedSnap.data ?? false;

                    return FutureBuilder(
                      future: _adhkarRepo?.getSession('routine_${routine.id}'),
                      builder: (context, sessionSnap) {
                        final session = sessionSnap.data;
                        final hasActiveSession =
                            session != null &&
                            !session.isCompleted &&
                            (session.counts.values.any((c) => c > 0) ||
                                session.skippedItemIds.isNotEmpty ||
                                session.lastPageIndex > 0);

                        return AdhkarRoutineCard(
                          routine: routine,
                          isCompletedToday: isCompleted,
                          hasActiveSession: hasActiveSession,
                          onStartOrContinue: () => onStartRoutine(routine),
                          onEdit: () {
                            AppHaptics.selectionClick();
                            context.push(
                              AppRoutes.adhkarRoutineEdit,
                              extra: routine,
                            );
                          },
                          onDelete: () => _confirmDelete(context, routine),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
