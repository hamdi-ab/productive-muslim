import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';

class HomeDailyAyahCard extends StatelessWidget {
  final bool isDark;

  const HomeDailyAyahCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
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
                            'AYAH OF BARAKAH',
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
                        tooltip: 'Recitation',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.bookmark_outline_rounded,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: 'Bookmark',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'وَتَوَكَّلْ عَلَى الْحَيِّ الَّذِي لَا يَمُوتُ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '“And put your trust in the Ever-Living Who dies not, and celebrate His praise.”',
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
                'Surah Al-Furqan • 25:58',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Personal reflection note empty',
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
                        onPressed: () => context.push('/journal'),
                        icon: const Icon(Icons.edit_note_rounded, size: 18),
                        label: const Text('Reflect & Journal'),
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
