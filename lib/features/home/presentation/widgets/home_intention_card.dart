import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';

/// Serene card on Home displaying today's spiritual intention and purpose.
class HomeIntentionCard extends StatelessWidget {
  final String today;
  final bool isDark;

  const HomeIntentionCard({
    super.key,
    required this.today,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    IntentionRepository? repo;
    try {
      repo = context.read<IntentionRepository>();
    } catch (_) {
      if (getIt.isRegistered<IntentionRepository>()) {
        repo = getIt<IntentionRepository>();
      }
    }
    if (repo == null) return const SizedBox.shrink();

    return StreamBuilder<List<IntentionEntry>>(
      stream: repo.watchEntriesForDate(today),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? [];
        final hasIntention = entries.isNotEmpty;
        final intention = hasIntention ? entries.first : null;

        return InkWell(
          onTap: () => context.go(AppRoutes.reflect),
          borderRadius: BorderRadius.circular(20),
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F4C3A)
                                  .withValues(alpha: isDark ? 0.35 : 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.spa_rounded,
                              size: 16,
                              color: Color(0xFF4EDEA3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isAr ? 'نية اليوم' : "Today's Intention",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                                letterSpacing: 0.3,
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
                        child: Text(
                          hasIntention
                              ? (isAr ? 'تعديل' : 'Reflect')
                              : (isAr ? 'تحديد نية' : 'Set Intention'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFE9C349)
                                : const Color(0xFF0F4C3A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (hasIntention && intention != null) ...[
                  Text(
                    intention.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  if (intention.statement != null &&
                      intention.statement!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      intention.statement!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ] else ...[
                  Text(
                    isAr ? 'ابدأ يومك بنية صادقة وخالصة لوجه الله' : 'Begin your day with sincere niyyah and clear purpose.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
