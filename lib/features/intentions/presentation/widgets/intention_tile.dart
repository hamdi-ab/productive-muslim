import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart';
import 'package:productive_muslim/features/intentions/logic/intention_bloc.dart';
import 'package:productive_muslim/features/intentions/logic/intention_event.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Single intention item tile supporting toggle completion and deletion.
class IntentionTile extends StatelessWidget {
  final IntentionEntry entry;
  final bool isDark;

  const IntentionTile({super.key, required this.entry, required this.isDark});

  @override
  Widget build(BuildContext context) {
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
}
