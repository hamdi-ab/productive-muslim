import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart';
import 'package:productive_muslim/features/intentions/logic/intention_bloc.dart';
import 'package:productive_muslim/features/intentions/logic/intention_event.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Single intention item tile supporting toggle completion, deletion, and
/// direct 1-tap navigation to Adhkar recitation if linked to a Dhikr practice.
class IntentionTile extends StatelessWidget {
  final IntentionEntry entry;
  final bool isDark;

  const IntentionTile({super.key, required this.entry, required this.isDark});

  DhikrCategory? _getDhikrCategory(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('adhkar') ||
        lower.contains('dhikr') ||
        lower.contains('أذكار') ||
        lower.contains('ذكر') ||
        lower.contains('istighfar') ||
        lower.contains('استغفار') ||
        lower.contains('tasbih') ||
        lower.contains('تسبيح')) {
      if (lower.contains('evening') || lower.contains('مساء')) {
        return DhikrCategory.evening;
      }
      if (lower.contains('sleep') ||
          lower.contains('mulk') ||
          lower.contains('نوم')) {
        return DhikrCategory.sleeping;
      }
      return DhikrCategory.morning;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final dhikrCategory = _getDhikrCategory(entry.title);

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.statement != null)
              Padding(
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
              ),
            if (dhikrCategory != null) ...[
              const SizedBox(height: 6),
              AppPressable(
                onTap: () {
                  AppHaptics.lightImpact();
                  context.push('/adhkar', extra: dhikrCategory);
                },
                pressedScale: 0.94,
                haptic: AppHapticFeedback.light,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 11,
                        color: AppColors.secondaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAr ? 'قراءة الذكر الآن' : 'Recite Dhikr Now',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryDark,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 12,
                        color: AppColors.secondaryDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
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
