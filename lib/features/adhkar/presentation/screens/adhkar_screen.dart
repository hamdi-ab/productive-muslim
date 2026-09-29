import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
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
    HapticFeedback.selectionClick();
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

    if (next == item.targetCount) {
      HapticFeedback.mediumImpact();
      // Record completion
      try {
        if (getIt.isRegistered<AdhkarService>()) {
          await getIt<AdhkarService>().recordDhikrCompletion(dhikrId: item.id);
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
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _resetCount(DhikrItem item) {
    HapticFeedback.lightImpact();
    setState(() {
      _counts[item.id] = 0;
    });
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adhkarTitle),
        actions: [
          if (items.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_currentPageIndex + 1} / ${items.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: DhikrCategory.values.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_getCategoryLabel(cat, l10n)),
                      selected: isSelected,
                      onSelected: (_) => _onCategorySelected(cat),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Card Carousel Viewport
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text(l10n.adhkarEmptyState))
                  : PageView.builder(
                      controller: _pageController,
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
                            vertical: AppSpacing.sm,
                          ),
                          child: DhikrCard(
                            item: item,
                            count: count,
                            onTap: () => _incrementCount(item),
                            onReset: () => _resetCount(item),
                          ),
                        );
                      },
                    ),
            ),

            // Carousel Bottom Controls
            if (items.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
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
                      children: List.generate(
                        items.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPageIndex == index
                                ? AppColors.primary
                                : (isDark ? Colors.white24 : Colors.black12),
                          ),
                        ),
                      ),
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}
