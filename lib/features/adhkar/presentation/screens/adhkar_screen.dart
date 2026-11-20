import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/home_widget_sync_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/adhkar_routine.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_background_atmosphere.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_category_tabs.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_collection_completion_card.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_library_picker_sheet.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_my_routines_section.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_retired_item_card.dart';
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
  final String? initialItemId;
  final String? initialRoutineId;
  final bool? isReviewModeEnabled;
  final bool? isInternalReviewAvailable;

  const AdhkarScreen({
    super.key,
    this.initialCategory = DhikrCategory.morning,
    this.initialItemId,
    this.initialRoutineId,
    this.isReviewModeEnabled,
    this.isInternalReviewAvailable,
  });

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  late DhikrCategory _selectedCategory;
  bool _isBookmarksView = false;
  bool _isRoutinesView = false;
  AdhkarRoutine? _activeRoutine;
  late PageController _pageController;
  int _currentPageIndex = 0;
  final Map<String, int> _counts = {};
  final Set<String> _skippedItemIds = {};

  final Set<String> _bookmarkedIds = {};
  bool _showTransliteration = false;
  bool _isCompletedToday = false;
  bool _isReviewMode = false;

  AdhkarRepository? get _adhkarRepo =>
      getIt.isRegistered<AdhkarRepository>() ? getIt<AdhkarRepository>() : null;

  SettingsService? get _settingsService =>
      getIt.isRegistered<SettingsService>() ? getIt<SettingsService>() : null;

  bool get _isInternalReviewAvailable {
    if (widget.isInternalReviewAvailable != null) {
      return widget.isInternalReviewAvailable!;
    }
    if (widget.isReviewModeEnabled != null) {
      return true;
    }
    if (_adhkarRepo != null) {
      return _adhkarRepo!.isReviewModeAvailable;
    }
    if (_settingsService != null) {
      return _settingsService!.isAdhkarReviewModeAvailable;
    }
    return !kReleaseMode;
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _showTransliteration =
        _settingsService?.adhkarTransliterationEnabled ?? false;
    _isReviewMode =
        _isInternalReviewAvailable &&
        (widget.isReviewModeEnabled ??
            (_adhkarRepo?.isReviewModeEnabled ??
                _settingsService?.adhkarReviewModeEnabled ??
                false));

    int initialPage = 0;
    if (widget.initialItemId != null) {
      final items = _adhkarRepo != null
          ? _adhkarRepo!.getByCategory(
              widget.initialCategory,
              includePendingReview: _isReviewMode,
            )
          : AdhkarCatalog.getByCategory(
              widget.initialCategory,
              includePendingReview: _isReviewMode,
            );
      final idx = items.indexWhere((i) => i.id == widget.initialItemId);
      if (idx >= 0) {
        initialPage = idx;
      }
    }
    _currentPageIndex = initialPage;
    _pageController = PageController(initialPage: initialPage);

    _initData();
  }

  Future<void> _toggleReviewMode() async {
    if (!_isInternalReviewAvailable) return;
    AppHaptics.selectionClick();
    final next = !_isReviewMode;
    setState(() {
      _isReviewMode = next;
      _currentPageIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    try {
      await _adhkarRepo?.setReviewModeEnabled(next);
      await _settingsService?.setAdhkarReviewModeEnabled(next);
    } catch (_) {}
    await _loadBookmarks();
    final targetColId = _activeRoutine != null
        ? 'routine_${_activeRoutine!.id}'
        : _selectedCategory.name;
    _loadSessionForCollection(targetColId);
  }

  Future<void> _initData() async {
    if (_adhkarRepo == null) {
      _loadLegacySavedCounts();
    }
    await _loadBookmarks();
    if (widget.initialRoutineId != null && _adhkarRepo != null) {
      final routine = await _adhkarRepo!.getRoutineById(
        widget.initialRoutineId!,
      );
      if (routine != null && mounted) {
        setState(() {
          _activeRoutine = routine;
          _isRoutinesView = false;
          _isBookmarksView = false;
          _counts.clear();
          _skippedItemIds.clear();
        });
        await _loadSessionForCollection('routine_${routine.id}');
        return;
      }
    }
    await _loadSessionForCollection(_selectedCategory.name);
  }

  Future<void> _loadBookmarks() async {
    if (_adhkarRepo != null) {
      try {
        final bookmarks = await _adhkarRepo!.getBookmarkedItems(
          includePendingReview: _isReviewMode,
        );
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
      final isCompleted = _activeRoutine != null
          ? await _adhkarRepo!.isRoutineCompletedToday(_activeRoutine!.id)
          : await _adhkarRepo!.isCollectionCompletedToday(collectionId);
      final session = await _adhkarRepo!.getSession(collectionId);

      if (mounted) {
        setState(() {
          _isCompletedToday = isCompleted;
          _counts.clear();
          _skippedItemIds.clear();
          if (session != null) {
            _counts.addAll(session.counts);
            _skippedItemIds.addAll(session.skippedItemIds);
          }
          final items = _currentItems;
          int targetIndex = -1;
          if (widget.initialItemId != null) {
            targetIndex = items.indexWhere((i) => i.id == widget.initialItemId);
          }
          final maxLen = _activeRoutine != null
              ? _activeRoutine!.itemIds.length
              : items.length;
          if (targetIndex >= 0) {
            _currentPageIndex = targetIndex;
          } else if (session != null &&
              session.lastPageIndex > 0 &&
              session.lastPageIndex < maxLen) {
            _currentPageIndex = session.lastPageIndex;
          } else {
            _currentPageIndex = 0;
          }

          if (_currentPageIndex > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _pageController.hasClients) {
                _pageController.jumpToPage(_currentPageIndex);
              }
            });
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
    if (_activeRoutine != null) {
      final items = <DhikrItem>[];
      for (final id in _activeRoutine!.itemIds) {
        final item =
            _adhkarRepo?.getById(id, includePendingReview: _isReviewMode) ??
            AdhkarCatalog.getById(id, includePendingReview: _isReviewMode);
        if (item != null && (_isReviewMode || item.isApproved)) {
          items.add(item);
        }
      }
      return items;
    }
    if (_isBookmarksView) {
      return _bookmarkedIds
          .map(
            (id) =>
                _adhkarRepo?.getById(id, includePendingReview: _isReviewMode) ??
                AdhkarCatalog.getById(id, includePendingReview: _isReviewMode),
          )
          .whereType<DhikrItem>()
          .where((d) => _isReviewMode || d.isApproved)
          .toList();
    }
    if (_adhkarRepo != null) {
      return _adhkarRepo!.getByCategory(
        _selectedCategory,
        includePendingReview: _isReviewMode,
      );
    }
    return AdhkarCatalog.getByCategory(
      _selectedCategory,
      includePendingReview: _isReviewMode,
    );
  }

  void _onCategorySelected(DhikrCategory category) {
    if (!_isBookmarksView &&
        !_isRoutinesView &&
        _activeRoutine == null &&
        _selectedCategory == category) {
      return;
    }
    AppHaptics.selectionClick();
    setState(() {
      _isBookmarksView = false;
      _isRoutinesView = false;
      _activeRoutine = null;
      _selectedCategory = category;
      _currentPageIndex = 0;
      _counts.clear();
      _skippedItemIds.clear();
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    _loadSessionForCollection(category.name);
  }

  void _onBookmarksSelected() {
    if (_isBookmarksView && _activeRoutine == null) return;
    AppHaptics.selectionClick();
    setState(() {
      _isBookmarksView = true;
      _isRoutinesView = false;
      _activeRoutine = null;
      _currentPageIndex = 0;
      _counts.clear();
      _skippedItemIds.clear();
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _onRoutinesSelected() {
    if (_isRoutinesView && _activeRoutine == null) return;
    AppHaptics.selectionClick();
    setState(() {
      _isRoutinesView = true;
      _isBookmarksView = false;
      _activeRoutine = null;
      _currentPageIndex = 0;
      _counts.clear();
      _skippedItemIds.clear();
    });
  }

  Future<void> _startRoutine(AdhkarRoutine routine) async {
    AppHaptics.selectionClick();
    setState(() {
      _activeRoutine = routine;
      _isRoutinesView = false;
      _isBookmarksView = false;
      _currentPageIndex = 0;
      _counts.clear();
      _skippedItemIds.clear();
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    await _loadSessionForCollection('routine_${routine.id}');
  }

  void _exitActiveRoutine() {
    AppHaptics.selectionClick();
    setState(() {
      _activeRoutine = null;
      _isRoutinesView = true;
      _currentPageIndex = 0;
      _counts.clear();
      _skippedItemIds.clear();
    });
  }

  Future<void> _resetRoutine(AdhkarRoutine routine) async {
    setState(() {
      _counts.clear();
      _skippedItemIds.clear();
      _currentPageIndex = 0;
      _isCompletedToday = false;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    if (_adhkarRepo != null) {
      await _adhkarRepo!.clearSession('routine_${routine.id}');
    }
  }

  void _replaceRetiredItem(String oldId) {
    AppHaptics.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AdhkarLibraryPickerSheet(
        alreadySelectedIds: _activeRoutine?.itemIds.toSet() ?? {},
        onItemSelected: (newItem) async {
          if (_activeRoutine == null) return;
          final currentIds = List<String>.from(_activeRoutine!.itemIds);
          final oldIdx = currentIds.indexOf(oldId);
          if (oldIdx != -1) {
            currentIds[oldIdx] = newItem.id;
          } else {
            currentIds.add(newItem.id);
          }
          final updated = _activeRoutine!.copyWith(
            itemIds: currentIds,
            updatedAt: DateTime.now(),
          );
          if (_adhkarRepo != null) {
            await _adhkarRepo!.updateRoutineWithProgressPreservation(updated);
          }
          if (mounted) {
            setState(() {
              _activeRoutine = updated;
            });
          }
        },
      ),
    );
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

  bool _isRoutineCompleted(AdhkarRoutine routine) {
    if (routine.itemIds.isEmpty) return false;
    final approved = <DhikrItem>[];
    final retiredIds = <String>[];
    for (final id in routine.itemIds) {
      final d =
          _adhkarRepo?.getById(id, includePendingReview: _isReviewMode) ??
          AdhkarCatalog.getById(id, includePendingReview: _isReviewMode);
      if (d != null && (_isReviewMode || d.isApproved)) {
        approved.add(d);
      } else {
        retiredIds.add(id);
      }
    }
    if (approved.isEmpty) return false;
    final approvedDone = approved.every(
      (item) => (_counts[item.id] ?? 0) >= item.targetCount,
    );
    if (!approvedDone) return false;
    return retiredIds.every(
      (id) =>
          _skippedItemIds.contains(id) || routine.retiredItemIds.contains(id),
    );
  }

  Future<void> _skipRetiredItem(String itemId) async {
    if (_activeRoutine == null) return;
    AppHaptics.selectionClick();
    setState(() {
      _skippedItemIds.add(itemId);
    });

    final routine = _activeRoutine!;
    final isRoutineCompleted = _isRoutineCompleted(routine);

    if (_adhkarRepo != null) {
      try {
        if (isRoutineCompleted && !_isCompletedToday) {
          await _adhkarRepo!.recordRoutineCompletion(
            routineId: routine.id,
            routineName: routine.name,
          );
          if (mounted) setState(() => _isCompletedToday = true);
        }
        await _adhkarRepo!.saveSession(
          collectionId: 'routine_${routine.id}',
          lastPageIndex: _currentPageIndex,
          counts: _counts,
          skippedItemIds: _skippedItemIds.toList(),
          isCompleted: isRoutineCompleted,
        );
      } catch (_) {}
    }

    if (!mounted) return;

    final routineLen = routine.itemIds.length;
    final totalPageCount = isRoutineCompleted ? routineLen + 1 : routineLen;
    if (_currentPageIndex < totalPageCount - 1 && _pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _incrementCount(DhikrItem item) async {
    final current = _counts[item.id] ?? 0;
    if (current >= item.targetCount) return;

    final next = current + 1;
    setState(() {
      _counts[item.id] = next;
    });

    if (_activeRoutine != null) {
      final routine = _activeRoutine!;
      final isRoutineCompleted = _isRoutineCompleted(routine);

      if (_adhkarRepo != null) {
        try {
          if (isRoutineCompleted && !_isCompletedToday) {
            await _adhkarRepo!.recordRoutineCompletion(
              routineId: routine.id,
              routineName: routine.name,
            );
            if (mounted) setState(() => _isCompletedToday = true);
          }
          await _adhkarRepo!.saveSession(
            collectionId: 'routine_${routine.id}',
            lastPageIndex: _currentPageIndex,
            counts: _counts,
            skippedItemIds: _skippedItemIds.toList(),
            isCompleted: isRoutineCompleted,
          );
        } catch (_) {}
      }

      if (next == item.targetCount) {
        AppHaptics.heavyImpact();
      } else if (next == 33 || next == 66) {
        AppHaptics.mediumImpact();
      } else {
        AppHaptics.lightImpact();
      }
      return;
    }

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
      if (getIt.isRegistered<HomeWidgetSyncService>()) {
        try {
          final completedCount = _counts.entries.where((entry) {
            final d =
                _adhkarRepo?.getById(
                  entry.key,
                  includePendingReview: _isReviewMode,
                ) ??
                AdhkarCatalog.getById(
                  entry.key,
                  includePendingReview: _isReviewMode,
                );
            return d != null && entry.value >= d.targetCount;
          }).length;
          getIt<HomeWidgetSyncService>().syncDhikrCount(completedCount);
        } catch (_) {}
      }
      // Calm reading: do NOT force auto-advance to next item.
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
      if (_activeRoutine != null && _adhkarRepo != null) {
        await _adhkarRepo!.saveSession(
          collectionId: 'routine_${_activeRoutine!.id}',
          lastPageIndex: _currentPageIndex,
          counts: _counts,
          skippedItemIds: _skippedItemIds.toList(),
          isCompleted: false,
        );
      } else if (!_isBookmarksView && _adhkarRepo != null) {
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
    setState(() {
      _counts.clear();
      _skippedItemIds.clear();
      _currentPageIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    try {
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

  Future<void> _readAgain() async {
    AppHaptics.mediumImpact();
    setState(() {
      _counts.clear();
      _skippedItemIds.clear();
      _currentPageIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    try {
      if (!_isBookmarksView && _adhkarRepo != null) {
        await _adhkarRepo!.saveSession(
          collectionId: _selectedCategory.name,
          lastPageIndex: 0,
          counts: _counts,
          isCompleted: false,
        );
        // Note: Retains daily completion record in AdhkarCompletions
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

    final isRoutineMode = _activeRoutine != null;
    final routineLen = _activeRoutine?.itemIds.length ?? 0;
    final isCollectionCompleted = isRoutineMode
        ? _isRoutineCompleted(_activeRoutine!)
        : (items.isNotEmpty &&
              items.every((i) => (_counts[i.id] ?? 0) >= i.targetCount));

    final hasCompletionCard =
        isCollectionCompleted && (!_isBookmarksView || isRoutineMode);
    final totalPageCount = hasCompletionCard
        ? (isRoutineMode ? routineLen + 1 : items.length + 1)
        : (isRoutineMode ? routineLen : items.length);

    final String pageLabel;
    final effectiveTotal = isRoutineMode ? routineLen : items.length;
    if (_currentPageIndex >= effectiveTotal && hasCompletionCard) {
      pageLabel = isAr ? 'اكتمل' : 'Completed';
    } else {
      pageLabel = isAr
          ? '${_toArabicDigits('${_currentPageIndex + 1}')} / ${_toArabicDigits('$effectiveTotal')}'
          : '${_currentPageIndex + 1} / $effectiveTotal';
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: isRoutineMode
          ? ProductiveAppBar(
              title: _activeRoutine!.name,
              subtitle: l10n.adhkarRoutinePersonalTag,
              showBackButton: true,
              onBackPressed: _exitActiveRoutine,
              actions: [
                ProductiveAppBarAction(
                  tooltip: l10n.adhkarToggleTransliteration,
                  icon: _showTransliteration
                      ? Icons.subtitles_rounded
                      : Icons.subtitles_off_rounded,
                  onTap: _toggleTransliteration,
                ),
                ProductiveAppBarAction(
                  tooltip: l10n.typographyTooltip,
                  icon: Icons.format_size_rounded,
                  onTap: _showTypographySheet,
                ),
                ProductiveAppBarAction(
                  tooltip: l10n.adhkarReset,
                  icon: Icons.restart_alt_rounded,
                  onTap: () => _resetRoutine(_activeRoutine!),
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
                      pageLabel,
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
            )
          : (hasParentScaffold
                ? null
                : ProductiveAppBar(
                    title: l10n.adhkarTitle,
                    subtitle: l10n.adhkarSubtitle,
                    showBackButton: true,
                    actions: [
                      if (_isInternalReviewAvailable)
                        ProductiveAppBarAction(
                          tooltip: _isReviewMode
                              ? l10n.adhkarDisableReviewMode
                              : l10n.adhkarEditorialReviewMode,
                          icon: _isReviewMode
                              ? Icons.rate_review_rounded
                              : Icons.rate_review_outlined,
                          onTap: _toggleReviewMode,
                        ),
                      ProductiveAppBarAction(
                        tooltip: l10n.adhkarExploreTitle,
                        icon: Icons.explore_outlined,
                        onTap: () => context.push(AppRoutes.adhkarExplore),
                      ),
                      ProductiveAppBarAction(
                        key: const Key('adhkar_tasbih_app_bar_action'),
                        tooltip: l10n.tasbihTitle,
                        icon: Icons.fingerprint_rounded,
                        onTap: () => context.push(AppRoutes.adhkarTasbih),
                      ),
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
                                  ? AppColors.primaryLight.withValues(
                                      alpha: 0.3,
                                    )
                                  : AppColors.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              pageLabel,
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
                  )),
      body: Stack(
        children: [
          AdhkarBackgroundAtmosphere(isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                if (!isRoutineMode)
                  AdhkarCategoryTabs(
                    selectedCategory: (_isBookmarksView || _isRoutinesView)
                        ? null
                        : _selectedCategory,
                    isBookmarksSelected: _isBookmarksView,
                    isRoutinesSelected: _isRoutinesView,
                    onCategorySelected: _onCategorySelected,
                    onBookmarksSelected: _onBookmarksSelected,
                    onRoutinesSelected: _onRoutinesSelected,
                    onExploreTap: () => context.push(AppRoutes.adhkarExplore),
                    onTasbihTap: () => context.push(AppRoutes.adhkarTasbih),
                    l10n: l10n,
                    isDark: isDark,
                  ),
                if (_isRoutinesView && !isRoutineMode)
                  Expanded(
                    child: AdhkarMyRoutinesSection(
                      onStartRoutine: _startRoutine,
                    ),
                  )
                else ...[
                  if (_isReviewMode)
                    Container(
                      key: const Key('adhkar_review_mode_banner'),
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(
                          alpha: isDark ? 0.2 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.rate_review_rounded,
                            size: 16,
                            color: isDark
                                ? const Color(0xFFFCD34D)
                                : const Color(0xFFB45309),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.adhkarReviewModeBanner,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFFCD34D)
                                    : const Color(0xFFB45309),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: l10n.adhkarDisableReviewMode,
                            onPressed: _toggleReviewMode,
                          ),
                        ],
                      ),
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
                                      pageLabel,
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
                                  GestureDetector(
                                    onTap: () {
                                      if (hasCompletionCard &&
                                          _pageController.hasClients) {
                                        _pageController.jumpToPage(
                                          items.length,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withValues(
                                              alpha: isDark ? 0.2 : 0.12,
                                            ),
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
                                  ),
                              ],
                            ),
                          ),
                          if (hasParentScaffold)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isInternalReviewAvailable)
                                  IconButton(
                                    key: const Key(
                                      'adhkar_review_mode_toggle_shell',
                                    ),
                                    tooltip: _isReviewMode
                                        ? l10n.adhkarDisableReviewMode
                                        : l10n.adhkarEditorialReviewMode,
                                    icon: Icon(
                                      _isReviewMode
                                          ? Icons.rate_review_rounded
                                          : Icons.rate_review_outlined,
                                      size: 20,
                                      color: _isReviewMode
                                          ? (isDark
                                                ? const Color(0xFFFCD34D)
                                                : const Color(0xFFD97706))
                                          : null,
                                    ),
                                    onPressed: _toggleReviewMode,
                                  ),
                                IconButton(
                                  tooltip: l10n.adhkarToggleTransliteration,
                                  icon: Icon(
                                    _showTransliteration
                                        ? Icons.subtitles_rounded
                                        : Icons.subtitles_off_rounded,
                                    size: 20,
                                    color: _showTransliteration
                                        ? (isDark
                                              ? AppColors.primaryLight
                                              : AppColors.primary)
                                        : null,
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
                    child: (items.isEmpty && !isRoutineMode)
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isBookmarksView
                                        ? Icons.bookmark_outline_rounded
                                        : (!_isReviewMode
                                              ? Icons.hourglass_top_rounded
                                              : Icons.menu_book_rounded),
                                    size: 48,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    _isBookmarksView
                                        ? l10n.adhkarBookmarksEmpty
                                        : (!_isReviewMode
                                              ? l10n.adhkarContentUnderReview
                                              : l10n.adhkarEmptyState),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                  if (!_isBookmarksView && !_isReviewMode) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      l10n.adhkarContentUnderReviewDesc,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.4,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    if (_isInternalReviewAvailable) ...[
                                      const SizedBox(height: AppSpacing.md),
                                      OutlinedButton.icon(
                                        key: const Key(
                                          'adhkar_enable_review_mode_button',
                                        ),
                                        onPressed: _toggleReviewMode,
                                        icon: const Icon(
                                          Icons.preview_rounded,
                                          size: 16,
                                        ),
                                        label: Text(
                                          l10n.adhkarEnableReviewMode,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: isDark
                                              ? AppColors.secondary
                                              : AppColors.secondaryDark,
                                          side: BorderSide(
                                            color: AppColors.secondary
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          )
                        : PageView.builder(
                            controller: _pageController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: totalPageCount,
                            onPageChanged: (idx) {
                              setState(() => _currentPageIndex = idx);
                              if (isRoutineMode && _adhkarRepo != null) {
                                _adhkarRepo!.saveSession(
                                  collectionId: 'routine_${_activeRoutine!.id}',
                                  lastPageIndex: idx < routineLen
                                      ? idx
                                      : routineLen - 1,
                                  counts: _counts,
                                  skippedItemIds: _skippedItemIds.toList(),
                                  isCompleted: isCollectionCompleted,
                                );
                              } else if (!_isBookmarksView &&
                                  _adhkarRepo != null) {
                                _adhkarRepo!.saveSession(
                                  collectionId: _selectedCategory.name,
                                  lastPageIndex: idx < items.length
                                      ? idx
                                      : items.length - 1,
                                  counts: _counts,
                                  isCompleted: isCollectionCompleted,
                                );
                              }
                            },
                            itemBuilder: (context, index) {
                              if (index ==
                                      (isRoutineMode
                                          ? routineLen
                                          : items.length) &&
                                  hasCompletionCard) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  child: AdhkarCollectionCompletionCard(
                                    category: isRoutineMode
                                        ? DhikrCategory.general
                                        : _selectedCategory,
                                    items: items,
                                    description: isRoutineMode
                                        ? l10n.adhkarRoutineCompletedDesc
                                        : null,
                                    onDone: isRoutineMode
                                        ? _exitActiveRoutine
                                        : () {
                                            if (Navigator.canPop(context)) {
                                              Navigator.maybePop(context);
                                            } else {
                                              _pageController.jumpToPage(0);
                                            }
                                          },
                                    onReadAgain: isRoutineMode
                                        ? () => _resetRoutine(_activeRoutine!)
                                        : _readAgain,
                                  ),
                                );
                              }

                              if (isRoutineMode) {
                                final itemId = _activeRoutine!.itemIds[index];
                                final item =
                                    _adhkarRepo?.getById(
                                      itemId,
                                      includePendingReview: _isReviewMode,
                                    ) ??
                                    AdhkarCatalog.getById(
                                      itemId,
                                      includePendingReview: _isReviewMode,
                                    );

                                if (item == null ||
                                    (!_isReviewMode && !item.isApproved)) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.xs,
                                    ),
                                    child: AdhkarRetiredItemCard(
                                      itemId: itemId,
                                      onSkip: () => _skipRetiredItem(itemId),
                                      onReplace: () =>
                                          _replaceRetiredItem(itemId),
                                      onExit: _exitActiveRoutine,
                                    ),
                                  );
                                }

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
                                    total: routineLen,
                                    isBookmarked: isBookmarked,
                                    onToggleBookmark: () =>
                                        _toggleBookmark(item),
                                    showTransliteration: _showTransliteration,
                                    onTap: () => _incrementCount(item),
                                    onReset: () => _resetCount(item),
                                  ),
                                );
                              }

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
                  if (items.isNotEmpty || isRoutineMode)
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
                      onNext: _currentPageIndex < totalPageCount - 1
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
