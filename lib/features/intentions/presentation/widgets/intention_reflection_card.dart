import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart';
import 'package:productive_muslim/features/intentions/logic/intention_bloc.dart';
import 'package:productive_muslim/features/intentions/logic/intention_event.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Evening Muhasabah & Reflection card allowing reflection logging and spiritual tags.
class IntentionReflectionCard extends StatefulWidget {
  final List<IntentionEntry> entries;
  final bool isDark;

  const IntentionReflectionCard({
    super.key,
    required this.entries,
    required this.isDark,
  });

  @override
  State<IntentionReflectionCard> createState() =>
      _IntentionReflectionCardState();
}

class _IntentionReflectionCardState extends State<IntentionReflectionCard> {
  late final TextEditingController _reflectionController;

  @override
  void initState() {
    super.initState();
    _reflectionController = TextEditingController();
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final completed = widget.entries.where((e) => e.completed).toList();
    final total = widget.entries.length;
    final ratio = total == 0 ? 0.0 : completed.length / total;

    return Card(
      elevation: 0,
      color: widget.isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: widget.isDark
              ? const Color(0x2610B981)
              : const Color(0x1A0F4C3A),
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
                _buildTagChip('#Istighfar'),
                _buildTagChip('#WorkAsWorship'),
                _buildTagChip('#Shukr'),
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
                fillColor: widget.isDark
                    ? AppColors.darkSurfaceSubtle
                    : AppColors.surfaceSubtle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: widget.isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: widget.isDark
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
            const SizedBox(height: AppSpacing.sm),
            AppPressable(
              onTap: () {
                AppHaptics.lightImpact();
                context.push('/adhkar', extra: DhikrCategory.evening);
              },
              pressedScale: 0.96,
              haptic: AppHapticFeedback.light,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF1E281F)
                      : const Color(0xFFFAF8F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.nights_stay_rounded,
                      size: 15,
                      color: AppColors.secondaryDark,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Seal today with Istighfar & Evening Adhkar',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark
                              ? Colors.white70
                              : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: AppColors.secondaryDark,
                    ),
                  ],
                ),
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
          setState(() {
            _reflectionController.text = current.isEmpty
                ? tag
                : '$current $tag';
          });
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
}
