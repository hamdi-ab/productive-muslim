import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/arabic_typography.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class ArabicTypographySheet extends StatefulWidget {
  const ArabicTypographySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ArabicTypographySheet(),
    );
  }

  @override
  State<ArabicTypographySheet> createState() => _ArabicTypographySheetState();
}

class _ArabicTypographySheetState extends State<ArabicTypographySheet> {
  late SettingsService _settingsService;
  late ArabicFontFamily _selectedFont;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _settingsService = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : SettingsService.empty();
    _selectedFont = ArabicFontFamily.fromKey(_settingsService.arabicFontFamily);
    _fontSize = _settingsService.arabicFontSize;
  }

  Future<void> _onFontSelected(ArabicFontFamily font) async {
    if (_selectedFont == font) return;
    AppHaptics.selectionClick();
    setState(() => _selectedFont = font);
    await _settingsService.setArabicFontFamily(font.key);
  }

  Future<void> _onSizeChanged(double newSize) async {
    final clamped = newSize.clamp(16.0, 32.0);
    if ((clamped - _fontSize).abs() < 0.5) return;
    AppHaptics.selectionClick();
    setState(() => _fontSize = clamped);
    await _settingsService.setArabicFontSize(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Sheet Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.format_size_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.typographyTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Live Preview Card
            GlassContainer(
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.typographyPreview,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${_fontSize.round()} px',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: _selectedFont.getTextStyle(
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Font Size Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.typographyFontSize,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      onPressed: _fontSize > 16
                          ? () => _onSizeChanged(_fontSize - 2)
                          : null,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      onPressed: _fontSize < 32
                          ? () => _onSizeChanged(_fontSize + 2)
                          : null,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.15),
              ),
              child: Slider(
                value: _fontSize,
                min: 16.0,
                max: 32.0,
                divisions: 8,
                onChanged: (val) => _onSizeChanged(val),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Calligraphy Font Styles
            Text(
              l10n.typographyFontFamily,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.sm),

            ...ArabicFontFamily.values.map((font) {
              final isSelected = font == _selectedFont;
              final label = isArabic ? font.labelAr : font.labelEn;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: AppPressable(
                  onTap: () => _onFontSelected(font),
                  haptic: AppHapticFeedback.selection,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : (isDark
                                ? Colors.black.withValues(alpha: 0.2)
                                : AppColors.surfaceSubtle),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.white10 : Colors.black12),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                            ? Colors.white
                                            : Colors.black87),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                textDirection: TextDirection.rtl,
                                style: font.getTextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
