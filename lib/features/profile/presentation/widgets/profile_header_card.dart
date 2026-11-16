import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/features/habits/presentation/screens/istiqamah_streak_sheet.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Hero identity card for the user's spiritual profile, showcasing avatar,
/// spiritual persona level, and quick access to system settings.
class ProfileHeaderCard extends StatefulWidget {
  final bool isDark;
  final bool isAr;
  final VoidCallback? onProfileUpdated;

  const ProfileHeaderCard({
    super.key,
    required this.isDark,
    required this.isAr,
    this.onProfileUpdated,
  });

  @override
  State<ProfileHeaderCard> createState() => _ProfileHeaderCardState();
}

class _ProfileHeaderCardState extends State<ProfileHeaderCard> {
  static const Map<String, IconData> _avatarIcons = {
    'spa': Icons.spa_rounded,
    'mosque': Icons.mosque_rounded,
    'nightlight': Icons.nightlight_round,
    'menu_book': Icons.menu_book_rounded,
    'wb_sunny': Icons.wb_sunny_rounded,
    'favorite': Icons.favorite_rounded,
  };

  IconData _resolveAvatarIcon(String key) {
    return _avatarIcons[key] ?? Icons.spa_rounded;
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    AppHaptics.lightImpact();
    final l10n = AppLocalizations.of(context)!;
    final settings = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : null;

    final initialName = settings?.userName ?? '';
    final initialIntention = settings?.userIntention ?? '';
    String currentAvatar = settings?.userAvatar ?? 'spa';

    final nameController = TextEditingController(text: initialName);
    final intentionController = TextEditingController(text: initialIntention);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            return AlertDialog(
              backgroundColor: widget.isDark
                  ? const Color(0xFF13221C)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: widget.isDark
                      ? const Color(0x3310B981)
                      : const Color(0x260F4C3A),
                  width: 1.2,
                ),
              ),
              title: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.editProfile,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Symbol Picker
                    Text(
                      l10n.chooseAvatar,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _avatarIcons.entries.map((entry) {
                        final isSelected = currentAvatar == entry.key;
                        return InkWell(
                          onTap: () {
                            AppHaptics.selectionClick();
                            setModalState(() {
                              currentAvatar = entry.key;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : (widget.isDark
                                        ? Colors.white10
                                        : Colors.black.withValues(alpha: 0.05)),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (widget.isDark
                                          ? Colors.white24
                                          : Colors.black12),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              entry.value,
                              size: 22,
                              color: isSelected
                                  ? AppColors.primary
                                  : (widget.isDark
                                        ? Colors.white70
                                        : Colors.black54),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Display Name Field
                    Text(
                      l10n.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      maxLength: 30,
                      decoration: InputDecoration(
                        hintText: l10n.enterNameHint,
                        counterText: '',
                        filled: true,
                        fillColor: widget.isDark
                            ? const Color(0xFF091712)
                            : const Color(0xFFF3F7F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Daily Sacred Intention Field
                    Text(
                      l10n.spiritualMotto,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: intentionController,
                      maxLines: 2,
                      maxLength: 80,
                      decoration: InputDecoration(
                        hintText: l10n.enterMottoHint,
                        counterText: '',
                        filled: true,
                        fillColor: widget.isDark
                            ? const Color(0xFF091712)
                            : const Color(0xFFF3F7F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(dialogCtx, true),
                  child: Text(l10n.saveChanges),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true && settings != null) {
      await settings.setUserName(nameController.text.trim());
      await settings.setUserIntention(intentionController.text.trim());
      await settings.setUserAvatar(currentAvatar);
      if (mounted) {
        setState(() {});
      }
      widget.onProfileUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : null;

    final userName = settings?.userName;
    final userIntention = settings?.userIntention;
    final avatarKey = settings?.userAvatar ?? 'spa';
    final avatarIcon = _resolveAvatarIcon(avatarKey);

    final displayName = (userName != null && userName.trim().isNotEmpty)
        ? userName.trim()
        : (widget.isAr ? 'طالب البركة' : 'Productive Seeker');

    final displayIntention =
        (userIntention != null && userIntention.trim().isNotEmpty)
        ? userIntention.trim()
        : (widget.isAr
              ? '«اللَّهُمَّ بَارِكْ لِأُمَّتِي فِي بُكُورِهَا»'
              : '“O Allah, bless my Ummah in its early mornings.”');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF10221B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withValues(
            alpha: widget.isDark ? 0.35 : 0.25,
          ),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isDark ? const Color(0xFF0F4C3A) : Colors.black)
                .withValues(alpha: widget.isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with glowing celestial gold rim & edit trigger
              AppPressable(
                onTap: () => _showEditProfileDialog(context),
                pressedScale: 0.94,
                child: Stack(
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
                        backgroundColor: widget.isDark
                            ? const Color(0xFF0D1E17)
                            : const Color(0xFFF3F7F5),
                        child: Icon(
                          avatarIcon,
                          size: 28,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isDark
                                ? const Color(0xFF10221B)
                                : Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Name and Spiritual Rank
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        AppPressable(
                          onTap: () => _showEditProfileDialog(context),
                          pressedScale: 0.9,
                          child: Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: widget.isDark
                                ? Colors.white38
                                : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    StreamBuilder<int>(
                      stream: getIt.isRegistered<HabitRepository>()
                          ? getIt<HabitRepository>().watchOverallStreak()
                          : null,
                      initialData: 0,
                      builder: (context, snapshot) {
                        final streak = snapshot.data ?? 0;
                        final (levelTitle, levelRank) = _computeSpiritualLevel(
                          streak,
                          widget.isAr,
                        );

                        return Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
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
                            AppPressable(
                              onTap: () => IstiqamahStreakSheet.show(context),
                              pressedScale: 0.92,
                              borderRadius: BorderRadius.circular(10),
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
                                    Flexible(
                                      child: Text(
                                        l10n.streak(streak),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD97706),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Settings Gear Button
              AppPressable(
                onTap: () {
                  AppHaptics.lightImpact();
                  context.push(AppRoutes.settings);
                },
                pressedScale: 0.88,
                haptic: AppHapticFeedback.light,
                child: Tooltip(
                  message: l10n.settings,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? AppColors.darkSurfaceSubtle
                          : AppColors.surfaceSubtle,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isDark ? Colors.white12 : Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: widget.isDark
                          ? Colors.white70
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Spiritual Intention Quote (tap to edit)
          AppPressable(
            onTap: () => _showEditProfileDialog(context),
            pressedScale: 0.98,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF0A1813)
                    : const Color(0xFFF6FAF7),
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
                      displayIntention,
                      style: TextStyle(
                        fontFamily: widget.isAr ? 'amiri' : null,
                        fontSize: 11.5,
                        fontStyle: widget.isAr
                            ? FontStyle.normal
                            : FontStyle.italic,
                        color: widget.isDark ? Colors.white70 : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static (String, String) _computeSpiritualLevel(int streak, bool isAr) {
    if (streak >= 40) {
      return (
        isAr ? 'الـمُقـرّب' : 'Al-Muqarrab',
        isAr ? 'المستوى ٥' : 'Level 5',
      );
    } else if (streak >= 21) {
      return (
        isAr ? 'الـمُبـارك' : 'Al-Mubarak',
        isAr ? 'المستوى ٤' : 'Level 4',
      );
    } else if (streak >= 7) {
      return (
        isAr ? 'الـثّـابـت' : 'Al-Thabit',
        isAr ? 'المستوى ٣' : 'Level 3',
      );
    } else if (streak >= 3) {
      return (
        isAr ? 'الـمُجـاهـد' : 'Al-Mujahid',
        isAr ? 'المستوى ٢' : 'Level 2',
      );
    } else {
      return (
        isAr ? 'الـسَّـاعِـي' : 'Al-Sa\'i',
        isAr ? 'المستوى ١' : 'Level 1',
      );
    }
  }
}
