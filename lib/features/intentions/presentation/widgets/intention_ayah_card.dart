import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';

/// Ayah of Barakah callout card (Surah At-Talaq: 3) inspiring tawakkul.
class IntentionAyahCard extends StatelessWidget {
  final bool isDark;

  const IntentionAyahCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16241C) : const Color(0xFFFAF8F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_quote_rounded,
                size: 16,
                color: AppColors.secondaryDark,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'AYAH OF BARAKAH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.secondaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'amiri',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryDark,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '“And whoever relies upon Allah — then He is sufficient for him.”',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Surah At-Talaq: 3',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
