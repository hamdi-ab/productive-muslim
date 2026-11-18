import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Ambient contextual pill on the Home Screen that highlights
/// the active Dhikr / Du'a based on current solar / prayer context.
class HomeAdhkarPill extends StatefulWidget {
  final PrayerTimes? prayerTimes;

  const HomeAdhkarPill({super.key, this.prayerTimes});

  @override
  State<HomeAdhkarPill> createState() => _HomeAdhkarPillState();
}

class _HomeAdhkarPillState extends State<HomeAdhkarPill> {
  IconData _getCategoryIcon(DhikrCategory category) {
    switch (category) {
      case DhikrCategory.morning:
        return Icons.wb_sunny_rounded;
      case DhikrCategory.evening:
        return Icons.nights_stay_rounded;
      case DhikrCategory.wakingUp:
        return Icons.alarm_on_rounded;
      case DhikrCategory.sleeping:
        return Icons.bedtime_rounded;
      case DhikrCategory.postPrayer:
        return Icons.mosque_rounded;
      case DhikrCategory.dailySunnah:
        return Icons.auto_awesome_rounded;
    }
  }

  Color _getCategoryColor(DhikrCategory category) {
    switch (category) {
      case DhikrCategory.morning:
        return const Color(0xFFF59E0B); // Amber / Gold
      case DhikrCategory.evening:
        return const Color(0xFF6366F1); // Indigo / Twilight
      case DhikrCategory.wakingUp:
        return const Color(0xFF10B981); // Emerald
      case DhikrCategory.sleeping:
        return const Color(0xFF8B5CF6); // Purple
      case DhikrCategory.postPrayer:
        return AppColors.primary;
      case DhikrCategory.dailySunnah:
        return AppColors.secondary;
    }
  }

  String _getCategoryTitle(DhikrCategory category, AppLocalizations l10n) {
    switch (category) {
      case DhikrCategory.morning:
        return l10n.adhkarMorning;
      case DhikrCategory.evening:
        return l10n.adhkarEvening;
      case DhikrCategory.wakingUp:
        return l10n.adhkarWaking;
      case DhikrCategory.sleeping:
        return l10n.adhkarSleeping;
      case DhikrCategory.postPrayer:
        return l10n.adhkarPostPrayer;
      case DhikrCategory.dailySunnah:
        return l10n.adhkarDailySunnah;
    }
  }

  Future<void> _handleTap(DhikrCategory activeCategory) async {
    context.go(AppRoutes.adhkar, extra: activeCategory);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final now = DateTime.now();

    DhikrCategory activeCategory = DhikrCategory.morning;
    int completedCount = 0;
    int totalCount = 0;

    if (getIt.isRegistered<AdhkarService>()) {
      final adhkarService = getIt<AdhkarService>();
      activeCategory = adhkarService.getCurrentContextCategory(
        now: now,
        prayerTimes: widget.prayerTimes,
      );
      completedCount = adhkarService.getCompletedCountForCategory(
        activeCategory,
      );
      totalCount = AdhkarCatalog.getByCategory(activeCategory).length;
    } else {
      totalCount = AdhkarCatalog.getByCategory(activeCategory).length;
    }

    final accentColor = _getCategoryColor(activeCategory);
    final isAllDone = totalCount > 0 && completedCount >= totalCount;

    return InkWell(
      onTap: () => _handleTap(activeCategory),
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 20,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getCategoryIcon(activeCategory),
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _getCategoryTitle(activeCategory, l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isAllDone) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAllDone
                        ? l10n.adhkarCompleted
                        : (completedCount > 0
                              ? l10n.adhkarProgress(completedCount, totalCount)
                              : l10n.adhkarPillTapPrompt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isAllDone
                          ? const Color(0xFF10B981)
                          : AppColors.textSecondary,
                      fontWeight: isAllDone
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAllDone
                        ? l10n.adhkarActionReview
                        : (completedCount > 0
                              ? (isAr ? 'متابعة' : 'Continue')
                              : l10n.adhkarActionRecite),
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: accentColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
