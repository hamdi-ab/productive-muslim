import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/home_widget_sync_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_background_atmosphere.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_category_tabs.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_session_dock.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/arabic_typography_sheet.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/dhikr_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

String _toArabicDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], arabic[i]);
  }
  return input;
}

class AdhkarScreen extends StatefulWidget {
  final DhikrCategory initialCategory;

  const AdhkarScreen({super.key, this.initialCategory = DhikrCategory.morning});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  late DhikrCategory _selectedCategory;
  late PageController _pageController;
  int _currentPageIndex = 0;
  final Map<String, int> _counts = {};
  int _categoryVersion = 0;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _pageController = PageController();
    _loadSavedCounts();
  }

  void _loadSavedCounts() {
    try {
      if (getIt.isRegistered<AdhkarService>()) {
        final adhkarService = getIt<AdhkarService>();
        final completedIds = adhkarService.getCompletedDhikrIdsForDate(null);
        for (final item in AdhkarCatalog.all) {
          if (completedIds.contains(item.id)) {
            _counts[item.id] = item.targetCount;
          } else {
            final saved = adhkarService.getDhikrCount(item.id);
            if (saved > 0) {
              _counts[item.id] = saved;
            }
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<DhikrItem> get _currentItems =>
      AdhkarCatalog.getByCategory(_selectedCategory);

  void _onCategorySelected(DhikrCategory category) {
    if (_selectedCategory == category) return;
    AppHaptics.selectionClick();
    setState(() {
      _selectedCategory = category;
      _currentPageIndex = 0;
      _categoryVersion++;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  Future<void> _incrementCount(DhikrItem item) async {
    final current = _counts[item.id] ?? 0;
    if (current >= item.targetCount) return;

    final next = current + 1;
    setState(() {
      _counts[item.id] = next;
    });

    try {
      if (getIt.isRegistered<AdhkarService>()) {
        await getIt<AdhkarService>().recordDhikrCount(
          dhikrId: item.id,
          count: next,
        );
      }
    } catch (_) {}

    if (next == item.targetCount) {
      AppHaptics.heavyImpact();
      try {
        if (getIt.isRegistered<AdhkarService>()) {
          final adhkarService = getIt<AdhkarService>();
          await adhkarService.recordDhikrCompletion(dhikrId: item.id);
          if (getIt.isRegistered<HomeWidgetSyncService>()) {
            final count = adhkarService
                .getCompletedDhikrIdsForDate(null)
                .length;
            getIt<HomeWidgetSyncService>().syncDhikrCount(count);
          }
        }
      } catch (_) {}

      final scheduledVersion = _categoryVersion;
      if (_currentPageIndex < _currentItems.length - 1) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted &&
              _pageController.hasClients &&
              _categoryVersion == scheduledVersion) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    } else if (next == 33 || next == 66) {
      AppHaptics.mediumImpact();
    } else {
      AppHaptics.lightImpact();
    }
  }

  Future<void> _resetCount(DhikrItem item) async {
    AppHaptics.lightImpact();
    setState(() {
      _counts[item.id] = 0;
    });
    try {
      if (getIt.isRegistered<AdhkarService>()) {
        await getIt<AdhkarService>().resetDhikr(dhikrId: item.id);
      }
    } catch (_) {}
  }

  Future<void> _resetCategory(DhikrCategory category) async {
    AppHaptics.mediumImpact();
    final items = AdhkarCatalog.getByCategory(category);
    setState(() {
      for (final item in items) {
        _counts[item.id] = 0;
      }
    });
    try {
      if (getIt.isRegistered<AdhkarService>()) {
        await getIt<AdhkarService>().resetCategory(category);
      }
    } catch (_) {}
  }

  Future<void> _showTypographySheet() async {
    await ArabicTypographySheet.show(context);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final items = _currentItems;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: ProductiveAppBar(
        title: l10n.adhkarTitle,
        subtitle: l10n.adhkarSubtitle,
        showBackButton: true,
        actions: [
          if (items.isNotEmpty) ...[
            ProductiveAppBarAction(
              tooltip: l10n.typographyTooltip,
              icon: Icons.format_size_rounded,
              onTap: _showTypographySheet,
            ),
            ProductiveAppBarAction(
              tooltip: l10n.adhkarResetCategory,
              icon: Icons.restart_alt_rounded,
              onTap: () => _resetCategory(_selectedCategory),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryLight.withValues(alpha: 0.16)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.primaryLight.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isAr
                      ? '${_toArabicDigits('${_currentPageIndex + 1}')} / ${_toArabicDigits('${items.length}')}'
                      : '${_currentPageIndex + 1} / ${items.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          AdhkarBackgroundAtmosphere(isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                AdhkarCategoryTabs(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: _onCategorySelected,
                  l10n: l10n,
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.xs),
                Expanded(
                  child: items.isEmpty
                      ? Center(child: Text(l10n.adhkarEmptyState))
                      : PageView.builder(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          onPageChanged: (idx) {
                            setState(() => _currentPageIndex = idx);
                          },
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final count = _counts[item.id] ?? 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              child: DhikrCard(
                                item: item,
                                count: count,
                                index: index + 1,
                                total: items.length,
                                onTap: () => _incrementCount(item),
                                onReset: () => _resetCount(item),
                              ),
                            );
                          },
                        ),
                ),
                AdhkarSessionDock(
                  items: items,
                  counts: _counts,
                  currentPageIndex: _currentPageIndex,
                  onPrevious: _currentPageIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  onNext: _currentPageIndex < items.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  l10n: l10n,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
