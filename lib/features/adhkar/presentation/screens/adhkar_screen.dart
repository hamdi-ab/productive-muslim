import 'dart:async';

import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/home_widget_sync_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
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
  bool _isBookmarksView = false;
  late PageController _pageController;
  int _currentPageIndex = 0;
  final Map<String, int> _counts = {};
  int _categoryVersion = 0;

  final Set<String> _bookmarkedIds = {};
  bool _showTransliteration = false;
  bool _isCompletedToday = false;

  AdhkarRepository? get _adhkarRepo =>
      getIt.isRegistered<AdhkarRepository>() ? getIt<AdhkarRepository>() : null;

  SettingsService? get _settingsService =>
      getIt.isRegistered<SettingsService>() ? getIt<SettingsService>() : null;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _pageController = PageController();
    _showTransliteration =
        _settingsService?.adhkarTransliterationEnabled ?? false;
    _initData();
  }

  Future<void> _initData() async {
    _loadLegacySavedCounts();
    await _loadBookmarks();
    await _loadSessionForCollection(_selectedCategory.name);
  }

  Future<void> _loadBookmarks() async {
    if (_adhkarRepo != null) {
      try {
        final bookmarks = await _adhkarRepo!.getBookmarkedItems();
        if (mounted) {
          setState(() {
            _bookmarkedIds.clear();
            _bookmarkedIds.addAll(bookmarks.map((b) => b.id));
          });
        }
      } catch (_) {}
    }
  }

  void _loadLegacySavedCounts() {
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

  Future<void> _loadSessionForCollection(String collectionId) async {
    if (_adhkarRepo == null) return;
    try {
      final isCompleted = await _adhkarRepo!.isCollectionCompletedToday(
        collectionId,
      );
      final session = await _adhkarRepo!.getSession(collectionId);

      if (mounted) {
        setState(() {
          _isCompletedToday = isCompleted;
          if (session != null) {
            _counts.addAll(session.counts);
            final items = _currentItems;
            if (session.lastPageIndex > 0 &&
                session.lastPageIndex < items.length) {
              _currentPageIndex = session.lastPageIndex;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _pageController.hasClients) {
                  _pageController.jumpToPage(_currentPageIndex);
                }
              });
            }
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<DhikrItem> get _currentItems {
    if (_isBookmarksView) {
      return _bookmarkedIds
          .map((id) => AdhkarCatalog.getById(id))
          .whereType<DhikrItem>()
          .toList();
    }
    return AdhkarCatalog.getByCategory(_selectedCategory);
  }

  void _onCategorySelected(DhikrCategory category) {
    if (!_isBookmarksView && _selectedCategory == category) return;
    AppHaptics.selectionClick();
    setState(() {
      _isBookmarksView = false;
      _selectedCategory = category;
      _currentPageIndex = 0;
      _categoryVersion++;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    _loadSessionForCollection(category.name);
  }

  void _onBookmarksSelected() {
    if (_isBookmarksView) return;
    AppHaptics.selectionClick();
    setState(() {
      _isBookmarksView = true;
      _currentPageIndex = 0;
      _categoryVersion++;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  Future<void> _toggleBookmark(DhikrItem item) async {
    AppHaptics.selectionClick();
    final wasBookmarked = _bookmarkedIds.contains(item.id);
    setState(() {
      if (wasBookmarked) {
        _bookmarkedIds.remove(item.id);
      } else {
        _bookmarkedIds.add(item.id);
      }
    });

    try {
      if (_adhkarRepo != null) {
        await _adhkarRepo!.toggleBookmark(item.id);
      }
    } catch (_) {}
  }

  Future<void> _toggleTransliteration() async {
    AppHaptics.lightImpact();
    final next = !_showTransliteration;
    setState(() {
      _showTransliteration = next;
    });
    try {
      await _settingsService?.setAdhkarTransliterationEnabled(next);
    } catch (_) {}
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

    final items = _currentItems;
    final isCollectionCompleted =
        items.isNotEmpty &&
        items.every((i) => (_counts[i.id] ?? 0) >= i.targetCount);

    if (!_isBookmarksView && _adhkarRepo != null) {
      try {
        if (isCollectionCompleted && !_isCompletedToday) {
          await _adhkarRepo!.recordCollectionCompletion(_selectedCategory.name);
          if (mounted) setState(() => _isCompletedToday = true);
        }
        await _adhkarRepo!.saveSession(
          collectionId: _selectedCategory.name,
          lastPageIndex: _currentPageIndex,
          counts: _counts,
          isCompleted: isCollectionCompleted,
        );
      } catch (_) {}
    }

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
      if (!_isBookmarksView && _adhkarRepo != null) {
        await _adhkarRepo!.saveSession(
          collectionId: _selectedCategory.name,
          lastPageIndex: _currentPageIndex,
          counts: _counts,
          isCompleted: false,
        );
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
      _currentPageIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    try {
      if (getIt.isRegistered<AdhkarService>()) {
        await getIt<AdhkarService>().resetCategory(category);
      }
      if (_adhkarRepo != null) {
        await _adhkarRepo!.saveSession(
          collectionId: category.name,
          lastPageIndex: 0,
          counts: {},
          isCompleted: false,
        );
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
    final hasParentScaffold = Scaffold.maybeOf(context) != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: hasParentScaffold
          ? null
          : ProductiveAppBar(
              title: l10n.adhkarTitle,
              subtitle: l10n.adhkarSubtitle,
              showBackButton: true,
              actions: [
                ProductiveAppBarAction(
                  tooltip: l10n.adhkarToggleTransliteration,
                  icon: _showTransliteration
                      ? Icons.subtitles_rounded
                      : Icons.subtitles_off_rounded,
                  onTap: _toggleTransliteration,
                ),
                if (items.isNotEmpty) ...[
                  ProductiveAppBarAction(
                    tooltip: l10n.typographyTooltip,
                    icon: Icons.format_size_rounded,
                    onTap: _showTypographySheet,
                  ),
                  if (!_isBookmarksView)
                    ProductiveAppBarAction(
                      tooltip: l10n.adhkarResetCategory,
                      icon: Icons.restart_alt_rounded,
                      onTap: () => _resetCategory(_selectedCategory),
                    ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
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
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
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
                  selectedCategory: _isBookmarksView ? null : _selectedCategory,
                  isBookmarksSelected: _isBookmarksView,
                  onCategorySelected: _onCategorySelected,
                  onBookmarksSelected: _onBookmarksSelected,
                  l10n: l10n,
                  isDark: isDark,
                ),
                if (hasParentScaffold || _isCompletedToday)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (items.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.primaryLight.withValues(
                                            alpha: 0.16,
                                          )
                                        : AppColors.primary.withValues(
                                            alpha: 0.08,
                                          ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.primaryLight.withValues(
                                              alpha: 0.3,
                                            )
                                          : AppColors.primary.withValues(
                                              alpha: 0.2,
                                            ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    isAr
                                        ? '${_toArabicDigits('${_currentPageIndex + 1}')} / ${_toArabicDigits('${items.length}')}'
                                        : '${_currentPageIndex + 1} / ${items.length}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              if (_isCompletedToday && !_isBookmarksView)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: isDark ? 0.2 : 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.4),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 13,
                                        color: Color(0xFF10B981),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.adhkarCompletedToday,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (hasParentScaffold)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: l10n.adhkarToggleTransliteration,
                                icon: Icon(
                                  _showTransliteration
                                      ? Icons.subtitles_rounded
                                      : Icons.subtitles_off_rounded,
                                  size: 20,
                                ),
                                onPressed: _toggleTransliteration,
                              ),
                              IconButton(
                                tooltip: l10n.typographyTooltip,
                                icon: const Icon(
                                  Icons.format_size_rounded,
                                  size: 20,
                                ),
                                onPressed: _showTypographySheet,
                              ),
                              if (!_isBookmarksView)
                                IconButton(
                                  tooltip: l10n.adhkarResetCategory,
                                  icon: const Icon(
                                    Icons.restart_alt_rounded,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _resetCategory(_selectedCategory),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isBookmarksView
                                      ? Icons.bookmark_outline_rounded
                                      : Icons.menu_book_rounded,
                                  size: 48,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  _isBookmarksView
                                      ? l10n.adhkarBookmarksEmpty
                                      : l10n.adhkarEmptyState,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          onPageChanged: (idx) {
                            setState(() => _currentPageIndex = idx);
                            if (!_isBookmarksView && _adhkarRepo != null) {
                              _adhkarRepo!.saveSession(
                                collectionId: _selectedCategory.name,
                                lastPageIndex: idx,
                                counts: _counts,
                                isCompleted: _isCompletedToday,
                              );
                            }
                          },
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final count = _counts[item.id] ?? 0;
                            final isBookmarked = _bookmarkedIds.contains(
                              item.id,
                            );
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
                                isBookmarked: isBookmarked,
                                onToggleBookmark: () => _toggleBookmark(item),
                                showTransliteration: _showTransliteration,
                                onTap: () => _incrementCount(item),
                                onReset: () => _resetCount(item),
                              ),
                            );
                          },
                        ),
                ),
                if (items.isNotEmpty)
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
