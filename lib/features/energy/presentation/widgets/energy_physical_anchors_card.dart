import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/data/services/settings_service.dart';

String _toArabicDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], arabic[i]);
  }
  return input;
}

/// Interactive card presenting the 3 Sunnah Physical Anchors from Mohammed Faris's Barakah Framework:
/// 1. Sleep on the Sunnah (Night Architecture)
/// 2. 1/3 Rule for Nutrition (Prophetic Diet)
/// 3. Daily Movement to the Mosque (Steps of Barakah)
class EnergyPhysicalAnchorsCard extends StatefulWidget {
  const EnergyPhysicalAnchorsCard({super.key});

  @override
  State<EnergyPhysicalAnchorsCard> createState() =>
      _EnergyPhysicalAnchorsCardState();
}

class _EnergyPhysicalAnchorsCardState extends State<EnergyPhysicalAnchorsCard> {
  late final String _today;
  Set<String> _completedAnchors = {};

  @override
  void initState() {
    super.initState();
    _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadAnchors();
  }

  void _loadAnchors() {
    try {
      if (getIt.isRegistered<SettingsService>()) {
        final settings = getIt<SettingsService>();
        setState(() {
          _completedAnchors = settings.getPhysicalAnchors(_today);
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleAnchor(String anchorId) async {
    AppHaptics.selectionClick();
    try {
      if (getIt.isRegistered<SettingsService>()) {
        final settings = getIt<SettingsService>();
        await settings.togglePhysicalAnchor(_today, anchorId);
        setState(() {
          _completedAnchors = settings.getPhysicalAnchors(_today);
        });
      } else {
        setState(() {
          if (_completedAnchors.contains(anchorId)) {
            _completedAnchors.remove(anchorId);
          } else {
            _completedAnchors.add(anchorId);
          }
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final completedCount = _completedAnchors.length;
    final progress = completedCount / 3.0;

    final progressCountStr = isAr
        ? _toArabicDigits('$completedCount')
        : '$completedCount';
    final totalCountStr = isAr ? '٣' : '3';

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
          // Header Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAr ? 'إطار البركة النبوي' : 'BARAKAH FRAMEWORK',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4EDEA3),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      isAr
                          ? 'مرتكزات الجسد النبوية'
                          : 'Sunnah Physical Anchors',
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
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4EDEA3).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF4EDEA3).withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      isAr
                          ? '$progressCountStr / $totalCountStr منجز اليوم'
                          : '$progressCountStr / $totalCountStr Completed',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4EDEA3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Overall Anchors Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: isDark
                  ? const Color(0xFF222C29)
                  : Colors.grey.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4EDEA3),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Anchor 1: Sleep on the Sunnah
          _buildAnchorHabitCard(
            id: 'sleep',
            icon: Icons.night_shelter_rounded,
            tag: isAr ? 'هندسة النوم' : 'Night Architecture',
            title: isAr ? 'النوم على السنة النبوية' : 'Sleep on the Sunnah',
            desc: isAr
                ? 'النوم مبكراً بعد العشاء، والوضوء قبل النوم، ونفض الفراش، والاضطجاع على الشق الأيمن مستقبل القبلة.'
                : 'Sleep immediately after Isha, perform Wudu before bed, dust the mattress, and sleep on the right side facing Qibla.',
            activeStatus: isAr
                ? 'تم الالتزام بنوم السنة الليلة'
                : 'Sunnah Sleep Ritual Done',
            inactiveStatus: isAr
                ? 'جاهز لقائمة نوم الليلة'
                : 'Tonight Checklist Ready',
            color: const Color(0xFF4EDEA3),
            isDark: isDark,
            isAr: isAr,
          ),

          const SizedBox(height: 10),

          // Anchor 2: The 1/3 Rule for Nutrition
          _buildAnchorHabitCard(
            id: 'nutrition',
            icon: Icons.restaurant_rounded,
            tag: isAr ? 'الهدي النبوي' : 'Prophetic Diet',
            title: isAr
                ? 'قاعدة الثلث في التغذية'
                : 'The 1/3 Rule for Nutrition',
            desc: isAr
                ? '«ثُلُثٌ لِطَعَامِهِ وَثُلُثٌ لِشَرَابِهِ وَثُلُثٌ لِنَفَسِهِ» — رواه الترمذي. يحفظ خفة البدن ونشاط الروح.'
                : '"One-third for food, one-third for drink, and one-third for breath." — Sunan al-Tirmidhi. Keeps digestion light and avoids sluggishness.',
            activeStatus: isAr
                ? 'تم الالتزام بثُلث الطعام'
                : '1/3 Nutrition Rule Observed',
            inactiveStatus: isAr
                ? 'وجبات خفيفة ومتوازنة'
                : 'Clean & Light Midday',
            color: const Color(0xFFE9C349),
            isDark: isDark,
            isAr: isAr,
          ),

          const SizedBox(height: 10),

          // Anchor 3: Daily Movement to Mosque
          _buildAnchorHabitCard(
            id: 'movement',
            icon: Icons.directions_walk_rounded,
            tag: isAr ? 'خطوات البركة' : 'Steps of Barakah',
            title: isAr
                ? 'المشي لصلاة الجماعة والحركة'
                : 'Daily Movement to the Mosque',
            desc: isAr
                ? 'المشي الواعي إلى صلاة الجماعة — بكل خطوة ترفع درجة وتحط خطيئة، وتجدد الدورة الدموية.'
                : 'Intentional walking for congregational Salah — each step elevates a rank and erases an error.',
            activeStatus: isAr
                ? 'أنجزت خطوات صلاة الجماعة'
                : 'Mosque Walk & Movement Logged',
            inactiveStatus: isAr
                ? 'المشي لصلاة الجماعة والحركة'
                : 'Congregational Walk & Steps',
            color: const Color(0xFF99D3BA),
            isDark: isDark,
            isAr: isAr,
          ),
        ],
      ),
    );
  }

  Widget _buildAnchorHabitCard({
    required String id,
    required IconData icon,
    required String tag,
    required String title,
    required String desc,
    required String activeStatus,
    required String inactiveStatus,
    required Color color,
    required bool isDark,
    required bool isAr,
  }) {
    final isCompleted = _completedAnchors.contains(id);

    return AppPressable(
      onTap: () => _toggleAnchor(id),
      pressedScale: 0.98,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? color.withValues(alpha: isDark ? 0.14 : 0.08)
              : (isDark ? const Color(0xFF18221E) : AppColors.surfaceSubtle),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted
                ? color.withValues(alpha: 0.7)
                : (isDark
                      ? const Color(0xFF404944).withValues(alpha: 0.3)
                      : AppColors.borderLight),
            width: isCompleted ? 1.4 : 0.8,
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
                    color: color.withValues(alpha: isCompleted ? 0.25 : 0.16),
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
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isCompleted ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? color
                          : (isDark
                                ? Colors.white30
                                : Colors.black.withValues(alpha: 0.25)),
                      width: 1.5,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Color(0xFF0B1512),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                color: isDark
                    ? const Color(0xFFBFC9C3)
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isCompleted ? color : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isCompleted ? activeStatus : inactiveStatus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isCompleted
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isCompleted
                          ? color
                          : (isDark
                                ? const Color(0xFF8A938D)
                                : AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
