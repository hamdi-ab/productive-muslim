import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/router/app_routes.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/theme/arabic_typography.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/services/adhkar_search_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/adhkar_session_record.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_background_atmosphere.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_category_tabs.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _ExploreFilter { all, collections, categories }

/// Fallback repository when DI is unconfigured in standalone widget previews/tests.
class _CatalogFallbackRepository implements AdhkarRepository {
  @override
  List<DhikrItem> getAll({bool? includePendingReview}) {
    if (includePendingReview == true) {
      return AdhkarCatalog.all;
    }
    return AdhkarCatalog.all.where((d) => d.isApproved).toList();
  }

  @override
  List<DhikrItem> getByCategory(
    DhikrCategory category, {
    bool? includePendingReview,
  }) => AdhkarCatalog.getByCategory(
    category,
    includePendingReview: includePendingReview ?? false,
  );

  @override
  List<DhikrItem> getBySubject(
    DhikrSubject subject, {
    bool? includePendingReview,
  }) => AdhkarCatalog.getBySubject(
    subject,
    includePendingReview: includePendingReview ?? false,
  );

  @override
  DhikrItem? getById(String id, {bool? includePendingReview}) =>
      AdhkarCatalog.getById(
        id,
        includePendingReview: includePendingReview ?? false,
      );

  @override
  int get catalogVersion => AdhkarCatalog.catalogVersion;

  @override
  bool get isReviewModeAvailable => !kReleaseMode;

  @override
  bool get isReviewModeEnabled => false;

  @override
  Future<void> setReviewModeEnabled(bool enabled) async {}

  @override
  Future<void> toggleBookmark(String dhikrId) async {}

  @override
  Future<bool> isBookmarked(
    String dhikrId, {
    bool? includePendingReview,
  }) async => false;

  @override
  Future<List<DhikrItem>> getBookmarkedItems({
    bool? includePendingReview,
  }) async => [];

  @override
  Stream<List<String>> watchBookmarkedIds({bool? includePendingReview}) =>
      Stream.value([]);

  @override
  Stream<List<DhikrItem>> watchBookmarkedItems({bool? includePendingReview}) =>
      Stream.value([]);

  @override
  Future<AdhkarSessionRecord?> getSession(String collectionId) async => null;

  @override
  Stream<AdhkarSessionRecord?> watchSession(String collectionId) =>
      Stream.value(null);

  @override
  Future<void> saveSession({
    required String collectionId,
    required int lastPageIndex,
    required Map<String, int> counts,
    bool isCompleted = false,
  }) async {}

  @override
  Future<void> clearSession(String collectionId) async {}

  @override
  Future<int> getCategoryCompletedCount(DhikrCategory category) async => 0;

  @override
  Stream<int> watchCategoryCompletedCount(DhikrCategory category) =>
      Stream.value(0);

  @override
  Future<void> recordCollectionCompletion(
    String collectionId, {
    String? date,
  }) async {}

  @override
  Future<bool> isCollectionCompletedToday(
    String collectionId, {
    String? date,
  }) async => false;

  @override
  Stream<bool> watchIsCollectionCompletedToday(
    String collectionId, {
    String? date,
  }) => Stream.value(false);

  @override
  Future<List<String>> getCompletedCollectionIdsForDate(String date) async =>
      [];

  @override
  Future<void> removeCollectionCompletion(
    String collectionId, {
    String? date,
  }) async {}

  @override
  Future<void> migrateFromSharedPreferencesIfNeeded(
    SharedPreferences prefs,
  ) async {}
}

/// Screen providing offline exploration by collections and subjects, plus
/// fast diacritic-tolerant offline search across the reviewed Adhkar catalog.
class AdhkarExploreScreen extends StatefulWidget {
  final bool? isReviewModeEnabled;

  const AdhkarExploreScreen({super.key, this.isReviewModeEnabled});

  @override
  State<AdhkarExploreScreen> createState() => _AdhkarExploreScreenState();
}

class _AdhkarExploreScreenState extends State<AdhkarExploreScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final TabController _tabController;
  String _query = '';
  _ExploreFilter _activeFilter = _ExploreFilter.all;
  DhikrSubject? _selectedSubject;

  AdhkarRepository? get _adhkarRepo =>
      getIt.isRegistered<AdhkarRepository>() ? getIt<AdhkarRepository>() : null;

  SettingsService? get _settingsService =>
      getIt.isRegistered<SettingsService>() ? getIt<SettingsService>() : null;

  bool get _isReviewMode {
    if (widget.isReviewModeEnabled != null) {
      return widget.isReviewModeEnabled!;
    }
    if (_adhkarRepo != null) {
      return _adhkarRepo!.isReviewModeEnabled;
    }
    if (_settingsService != null) {
      return _settingsService!.adhkarReviewModeEnabled;
    }
    return false;
  }

  AdhkarSearchService get _searchService {
    if (getIt.isRegistered<AdhkarSearchService>()) {
      return getIt<AdhkarSearchService>();
    }
    final repo = _adhkarRepo ?? _CatalogFallbackRepository();
    return AdhkarSearchService(repository: repo);
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      if (value.isNotEmpty) {
        _selectedSubject = null;
      }
    });
  }

  void _clearSearch() {
    AppHaptics.selectionClick();
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedSubject = null;
      _activeFilter = _ExploreFilter.all;
    });
  }

  void _applyPromptChip(String text) {
    AppHaptics.selectionClick();
    _searchController.text = text;
    _onSearchChanged(text);
  }

  void _openReader({required DhikrCategory category, String? itemId}) {
    AppHaptics.selectionClick();
    final extra = <String, dynamic>{
      'category': category,
      if (_isReviewMode) 'reviewMode': true,
    };
    if (itemId != null) {
      extra['itemId'] = itemId;
    }
    context.push(AppRoutes.adhkar, extra: extra);
  }

  List<DhikrSearchResult> _getFilteredSearchResults() {
    final rawResults = _searchService.search(
      query: _query,
      includePendingReview: _isReviewMode,
    );

    switch (_activeFilter) {
      case _ExploreFilter.all:
        return rawResults;
      case _ExploreFilter.collections:
        return rawResults.where((r) {
          return r.item.category == DhikrCategory.morning ||
              r.item.category == DhikrCategory.evening ||
              r.item.category == DhikrCategory.postPrayer ||
              r.item.category == DhikrCategory.sleeping ||
              r.item.category == DhikrCategory.wakingUp ||
              r.item.category == DhikrCategory.general;
        }).toList();
      case _ExploreFilter.categories:
        final allSubjectItemIds = <String>{};
        for (final s in DhikrSubject.values) {
          final info = DhikrSubjectInfo.getBySubject(s);
          if (info != null) allSubjectItemIds.addAll(info.itemIds);
        }
        return rawResults
            .where((r) => allSubjectItemIds.contains(r.item.id))
            .toList();
    }
  }

  int _getCollectionItemCount(DhikrCategory category) {
    if (_adhkarRepo != null) {
      return _adhkarRepo!
          .getByCategory(category, includePendingReview: _isReviewMode)
          .length;
    }
    return AdhkarCatalog.getByCategory(
      category,
      includePendingReview: _isReviewMode,
    ).length;
  }

  int _getSubjectItemCount(DhikrSubject subject) {
    if (_adhkarRepo != null) {
      return _adhkarRepo!
          .getBySubject(subject, includePendingReview: _isReviewMode)
          .length;
    }
    return AdhkarCatalog.getBySubject(
      subject,
      includePendingReview: _isReviewMode,
    ).length;
  }

  List<DhikrItem> _getItemsForSubject(DhikrSubject subject) {
    if (_adhkarRepo != null) {
      return _adhkarRepo!.getBySubject(
        subject,
        includePendingReview: _isReviewMode,
      );
    }
    return AdhkarCatalog.getBySubject(
      subject,
      includePendingReview: _isReviewMode,
    );
  }

  String _getSubjectTitle(DhikrSubject subject, AppLocalizations l10n) {
    switch (subject) {
      case DhikrSubject.gratitude:
        return l10n.adhkarSubjectGratitude;
      case DhikrSubject.forgiveness:
        return l10n.adhkarSubjectForgiveness;
      case DhikrSubject.protection:
        return l10n.adhkarSubjectProtection;
      case DhikrSubject.sleepAndWaking:
        return l10n.adhkarSubjectSleepWaking;
      case DhikrSubject.everyday:
        return l10n.adhkarSubjectEveryday;
    }
  }

  String _getSubjectDesc(DhikrSubject subject, AppLocalizations l10n) {
    switch (subject) {
      case DhikrSubject.gratitude:
        return l10n.adhkarSubjectGratitudeDesc;
      case DhikrSubject.forgiveness:
        return l10n.adhkarSubjectForgivenessDesc;
      case DhikrSubject.protection:
        return l10n.adhkarSubjectProtectionDesc;
      case DhikrSubject.sleepAndWaking:
        return l10n.adhkarSubjectSleepWakingDesc;
      case DhikrSubject.everyday:
        return l10n.adhkarSubjectEverydayDesc;
    }
  }

  IconData _getSubjectIcon(DhikrSubject subject) {
    switch (subject) {
      case DhikrSubject.gratitude:
        return Icons.favorite_border_rounded;
      case DhikrSubject.forgiveness:
        return Icons.water_drop_outlined;
      case DhikrSubject.protection:
        return Icons.shield_outlined;
      case DhikrSubject.sleepAndWaking:
        return Icons.nightlight_outlined;
      case DhikrSubject.everyday:
        return Icons.explore_outlined;
    }
  }

  IconData _getCollectionIcon(DhikrCategory category) {
    switch (category) {
      case DhikrCategory.morning:
        return Icons.wb_sunny_outlined;
      case DhikrCategory.evening:
        return Icons.nights_stay_outlined;
      case DhikrCategory.wakingUp:
        return Icons.alarm_outlined;
      case DhikrCategory.sleeping:
        return Icons.bedtime_outlined;
      case DhikrCategory.postPrayer:
        return Icons.mosque_outlined;
      case DhikrCategory.dailySunnah:
        return Icons.auto_stories_outlined;
      case DhikrCategory.general:
        return Icons.flare_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isSearching = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: ProductiveAppBar(
        title: l10n.adhkarExploreTitle,
        subtitle: l10n.adhkarExploreSubtitle,
        showBackButton: true,
      ),
      body: Stack(
        children: [
          AdhkarBackgroundAtmosphere(isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(l10n, isDark),
                if (!isSearching && _selectedSubject == null) ...[
                  _buildPromptChips(isAr, isDark),
                  _buildDiscoveryTabs(l10n, isDark),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCollectionsView(l10n, isDark, isAr),
                        _buildCategoriesView(l10n, isDark, isAr),
                      ],
                    ),
                  ),
                ] else if (!isSearching && _selectedSubject != null) ...[
                  _buildSubjectDetailHeader(l10n, isDark, isAr),
                  Expanded(
                    child: _buildSubjectItemsList(
                      _selectedSubject!,
                      l10n,
                      isDark,
                      isAr,
                    ),
                  ),
                ] else ...[
                  _buildFilterChips(l10n, isDark),
                  Expanded(child: _buildSearchResultsView(l10n, isDark, isAr)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.8)
            : AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: TextField(
        key: const Key('adhkar_explore_search_input'),
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: l10n.adhkarSearchPlaceholder,
          hintStyle: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
                : AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark ? AppColors.primaryLight : AppColors.primary,
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  key: const Key('adhkar_explore_search_clear'),
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPromptChips(bool isAr, bool isDark) {
    final prompts = isAr
        ? [
            'الصباح',
            'المساء',
            'سيد الاستغفار',
            'آية الكرسي',
            'سبحان الله',
            'الحمد لله',
            'التحصين',
            'النوم',
          ]
        : [
            'Morning',
            'Evening',
            'Sayyid al-Istighfar',
            'Ayat al-Kursi',
            'Subhan Allah',
            'Protection',
            'Forgiveness',
            'Sleep',
          ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      child: Row(
        children: prompts.map((prompt) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: AppPressable(
              key: Key('adhkar_prompt_chip_$prompt'),
              onTap: () => _applyPromptChip(prompt),
              pressedScale: 0.94,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.north_west_rounded,
                      size: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      prompt,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDiscoveryTabs(AppLocalizations l10n, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.12),
          border: Border.all(
            color: isDark
                ? AppColors.secondary.withValues(alpha: 0.5)
                : AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: isDark ? Colors.white : AppColors.primary,
        unselectedLabelColor: isDark
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: [
          Tab(
            key: const Key('adhkar_explore_tab_collections'),
            text: l10n.adhkarSearchCollectionsTab,
            icon: const Icon(Icons.collections_bookmark_outlined, size: 17),
            iconMargin: const EdgeInsets.only(bottom: 2),
          ),
          Tab(
            key: const Key('adhkar_explore_tab_categories'),
            text: l10n.adhkarSearchCategoriesTab,
            icon: const Icon(Icons.category_outlined, size: 17),
            iconMargin: const EdgeInsets.only(bottom: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsView(AppLocalizations l10n, bool isDark, bool isAr) {
    const collections = [
      DhikrCategory.morning,
      DhikrCategory.evening,
      DhikrCategory.postPrayer,
      DhikrCategory.sleeping,
      DhikrCategory.wakingUp,
      DhikrCategory.general,
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final cat = collections[index];
        final count = _getCollectionItemCount(cat);
        final title = AdhkarCategoryTabs.getCategoryLabel(cat, l10n);
        final icon = _getCollectionIcon(cat);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppPressable(
            key: Key('adhkar_collection_card_${cat.name}'),
            onTap: () => _openReader(category: cat),
            pressedScale: 0.98,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.8)
                    : AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.adhkarItemsCount(count),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isAr
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                        : AppColors.textSecondary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesView(AppLocalizations l10n, bool isDark, bool isAr) {
    const subjects = DhikrSubject.values;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final count = _getSubjectItemCount(subject);
        final title = _getSubjectTitle(subject, l10n);
        final desc = _getSubjectDesc(subject, l10n);
        final icon = _getSubjectIcon(subject);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppPressable(
            key: Key('adhkar_category_card_${subject.name}'),
            onTap: () {
              AppHaptics.selectionClick();
              setState(() => _selectedSubject = subject);
            },
            pressedScale: 0.98,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.8)
                    : AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.secondary.withValues(alpha: 0.2)
                          : AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isDark
                          ? AppColors.secondary
                          : AppColors.secondaryDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          desc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.adhkarItemsCount(count),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isAr
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                        : AppColors.textSecondary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectDetailHeader(
    AppLocalizations l10n,
    bool isDark,
    bool isAr,
  ) {
    final title = _getSubjectTitle(_selectedSubject!, l10n);
    final desc = _getSubjectDesc(_selectedSubject!, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('adhkar_explore_back_to_subjects'),
            icon: Icon(
              isAr ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
              size: 20,
            ),
            onPressed: () {
              AppHaptics.selectionClick();
              setState(() => _selectedSubject = null);
            },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectItemsList(
    DhikrSubject subject,
    AppLocalizations l10n,
    bool isDark,
    bool isAr,
  ) {
    final items = _getItemsForSubject(subject);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildDhikrItemCard(item, l10n, isDark, isAr);
      },
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      child: Row(
        children: [
          _buildFilterChip(
            label: l10n.adhkarFilterAll,
            filter: _ExploreFilter.all,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.adhkarFilterCollections,
            filter: _ExploreFilter.collections,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.adhkarFilterCategories,
            filter: _ExploreFilter.categories,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required _ExploreFilter filter,
    required bool isDark,
  }) {
    final isSelected = _activeFilter == filter;
    return AppPressable(
      onTap: () {
        AppHaptics.selectionClick();
        setState(() => _activeFilter = filter);
      },
      pressedScale: 0.95,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.primary.withValues(alpha: 0.12))
              : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark
                      ? AppColors.secondary.withValues(alpha: 0.6)
                      : AppColors.primary.withValues(alpha: 0.4))
                : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06)),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : AppColors.primary)
                : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsView(
    AppLocalizations l10n,
    bool isDark,
    bool isAr,
  ) {
    final results = _getFilteredSearchResults();

    if (results.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.4)
                    : AppColors.textSecondary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.adhkarSearchNoResultsTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.adhkarSearchNoResultsDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                key: const Key('adhkar_explore_no_results_clear_button'),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(l10n.adhkarSearchClear),
                onPressed: _clearSearch,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 4,
          ),
          child: Text(
            l10n.adhkarSearchResultsCount(results.length),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return _buildDhikrItemCard(
                result.item,
                l10n,
                isDark,
                isAr,
                matchedField: result.matchedField,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDhikrItemCard(
    DhikrItem item,
    AppLocalizations l10n,
    bool isDark,
    bool isAr, {
    String? matchedField,
  }) {
    final collectionLabel = AdhkarCategoryTabs.getCategoryLabel(
      item.category,
      l10n,
    );
    final title = isAr ? item.titleAr : item.titleEn;
    final translation = isAr ? item.translationAr : item.translationEn;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppPressable(
        key: Key('adhkar_result_card_${item.id}'),
        onTap: () => _openReader(category: item.category, itemId: item.id),
        pressedScale: 0.98,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.8)
                : AppColors.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      collectionLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  if (item.targetCount > 1) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.targetCount}×',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.secondary
                              : AppColors.secondaryDark,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    isAr
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                        : AppColors.textSecondary.withValues(alpha: 0.6),
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Arabic Sacred Text Snippet
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  item.arabic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: ArabicFontFamily.amiri.getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Title / Transliteration
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              // Translation Snippet
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      translation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
              // Reference Badge
              if (item.reference.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '📖 ${item.reference}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? AppColors.darkTextSecondary.withValues(
                                  alpha: 0.7,
                                )
                              : AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
