import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/router/app_routes.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class _QualityCardData {
  final String titleEn;
  final String titleAr;
  final String qualityEn;
  final String qualityAr;
  final String descEn;
  final String descAr;
  final String route;
  final IconData icon;
  final Color color;

  const _QualityCardData({
    required this.titleEn,
    required this.titleAr,
    required this.qualityEn,
    required this.qualityAr,
    required this.descEn,
    required this.descAr,
    required this.route,
    required this.icon,
    required this.color,
  });
}

class HomeQualitiesCarousel extends StatelessWidget {
  final AppLocalizations l10n;

  const HomeQualitiesCarousel({super.key, required this.l10n});

  static const List<_QualityCardData> _qualities = [
    _QualityCardData(
      titleEn: 'Spiritual Purity',
      titleAr: 'طهارة الروح',
      qualityEn: 'Ikhlas (Sincerity)',
      qualityAr: 'الإخلاص لله',
      descEn: 'Purify intentions before every action and word.',
      descAr: 'إخلاص النية لله تعالى قبل كل قول وفعل.',
      route: AppRoutes.journal,
      icon: Icons.favorite_rounded,
      color: Color(0xFF10B981),
    ),
    _QualityCardData(
      titleEn: 'God-Consciousness',
      titleAr: 'حضور القلب',
      qualityEn: 'Muraqabah (Mindfulness)',
      qualityAr: 'المراقبة والذكر',
      descEn: 'Mindful presence through continuous remembrance and reflection.',
      descAr: 'الاستشعار الدائم لمعية الله بالذكر والتأمل الصادق.',
      route: AppRoutes.adhkar,
      icon: Icons.fingerprint_rounded,
      color: Color(0xFF0D9488),
    ),
    _QualityCardData(
      titleEn: 'Energy & Purity',
      titleAr: 'طهارة ونشاط',
      qualityEn: 'Taharah (Purity)',
      qualityAr: 'الطهارة والنشاط',
      descEn: 'Renewed wudhu, restorative sleep, and vibrant clean energy.',
      descAr: 'تجديد الوضوء، والنوم الكافي، والطاقة الحيوية النظيفة.',
      route: AppRoutes.energy,
      icon: Icons.water_drop_rounded,
      color: Color(0xFF0284C7),
    ),
    _QualityCardData(
      titleEn: 'Excellence in Action',
      titleAr: 'إتقان العمل',
      qualityEn: 'Ihsan (Excellence)',
      qualityAr: 'الإحسان والإتقان',
      descEn: 'Execute work and daily tasks as beautiful worship.',
      descAr: 'إتقان كل مهمة وعمل كأنك تؤديه عبادة خالصة لله.',
      route: AppRoutes.tasks,
      icon: Icons.star_rounded,
      color: Color(0xFFD4AF37),
    ),
    _QualityCardData(
      titleEn: 'Abundant Gratitude',
      titleAr: 'استدامة النعم',
      qualityEn: 'Shukr (Gratitude)',
      qualityAr: 'الشكر والثناء',
      descEn: 'Daily recognition of blessings preserves and multiplies them.',
      descAr: 'تدوين النعم اليومية وحفظها بالحمد والشكر المستمر.',
      route: AppRoutes.journal,
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFF59E0B),
    ),
    _QualityCardData(
      titleEn: 'Divine Trust',
      titleAr: 'تفويض وتوكل',
      qualityEn: 'Tawakkul (Reliance)',
      qualityAr: 'التوكل على الله',
      descEn: 'Exert full effort while trusting Allah for every outcome.',
      descAr: 'بذل أقصى الأسباب مع اليقين ببركة الله وتوفيقه.',
      route: AppRoutes.barakah,
      icon: Icons.shield_rounded,
      color: Color(0xFF6366F1),
    ),
    _QualityCardData(
      titleEn: 'Steadfast Habits',
      titleAr: 'ثبات العادات',
      qualityEn: 'Istiqamah (Consistency)',
      qualityAr: 'الاستقامة والمداومة',
      descEn: 'The most beloved deeds are those done regularly, even if small.',
      descAr: 'أحب الأعمال إلى الله تعالى أدومها وإن قلّت.',
      route: AppRoutes.habits,
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFEA580C),
    ),
    _QualityCardData(
      titleEn: 'Balanced Living',
      titleAr: 'التوسط والاعتدال',
      qualityEn: 'Iqtisad (Moderation)',
      qualityAr: 'الاقتصاد والتوازن',
      descEn: 'Giving body and spirit their due rights without burnout.',
      descAr: 'إعطاء الجسد والروح حقهما بتناغم دون إرهاق أو تفريط.',
      route: AppRoutes.energy,
      icon: Icons.balance_rounded,
      color: Color(0xFF14B8A6),
    ),
    _QualityCardData(
      titleEn: 'Deep Purpose',
      titleAr: 'حضور وتركيز',
      qualityEn: 'Qasd (Purpose & Focus)',
      qualityAr: 'القصد والخشوع',
      descEn: 'Deep focused work blocks free from distractions and noise.',
      descAr: 'التركيز العميق في مساحات خالية من المشتتات والضوضاء.',
      route: AppRoutes.focus,
      icon: Icons.center_focus_strong_rounded,
      color: Color(0xFF8B5CF6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isAr ? 'الصفات الأساسية التسع' : 'Essential Qualities',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.profile),
                  child: Text(
                    isAr ? 'عرض الكل' : 'Explore All',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 154,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _qualities.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final q = _qualities[index];
              return AppPressable(
                onTap: () {
                  AppHaptics.lightImpact();
                  final route = q.route;
                  if (route == AppRoutes.profile ||
                      route == AppRoutes.journal ||
                      route == AppRoutes.tasks ||
                      route == AppRoutes.habits ||
                      route == AppRoutes.barakah) {
                    context.go(route);
                  } else {
                    context.push(route);
                  }
                },
                pressedScale: 0.96,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: q.color.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: q.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(q.icon, color: q.color, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isAr ? q.qualityAr : q.qualityEn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isAr ? q.descAr : q.descEn,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isAr ? q.titleAr : q.titleEn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: q.color,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: q.color.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
