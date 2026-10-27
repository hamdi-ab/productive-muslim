import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/home_widget_sync_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/arabic_typography_sheet.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/dhikr_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

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
      // Record completion
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

      // Auto advance to next card after brief delay if not last and category hasn't changed
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

  String _getCategoryLabel(DhikrCategory category, AppLocalizations l10n) {
    switch (category) {
      case DhikrCategory.morning:
        return l10n.adhkarTabMorning;
      case DhikrCategory.evening:
        return l10n.adhkarTabEvening;
      case DhikrCategory.wakingUp:
        return l10n.adhkarTabWaking;
      case DhikrCategory.sleeping:
        return l10n.adhkarTabBedtime;
      case DhikrCategory.postPrayer:
        return l10n.adhkarTabPostSalah;
      case DhikrCategory.dailySunnah:
        return l10n.adhkarTabSunnah;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _currentItems;
    final completedCount = items
        .where((item) => (_counts[item.id] ?? 0) >= item.targetCount)
        .length;
    final progressPercent = items.isNotEmpty
        ? (completedCount / items.length).clamp(0.0, 1.0)
        : 0.0;

    final content = Column(
      children: [
        // Category Tabs (Horizontal Pill Selector)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: DhikrCategory.values.map((cat) {
              final isSelected = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AppPressable(
                  onTap: () => _onCategorySelected(cat),
                  pressedScale: 0.95,
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? AppColors.primary.withValues(alpha: 0.35)
                                : AppColors.primary.withValues(alpha: 0.12))
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.black.withValues(alpha: 0.03)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? (isDark
                                  ? AppColors.secondary.withValues(alpha: 0.6)
                                  : AppColors.primary.withValues(alpha: 0.4))
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06)),
                        width: isSelected ? 1.2 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                        Text(
                          _getCategoryLabel(cat, l10n),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.primary)
                                : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // Card Carousel Viewport
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

        // Bottom Session Completion & Action Dock
        if (items.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              10,
              AppSpacing.md,
              12,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0D1714).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Session Progress Header & Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fact_check_rounded,
                          size: 14,
                          color: isDark
                              ? AppColors.secondary
                              : AppColors.secondaryDark,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Session Progress',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$completedCount of ${items.length} completed (${(progressPercent * 100).round()}%)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.secondary
                            : AppColors.secondaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    minHeight: 4,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressPercent == 1.0
                          ? const Color(0xFF10B981)
                          : AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Controls Row (Prev / Dots / Next)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _currentPageIndex > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: Text(l10n.adhkarPrev),
                    ),
                    Row(
                      children: List.generate(items.length, (index) {
                        final isCurrent = _currentPageIndex == index;
                        final isItemDone =
                            (_counts[items[index].id] ?? 0) >=
                            items[index].targetCount;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isCurrent ? 14 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: isCurrent
                                ? AppColors.secondary
                                : (isItemDone
                                      ? const Color(0xFF10B981)
                                            .withValues(alpha: 0.6)
                                      : (isDark
                                            ? Colors.white24
                                            : Colors.black12)),
                          ),
                        );
                      }),
                    ),
                    TextButton.icon(
                      onPressed: _currentPageIndex < items.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      label: Text(l10n.adhkarNext),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );

    return Scaffold(
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
              child: Text(
                '${_currentPageIndex + 1} / ${items.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          // Ambient Sacred Atmosphere Aura
          if (isDark) ...[
            Positioned(
              top: -60,
              left: MediaQuery.of(context).size.width / 2 - 100,
              child: IgnorePointer(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: -50,
              child: IgnorePointer(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withValues(alpha: 0.06),
                  ),
                ),
              ),
            ),
          ],
          SafeArea(child: content),
        ],
      ),
    );
  }
}
