import 'package:flutter/material.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';

/// Inspirational closing card emphasizing intentional rest as worship.
class EnergyPromiseCard extends StatelessWidget {
  const EnergyPromiseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F4C3A).withValues(alpha: isDark ? 0.5 : 0.15),
            const Color(0xFF141E1A).withValues(alpha: isDark ? 0.9 : 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9C349).withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 20,
            color: Color(0xFFE9C349),
          ),
          const SizedBox(height: 4),
          Text(
            isAr
                ? 'استثمار طاقة الجسد في طاعة الخالق'
                : 'Energize Body for the Creator',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isAr
                ? 'طاقتك أمانة واستثمار في العبادة والنفع. تجديد النشاط بنية السنة يحول الراحة إلى عبادة مأجورة مستمرة.'
                : 'Your energy is an investment in worship and service. Recharging with Sunnah intention transforms rest into continuous reward.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? const Color(0xFF8A938D) : AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
