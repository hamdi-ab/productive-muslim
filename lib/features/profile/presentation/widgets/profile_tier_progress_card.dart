import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Card displaying the user's current Spiritual Progression Tier, level progress bar,
/// and days remaining until unlocking the next rank.
class ProfileTierProgressCard extends StatelessWidget {
  final int streak;
  final bool isDark;
  final bool isAr;

  const ProfileTierProgressCard({
    super.key,
    required this.streak,
    required this.isDark,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final info = _getTierInfo(streak, isAr);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10221B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.2 : 0.04,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  size: 18,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.spiritualRank,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      l10n.nextRankProgress,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  info.levelBadge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Current Rank Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  info.currentTierTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  info.remainingSubtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: info.progress.clamp(0.0, 1.0),
                backgroundColor: isDark
                    ? const Color(0xFF07140E)
                    : const Color(0xFFE5EFEA),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFD4AF37),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Prophetic Consistency Reminder
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF091712) : const Color(0xFFF4F8F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  size: 14,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isAr
                        ? '«أَحَبُّ الأَعْمَالِ إِلَى اللهِ أَدْوَمُهَا وَإِنْ قَلَّ»'
                        : '“The deeds most loved by Allah are those done consistently, even if small.”',
                    style: TextStyle(
                      fontFamily: isAr ? 'amiri' : null,
                      fontSize: 11,
                      fontStyle: isAr ? FontStyle.normal : FontStyle.italic,
                      color: isDark ? Colors.white60 : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static ({
    String currentTierTitle,
    String levelBadge,
    String remainingSubtitle,
    double progress,
  })
  _getTierInfo(int streak, bool isAr) {
    if (streak >= 40) {
      return (
        currentTierTitle: isAr
            ? 'الـمُقـرّب (Al-Muqarrab)'
            : 'Al-Muqarrab (The Foremost)',
        levelBadge: isAr ? 'المستوى ٥' : 'Level 5',
        remainingSubtitle: isAr
            ? 'أعلى مرتبة إيمانية 🌟'
            : 'Peak Rank Achieved 🌟',
        progress: 1.0,
      );
    } else if (streak >= 21) {
      final needed = 40 - streak;
      final progress = (streak - 21) / (40 - 21);
      return (
        currentTierTitle: isAr
            ? 'الـمُبـارك (Al-Mubarak)'
            : 'Al-Mubarak (The Life Producer)',
        levelBadge: isAr ? 'المستوى ٤' : 'Level 4',
        remainingSubtitle: isAr
            ? 'بقي $needed يوم للمقرّب'
            : '$needed days to Al-Muqarrab',
        progress: progress,
      );
    } else if (streak >= 7) {
      final needed = 21 - streak;
      final progress = (streak - 7) / (21 - 7);
      return (
        currentTierTitle: isAr
            ? 'الـثّـابـت (Al-Thabit)'
            : 'Al-Thabit (The Steadfast)',
        levelBadge: isAr ? 'المستوى ٣' : 'Level 3',
        remainingSubtitle: isAr
            ? 'بقي $needed يوم للمبارك'
            : '$needed days to Al-Mubarak',
        progress: progress,
      );
    } else if (streak >= 3) {
      final needed = 7 - streak;
      final progress = (streak - 3) / (7 - 3);
      return (
        currentTierTitle: isAr
            ? 'الـمُجـاهـد (Al-Mujahid)'
            : 'Al-Mujahid (The Striver)',
        levelBadge: isAr ? 'المستوى ٢' : 'Level 2',
        remainingSubtitle: isAr
            ? 'بقي $needed يوم للثابت'
            : '$needed days to Al-Thabit',
        progress: progress,
      );
    } else {
      final needed = 3 - streak;
      final progress = streak / 3.0;
      return (
        currentTierTitle: isAr
            ? 'الـسَّـاعِـي (Al-Sa\'i)'
            : 'Al-Sa\'i (The Seeker)',
        levelBadge: isAr ? 'المستوى ١' : 'Level 1',
        remainingSubtitle: isAr
            ? 'بقي $needed يوم للمجاهد'
            : '$needed days to Al-Mujahid',
        progress: progress,
      );
    }
  }
}
