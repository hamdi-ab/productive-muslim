import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/data/services/settings_service.dart';

String _toArabicDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], arabic[i]);
  }
  return input;
}

class BarakahMuhasabahAuditCard extends StatefulWidget {
  const BarakahMuhasabahAuditCard({super.key});

  @override
  State<BarakahMuhasabahAuditCard> createState() =>
      _BarakahMuhasabahAuditCardState();
}

class _BarakahMuhasabahAuditCardState extends State<BarakahMuhasabahAuditCard> {
  late final String _today;
  int _rating = 4;
  Set<String> _passedCheckpoints = {
    'fajr',
    'morning_adhkar',
    'mindful_eating',
    'tongue_guarded',
  };

  static const List<(String, String, String)> allCheckpoints = [
    ('fajr', "Fajr in Jama'ah", "صلاة الفجر في جماعة"),
    ('morning_adhkar', "Morning Adhkar", "أذكار الصباح"),
    ('mindful_eating', "Mindful Eating", "الأكل بوعي وتسمية"),
    ('tongue_guarded', "Tongue Guarded", "حفظ اللسان"),
    ('evening_adhkar', "Evening Adhkar", "أذكار المساء"),
    ('quran_tadabbur', "Quran Tadabbur", "ورد تدبر القرآن"),
  ];

  @override
  void initState() {
    super.initState();
    _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadAudit();
  }

  void _loadAudit() {
    try {
      if (getIt.isRegistered<SettingsService>()) {
        final settings = getIt<SettingsService>();
        setState(() {
          _rating = settings.getMuhasabahRating(_today);
          _passedCheckpoints = settings.getMuhasabahCheckpoints(_today);
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleCheckpoint(String checkpointId) async {
    AppHaptics.selectionClick();
    try {
      if (getIt.isRegistered<SettingsService>()) {
        final settings = getIt<SettingsService>();
        await settings.toggleMuhasabahCheckpoint(_today, checkpointId);
        setState(() {
          _passedCheckpoints = settings.getMuhasabahCheckpoints(_today);
        });
      } else {
        setState(() {
          if (_passedCheckpoints.contains(checkpointId)) {
            _passedCheckpoints.remove(checkpointId);
          } else {
            _passedCheckpoints.add(checkpointId);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _setRating(int value) async {
    AppHaptics.mediumImpact();
    setState(() => _rating = value);
    try {
      if (getIt.isRegistered<SettingsService>()) {
        await getIt<SettingsService>().setMuhasabahRating(_today, value);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final ratingStr = isAr ? _toArabicDigits('$_rating') : '$_rating';
    final maxRatingStr = isAr ? '٥' : '5';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.35)
              : AppColors.secondary.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F4C3A) : Colors.black).withValues(
              alpha: isDark ? 0.3 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.psychology_alt_rounded,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'محاسبة الخشوع والتركيز'
                            : "Spiritual Focus & Khushu' Audit",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      isAr ? 'محاسبة النفس' : 'Muhasabah',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Star Rating Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground
                  : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isAr
                        ? 'تقييم الحضور القلبي اليوم:'
                        : "Rate Today's Spiritual Focus:",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(5, (index) {
                          final starNum = index + 1;
                          final isFilled = starNum <= _rating;
                          return InkWell(
                            onTap: () => _setRating(starNum),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: Icon(
                                isFilled
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 21,
                                color: isFilled
                                    ? AppColors.secondary
                                    : (isDark
                                          ? AppColors.darkTextSecondary
                                                .withValues(alpha: 0.4)
                                          : AppColors.textSecondary.withValues(
                                              alpha: 0.4,
                                            )),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '$ratingStr/$maxRatingStr',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Audit Checkpoints
          Text(
            isAr ? 'المعالم المتحققة اليوم:' : 'Audit Checkpoints Passed:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: allCheckpoints.map((cp) {
              final id = cp.$1;
              final label = isAr ? cp.$3 : cp.$2;
              final isPassed = _passedCheckpoints.contains(id);
              return InkWell(
                onTap: () => _toggleCheckpoint(id),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPassed
                        ? AppColors.primary.withValues(
                            alpha: isDark ? 0.25 : 0.12,
                          )
                        : (isDark
                              ? AppColors.darkSurfaceSubtle
                              : AppColors.surfaceSubtle),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPassed
                          ? AppColors.primaryLight.withValues(alpha: 0.6)
                          : (isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isPassed
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isPassed
                              ? (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.primary)
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isPassed
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        size: 13,
                        color: isPassed
                            ? AppColors.primaryLight
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Concluding Night Dua
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.secondary.withValues(alpha: 0.08)
                  : const Color(0xFFFEF3C7).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.nights_stay_rounded,
                  size: 17,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAr
                        ? '«اللهم اغفر لي تقصيري اليوم، وبارك لي في فجري غداً»'
                        : '"O Allah, forgive my lapses today and multiply the barakah in my dawn tomorrow."',
                    style: TextStyle(
                      fontFamily: isAr ? 'amiri' : null,
                      fontSize: 11.5,
                      fontStyle: isAr ? FontStyle.normal : FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.3,
                    ),
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
