import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:productive_muslim/core/router/app_routes.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';

class _AyahEntry {
  final String arabic;
  final String english;
  final String refEn;
  final String refAr;

  const _AyahEntry({
    required this.arabic,
    required this.english,
    required this.refEn,
    required this.refAr,
  });
}

class HomeDailyAyahCard extends StatefulWidget {
  final bool isDark;

  const HomeDailyAyahCard({super.key, required this.isDark});

  @override
  State<HomeDailyAyahCard> createState() => _HomeDailyAyahCardState();
}

class _HomeDailyAyahCardState extends State<HomeDailyAyahCard> {
  bool _isBookmarked = false;

  static const List<_AyahEntry> _weeklyAyahs = [
    // 0: Monday (DateTime.monday = 1 -> index 0)
    _AyahEntry(
      arabic: 'وَتَوَكَّلْ عَلَى الْحَيِّ الَّذِي لَا يَمُوتُ',
      english: '“And put your trust in the Ever-Living Who dies not, and celebrate His praise.”',
      refEn: 'Surah Al-Furqan • 25:58',
      refAr: 'سورة الفرقان • الآية ٥٨',
    ),
    // 1: Tuesday
    _AyahEntry(
      arabic: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      english: '“So remember Me; I will remember you. And be grateful to Me and do not deny Me.”',
      refEn: 'Surah Al-Baqarah • 2:152',
      refAr: 'سورة البقرة • الآية ١٥٢',
    ),
    // 2: Wednesday
    _AyahEntry(
      arabic: 'فَاسْتَقِمْ كَمَا أُمِرْتَ وَمَن تَابَ مَعَكَ',
      english: '“So remain on a right course as you have been commanded with those who have turned back with you.”',
      refEn: 'Surah Hud • 11:112',
      refAr: 'سورة هود • الآية ١١٢',
    ),
    // 3: Thursday
    _AyahEntry(
      arabic: 'وَلَوْ أَنَّ أَهْلَ الْقُرَىٰ آمَنُوا وَاتَّقَوْا لَفَتَحْنَا عَلَيْهِم بَرَكَاتٍ مِّنَ السَّمَاءِ وَالْأَرْضِ',
      english: '“And if only the people of the cities had believed and feared Allah, We would have opened upon them blessings from heaven and earth.”',
      refEn: 'Surah Al-A\'raf • 7:96',
      refAr: 'سورة الأعراف • الآية ٩٦',
    ),
    // 4: Friday
    _AyahEntry(
      arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا نُودِيَ لِلصَّلَاةِ مِن يَوْمِ الْجُمُعَةِ فَاسْعَوْا إِلَىٰ ذِكْرِ اللَّهِ',
      english: '“O you who have believed, when the call is made for prayer on Friday, hasten to the remembrance of Allah.”',
      refEn: 'Surah Al-Jumu\'ah • 62:9',
      refAr: 'سورة الجمعة • الآية ٩',
    ),
    // 5: Saturday
    _AyahEntry(
      arabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا • إِنَّ مَعَ الْعُسْرِ يُسْرًا • فَإِذَا فَرَغْتَ فَانصَبْ',
      english: '“For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease. So when you have finished, labor.”',
      refEn: 'Surah Al-Sharh • 94:5-7',
      refAr: 'سورة الشرح • الآيات ٥-٧',
    ),
    // 6: Sunday
    _AyahEntry(
      arabic: 'الَّذِي خَلَقَ الْمَوْتَ وَالْحَيَاةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا',
      english: '“[He] who created death and life to test you as to which of you is best in deed.”',
      refEn: 'Surah Al-Mulk • 67:2',
      refAr: 'سورة الملك • الآية ٢',
    ),
  ];

  _AyahEntry _getTodayAyah() {
    final weekday = DateTime.now().weekday; // 1 (Mon) - 7 (Sun)
    final index = (weekday - 1).clamp(0, 6);
    return _weeklyAyahs[index];
  }

  Future<String?> _fetchTodayReflection(String today) async {
    if (!getIt.isRegistered<BarakahRepository>()) return null;
    try {
      final entries = await getIt<BarakahRepository>().getEntriesForDate(today);
      for (final e in entries) {
        if (e.note != null && e.note!.trim().isNotEmpty) {
          return e.note!.trim();
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final ayah = _getTodayAyah();

    return Stack(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          borderColor: const Color(0xFFD4AF37)
              .withValues(alpha: isDark ? 0.25 : 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFFD4AF37),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isAr ? 'آية البركة اليومية' : 'AYAH OF BARAKAH',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: isDark
                                  ? const Color(0xFFD4AF37)
                                  : const Color(0xFF92600E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: isAr ? 'تلاوة' : 'Recitation',
                        onPressed: () {
                          AppHaptics.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isAr
                                    ? 'استمع إلى تلاوة خاشعة لهذه الآية'
                                    : 'Recitation audio stream ready',
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          color: _isBookmarked ? const Color(0xFFD4AF37) : null,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: isAr ? 'حفظ' : 'Bookmark',
                        onPressed: () {
                          AppHaptics.selectionClick();
                          setState(() => _isBookmarked = !_isBookmarked);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isBookmarked
                                    ? (isAr
                                          ? 'تم حفظ الآية في المفضلة'
                                          : 'Ayah bookmarked')
                                    : (isAr
                                          ? 'تمت إزالة الحفظ'
                                          : 'Bookmark removed'),
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ayah.arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'amiri',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.9,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ayah.english,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAr ? ayah.refAr : ayah.refEn,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 10),
              FutureBuilder<String?>(
                future: _fetchTodayReflection(today),
                builder: (context, snapshot) {
                  final reflection = snapshot.data;
                  final displayText = reflection != null
                      ? (isAr
                            ? 'تأمل اليوم: "$reflection"'
                            : 'Today\'s reflection: "$reflection"')
                      : (isAr
                            ? 'لم تسجل تأملاً لليوم بعد'
                            : 'No reflection recorded yet today');

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: TextButton.icon(
                            onPressed: () => context.go(AppRoutes.reflect),
                            icon: const Icon(Icons.edit_note_rounded, size: 18),
                            label: Text(
                              isAr ? 'تدوين وتأمل' : 'Reflect & Journal',
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: isDark
                                  ? AppColors.secondary
                                  : AppColors.primary,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
        Positioned(
          top: 8,
          right: 12,
          child: Text(
            '۞',
            style: TextStyle(
              fontSize: 22,
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 12,
          child: Text(
            '۞',
            style: TextStyle(
              fontSize: 22,
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }
}
