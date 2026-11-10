import 'package:flutter/material.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Segmented button selector allowing users to switch languages between System, English, and Arabic.
class SettingsLocaleSelector extends StatelessWidget {
  const SettingsLocaleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = getIt.isRegistered<SettingsService>()
        ? getIt<SettingsService>()
        : null;

    return ValueListenableBuilder<Locale?>(
      valueListenable: settings?.localeNotifier ?? ValueNotifier<Locale?>(null),
      builder: (context, _, _) {
        final currentCode = settings?.localeCode ?? 'system';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.language,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.primary,
                    selectedForegroundColor: Colors.white,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceSubtle
                        : AppColors.surfaceSubtle,
                    foregroundColor: isDark ? Colors.white70 : Colors.black87,
                    side: BorderSide(
                      color: isDark
                          ? const Color(0x3310B981)
                          : const Color(0x1F0F4C3A),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  segments: [
                    ButtonSegment<String>(
                      value: 'system',
                      label: Text(l10n.languageSystem),
                    ),
                    const ButtonSegment<String>(
                      value: 'en',
                      label: Text('English'),
                    ),
                    const ButtonSegment<String>(
                      value: 'ar',
                      label: Text('العربية'),
                    ),
                  ],
                  selected: {currentCode},
                  onSelectionChanged: (newSelection) {
                    final selected = newSelection.first;
                    settings?.setLocaleCode(selected);
                    AppHaptics.selectionClick();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
