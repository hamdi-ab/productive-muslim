import 'package:flutter/material.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';

/// Card presenting the 3 Sunnah Physical Anchors from Mohammed Faris's Barakah Framework:
/// 1. Sleep on the Sunnah
/// 2. 1/3 Rule for Nutrition
/// 3. Daily Movement to the Mosque
class EnergyPhysicalAnchorsCard extends StatelessWidget {
  const EnergyPhysicalAnchorsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141E1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF404944).withValues(alpha: 0.5)
              : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'BARAKAH FRAMEWORK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4EDEA3),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Sunnah Physical Anchors',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '3 Daily Habits',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8A938D),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Card 1: Sleep on the Sunnah
          _buildAnchorHabitCard(
            icon: Icons.night_shelter_rounded,
            tag: 'Night Architecture',
            title: 'Sleep on the Sunnah',
            desc: 'Sleep immediately after Isha, perform Wudu before bed, dust the mattress, and sleep on the right side facing Qibla.',
            status: 'Tonight Checklist Ready',
            color: const Color(0xFF4EDEA3),
            isDark: isDark,
          ),

          const SizedBox(height: 10),

          // Card 2: 1/3 Rule for Nutrition
          _buildAnchorHabitCard(
            icon: Icons.restaurant_rounded,
            tag: 'Prophetic Diet',
            title: 'The 1/3 Rule for Nutrition',
            desc: '"One-third for food, one-third for drink, and one-third for breath." — Sunan al-Tirmidhi. Keeps digestion light and avoids sluggishness.',
            status: 'Clean & Light Midday',
            color: const Color(0xFFE9C349),
            isDark: isDark,
          ),

          const SizedBox(height: 10),

          // Card 3: Daily Movement to Mosque
          _buildAnchorHabitCard(
            icon: Icons.directions_walk_rounded,
            tag: 'Steps of Barakah',
            title: 'Daily Movement to the Mosque',
            desc: 'Intentional walking for congregational Salah — each step elevates a rank and erases an error.',
            status: '2,840 / 5,000 Steps Logged',
            color: const Color(0xFF99D3BA),
            isDark: isDark,
            progress: 0.56,
          ),
        ],
      ),
    );
  }

  Widget _buildAnchorHabitCard({
    required IconData icon,
    required String tag,
    required String title,
    required String desc,
    required String status,
    required Color color,
    required bool isDark,
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18221E) : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? const Color(0xFF404944).withValues(alpha: 0.3)
              : AppColors.borderLight,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              color: isDark ? const Color(0xFFBFC9C3) : AppColors.textSecondary,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: isDark
                    ? const Color(0xFF222C29)
                    : Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
