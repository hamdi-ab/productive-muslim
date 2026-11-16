import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Represents a spiritual achievement badge.
class SpiritualBadge {
  final String id;
  final String title;
  final String description;
  final String hadith;
  final IconData icon;
  final Color activeColor;
  final bool isUnlocked;

  const SpiritualBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.hadith,
    required this.icon,
    required this.activeColor,
    required this.isUnlocked,
  });
}

/// Interactive spiritual milestones and badges cabinet for the profile screen.
class ProfileBadgesCard extends StatelessWidget {
  final int streak;
  final int lifetimeHabitCompletions;
  final int lifetimeTasksCompleted;
  final int totalFocusMinutes;
  final bool isDark;
  final bool isAr;

  const ProfileBadgesCard({
    super.key,
    required this.streak,
    required this.lifetimeHabitCompletions,
    required this.lifetimeTasksCompleted,
    required this.totalFocusMinutes,
    required this.isDark,
    required this.isAr,
  });

  List<SpiritualBadge> _buildBadges(AppLocalizations l10n) {
    return [
      SpiritualBadge(
        id: 'fajr_vanguard',
        title: l10n.badgeFajrVanguard,
        description: l10n.badgeFajrVanguardDesc,
        hadith: isAr
            ? '«رَكْعَتَا الْفَجْرِ خَيْرٌ مِنَ الدُّنْيَا وَمَا فِيهَا»'
            : '“The two rak\'ahs of Fajr are better than the world and all it contains.” (Muslim)',
        icon: Icons.wb_twilight_rounded,
        activeColor: const Color(0xFFD97706),
        isUnlocked: streak >= 7,
      ),
      SpiritualBadge(
        id: 'istiqamah_master',
        title: l10n.badgeIstiqamahMaster,
        description: l10n.badgeIstiqamahMasterDesc,
        hadith: isAr
            ? '«قُلْ آمَنْتُ بِاللَّهِ ثُمَّ اسْتَقِمْ»'
            : '“Say: I believe in Allah, and then remain steadfast.” (Muslim)',
        icon: Icons.shield_rounded,
        activeColor: const Color(0xFF10B981),
        isUnlocked: streak >= 21,
      ),
      SpiritualBadge(
        id: 'white_days_guardian',
        title: l10n.badgeWhiteDaysGuardian,
        description: l10n.badgeWhiteDaysGuardianDesc,
        hadith: isAr
            ? '«صِيَامُ ثَلاَثَةِ أَيَّامٍ مِنْ كُلِّ شَهْرٍ صِيَامُ الدَّهْرِ»'
            : '“Fasting three days of every month is equal to fasting for a lifetime.” (Bukhari)',
        icon: Icons.nightlight_round,
        activeColor: const Color(0xFF6366F1),
        isUnlocked: lifetimeHabitCompletions >= 3,
      ),
      SpiritualBadge(
        id: 'dhikr_abundance',
        title: l10n.badgeDhikrAbundance,
        description: l10n.badgeDhikrAbundanceDesc,
        hadith: isAr ? '«لاَ يَزَالُ لِسَانُكَ رَطْبًا مِنْ ذِكْرِ اللَّهِ»' : '“Keep your tongue moist with the remembrance of Allah.” (Tirmidhi)',
        icon: Icons.spa_rounded,
        activeColor: const Color(0xFF059669),
        isUnlocked: lifetimeHabitCompletions >= 10,
      ),
      SpiritualBadge(
        id: 'niyyah_purity',
        title: l10n.badgeNiyyahPurity,
        description: l10n.badgeNiyyahPurityDesc,
        hadith: isAr
            ? '«إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ»'
            : '“Actions are judged by motives and intentions.” (Bukhari)',
        icon: Icons.favorite_rounded,
        activeColor: const Color(0xFFE11D48),
        isUnlocked: lifetimeTasksCompleted >= 7,
      ),
      SpiritualBadge(
        id: 'muhasabah_devotee',
        title: l10n.badgeMuhasabahDevotee,
        description: l10n.badgeMuhasabahDevoteeDesc,
        hadith: isAr ? '«حَاسِبُوا أَنْفُسَكُمْ قَبْلَ أَنْ تُحَاسَبُوا»' : '“Hold yourselves accountable before you are held accountable.” (Umar ibn al-Khattab)',
        icon: Icons.balance_rounded,
        activeColor: const Color(0xFF8B5CF6),
        isUnlocked: totalFocusMinutes >= 60 || lifetimeTasksCompleted >= 14,
      ),
    ];
  }

  void _showBadgeDetail(BuildContext context, SpiritualBadge badge) {
    AppHaptics.lightImpact();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF10221B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: badge.isUnlocked
                  ? badge.activeColor.withValues(alpha: 0.4)
                  : (isDark ? Colors.white12 : Colors.black12),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Badge Icon Header
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: badge.isUnlocked
                      ? badge.activeColor.withValues(alpha: 0.16)
                      : (isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.05)),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: badge.isUnlocked
                        ? badge.activeColor
                        : (isDark ? Colors.white24 : Colors.black26),
                    width: 2,
                  ),
                ),
                child: Icon(
                  badge.icon,
                  size: 36,
                  color: badge.isUnlocked
                      ? badge.activeColor
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
              const SizedBox(height: 14),

              // Badge Title
              Text(
                badge.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // Unlocked Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: badge.isUnlocked
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : (isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.06)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      badge.isUnlocked
                          ? Icons.check_circle_rounded
                          : Icons.lock_outline_rounded,
                      size: 13,
                      color: badge.isUnlocked
                          ? const Color(0xFF10B981)
                          : (isDark ? Colors.white54 : Colors.black45),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      badge.isUnlocked
                          ? l10n.milestoneUnlocked
                          : l10n.milestoneLocked,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badge.isUnlocked
                            ? const Color(0xFF10B981)
                            : (isDark ? Colors.white54 : Colors.black45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Description
              Text(
                badge.description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Hadith Reflection
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0A1813)
                      : const Color(0xFFF4F8F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  badge.hadith,
                  style: TextStyle(
                    fontFamily: isAr ? 'amiri' : null,
                    fontSize: 12.5,
                    fontStyle: isAr ? FontStyle.normal : FontStyle.italic,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final badges = _buildBadges(l10n);
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10221B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                size: 16,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.spiritualMilestones,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unlockedCount / ${badges.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3x2 Grid of Badges
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final badge = badges[index];
              return AppPressable(
                onTap: () => _showBadgeDetail(context, badge),
                pressedScale: 0.94,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badge.isUnlocked
                        ? badge.activeColor.withValues(
                            alpha: isDark ? 0.14 : 0.08,
                          )
                        : (isDark
                              ? const Color(0xFF08140F)
                              : const Color(0xFFF7FAF8)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: badge.isUnlocked
                          ? badge.activeColor.withValues(alpha: 0.4)
                          : (isDark ? Colors.white10 : Colors.black12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badge.isUnlocked
                              ? badge.activeColor.withValues(alpha: 0.18)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          badge.icon,
                          size: 22,
                          color: badge.isUnlocked
                              ? badge.activeColor
                              : (isDark ? Colors.white30 : Colors.black26),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          badge.title,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: badge.isUnlocked
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: badge.isUnlocked
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
