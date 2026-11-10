import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Hero identity card for the user's spiritual profile, showcasing avatar,
/// spiritual persona level, and quick access to system settings.
class ProfileHeaderCard extends StatelessWidget {
  final bool isDark;
  final bool isAr;

  const ProfileHeaderCard({
    super.key,
    required this.isDark,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String? userName;
    if (getIt.isRegistered<SettingsService>()) {
      userName = getIt<SettingsService>().userName;
    }

    final displayName = (userName != null && userName.trim().isNotEmpty)
        ? userName.trim()
        : (isAr ? 'طالب البركة' : 'Productive Seeker');

    final levelTitle = isAr ? 'الـمُبـارك' : 'Al-Mubarak';
    final levelRank = isAr ? 'المستوى ٤' : 'Level 4';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10221B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.25 : 0.05,
            ),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with glowing celestial gold rim
              Stack(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Color(0xFFD4AF37)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: isDark
                          ? const Color(0xFF0D1E17)
                          : const Color(0xFFF3F7F5),
                      child: const Icon(
                        Icons.spa_rounded,
                        size: 28,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF10221B)
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Name and Spiritual Rank
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.16,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.35,
                                  ),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '$levelTitle • $levelRank',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondaryDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        StreamBuilder<int>(
                          stream: getIt.isRegistered<HabitRepository>()
                              ? getIt<HabitRepository>().watchOverallStreak()
                              : null,
                          initialData: 0,
                          builder: (context, snapshot) {
                            final streak = snapshot.data ?? 0;
                            return Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  key: const Key('profile_streak_badge'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B)
                                          .withValues(alpha: 0.35),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department_rounded,
                                        size: 12,
                                        color: Color(0xFFD97706),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        l10n.streak(streak),
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD97706),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Settings Gear Button
              AppPressable(
                onTap: () {
                  AppHaptics.lightImpact();
                  context.push('/settings');
                },
                pressedScale: 0.88,
                haptic: AppHapticFeedback.light,
                child: Tooltip(
                  message: l10n.settings,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceSubtle
                          : AppColors.surfaceSubtle,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Spiritual Intention Quote
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A1813) : const Color(0xFFF6FAF7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAr
                        ? '«اللَّهُمَّ بَارِكْ لِأُمَّتِي فِي بُكُورِهَا»'
                        : '“O Allah, bless my Ummah in its early mornings.”',
                    style: TextStyle(
                      fontFamily: isAr ? 'amiri' : null,
                      fontSize: 11.5,
                      fontStyle: isAr ? FontStyle.normal : FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.black87,
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
}
