import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/local/daos/adhkar_dao.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/adhkar_session_record.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';

class AdhkarRepositoryImpl implements AdhkarRepository {
  final AdhkarDao _adhkarDao;
  final SettingsService? _settingsService;
  final SharedPreferences? _prefs;

  AdhkarRepositoryImpl({
    required AdhkarDao adhkarDao,
    SharedPreferences? prefs,
    SettingsService? settingsService,
  }) : _adhkarDao = adhkarDao,
       _settingsService = settingsService,
       _prefs = prefs ?? settingsService?.prefs {
    final effectivePrefs = _prefs;
    if (effectivePrefs != null) {
      migrateFromSharedPreferencesIfNeeded(effectivePrefs);
    }
  }

  bool _adhkarReviewModeFallback = false;

  @override
  bool get isReviewModeAvailable =>
      _settingsService?.isAdhkarReviewModeAvailable ?? !kReleaseMode;

  @override
  bool get isReviewModeEnabled =>
      isReviewModeAvailable &&
      (_settingsService?.adhkarReviewModeEnabled ?? _adhkarReviewModeFallback);

  @override
  Future<void> setReviewModeEnabled(bool enabled) async {
    if (!isReviewModeAvailable) {
      _adhkarReviewModeFallback = false;
      return;
    }
    _adhkarReviewModeFallback = enabled;
    await _settingsService?.setAdhkarReviewModeEnabled(enabled);
  }

  @override
  List<DhikrItem> getAll({bool? includePendingReview}) {
    final include = includePendingReview ?? isReviewModeEnabled;
    return include
        ? AdhkarCatalog.all
        : AdhkarCatalog.all.where((d) => d.isApproved).toList();
  }

  @override
  List<DhikrItem> getByCategory(
    DhikrCategory category, {
    bool? includePendingReview,
  }) {
    final include = includePendingReview ?? isReviewModeEnabled;
    return AdhkarCatalog.getByCategory(category, includePendingReview: include);
  }

  @override
  DhikrItem? getById(String id, {bool? includePendingReview}) {
    final include = includePendingReview ?? isReviewModeEnabled;
    return AdhkarCatalog.getById(id, includePendingReview: include);
  }

  @override
  int get catalogVersion => AdhkarCatalog.catalogVersion;

  // --- Bookmarks ---

  @override
  Future<void> toggleBookmark(String dhikrId) async {
    final bookmarked = await _adhkarDao.isBookmarked(dhikrId);
    if (bookmarked) {
      await _adhkarDao.removeBookmark(dhikrId);
    } else {
      await _adhkarDao.addBookmark(dhikrId);
    }
  }

  @override
  Future<bool> isBookmarked(
    String dhikrId, {
    bool? includePendingReview,
  }) async {
    final include = includePendingReview ?? isReviewModeEnabled;
    final item = AdhkarCatalog.getById(dhikrId, includePendingReview: include);
    if (item == null) return false;
    return _adhkarDao.isBookmarked(dhikrId);
  }

  @override
  Future<List<DhikrItem>> getBookmarkedItems({
    bool? includePendingReview,
  }) async {
    final include = includePendingReview ?? isReviewModeEnabled;
    final ids = await _adhkarDao.getBookmarkedDhikrIds();
    return ids
        .map((id) => AdhkarCatalog.getById(id, includePendingReview: include))
        .whereType<DhikrItem>()
        .where((d) => include || d.isApproved)
        .toList();
  }

  @override
  Stream<List<String>> watchBookmarkedIds({bool? includePendingReview}) {
    final include = includePendingReview ?? isReviewModeEnabled;
    return _adhkarDao.watchBookmarkedDhikrIds().map((ids) {
      if (include) return ids;
      return ids.where((id) {
        final item = AdhkarCatalog.getById(id, includePendingReview: false);
        return item != null && item.isApproved;
      }).toList();
    });
  }

  @override
  Stream<List<DhikrItem>> watchBookmarkedItems({bool? includePendingReview}) {
    final include = includePendingReview ?? isReviewModeEnabled;
    return _adhkarDao.watchBookmarkedDhikrIds().map((ids) {
      return ids
          .map((id) => AdhkarCatalog.getById(id, includePendingReview: include))
          .whereType<DhikrItem>()
          .where((d) => include || d.isApproved)
          .toList();
    });
  }

  // --- Sessions ---

  @override
  Future<AdhkarSessionRecord?> getSession(String collectionId) async {
    final effectiveCollectionId = _canonicalCollectionId(collectionId);
    final row = await _adhkarDao.getSession(effectiveCollectionId);
    if (row != null) {
      return _mapSessionRow(row);
    }

    // Fallback & seamless migration from SettingsService legacy counts
    if (_settingsService != null) {
      final nowStr = DateTime.now().toIso8601String().substring(0, 10);
      final category = _parseCategory(effectiveCollectionId);
      if (category != null) {
        final items = AdhkarCatalog.getByCategory(
          category,
          includePendingReview: true,
        );
        final completedIds = _settingsService.getCompletedDhikrIds(nowStr);
        final counts = <String, int>{};
        bool hasAnyProgress = false;

        for (final item in items) {
          if (completedIds.contains(item.id)) {
            counts[item.id] = item.targetCount;
            hasAnyProgress = true;
          } else {
            final saved = _settingsService.getDhikrCount(nowStr, item.id);
            if (saved > 0) {
              counts[item.id] = saved;
              hasAnyProgress = true;
            }
          }
        }

        if (hasAnyProgress) {
          final isCompleted =
              items.isNotEmpty &&
              items.every((i) => (counts[i.id] ?? 0) >= i.targetCount);
          final record = AdhkarSessionRecord(
            collectionId: effectiveCollectionId,
            lastPageIndex: 0,
            counts: counts,
            lastAccessedAt: DateTime.now(),
            isCompleted: isCompleted,
          );
          await saveSession(
            collectionId: effectiveCollectionId,
            lastPageIndex: 0,
            counts: counts,
            isCompleted: isCompleted,
          );
          if (isCompleted) {
            await recordCollectionCompletion(
              effectiveCollectionId,
              date: nowStr,
            );
          }
          return record;
        }
      }
    }

    return null;
  }

  @override
  Stream<AdhkarSessionRecord?> watchSession(String collectionId) {
    return _adhkarDao.watchSession(_canonicalCollectionId(collectionId)).map((
      row,
    ) {
      return row != null ? _mapSessionRow(row) : null;
    });
  }

  @override
  Future<void> saveSession({
    required String collectionId,
    required int lastPageIndex,
    required Map<String, int> counts,
    bool isCompleted = false,
  }) {
    return _adhkarDao.saveSession(
      collectionId: _canonicalCollectionId(collectionId),
      lastPageIndex: lastPageIndex,
      countsJson: jsonEncode(counts),
      lastAccessedAt: DateTime.now().millisecondsSinceEpoch,
      isCompleted: isCompleted,
    );
  }

  @override
  Future<void> clearSession(String collectionId) {
    return _adhkarDao.clearSession(_canonicalCollectionId(collectionId));
  }

  // --- Progress & Counts ---

  @override
  Future<int> getCategoryCompletedCount(DhikrCategory category) async {
    final collectionId = _categoryToCollectionId(category);
    final session = await getSession(collectionId);
    if (session == null) return 0;
    final items = getByCategory(category);
    return items
        .where((i) => (session.counts[i.id] ?? 0) >= i.targetCount)
        .length;
  }

  @override
  Stream<int> watchCategoryCompletedCount(DhikrCategory category) {
    final collectionId = _categoryToCollectionId(category);
    return watchSession(collectionId).map((session) {
      if (session == null) return 0;
      final items = getByCategory(category);
      return items
          .where((i) => (session.counts[i.id] ?? 0) >= i.targetCount)
          .length;
    });
  }

  // --- Daily Completions ---

  @override
  Future<void> recordCollectionCompletion(String collectionId, {String? date}) {
    final targetDate =
        date ?? DateTime.now().toIso8601String().substring(0, 10);
    return _adhkarDao.logCollectionCompletion(
      collectionId: _canonicalCollectionId(collectionId),
      date: targetDate,
      completedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<bool> isCollectionCompletedToday(String collectionId, {String? date}) {
    final targetDate =
        date ?? DateTime.now().toIso8601String().substring(0, 10);
    return _adhkarDao.isCollectionCompletedOnDate(
      _canonicalCollectionId(collectionId),
      targetDate,
    );
  }

  @override
  Stream<bool> watchIsCollectionCompletedToday(
    String collectionId, {
    String? date,
  }) {
    final targetDate =
        date ?? DateTime.now().toIso8601String().substring(0, 10);
    return _adhkarDao.watchIsCollectionCompletedOnDate(
      _canonicalCollectionId(collectionId),
      targetDate,
    );
  }

  @override
  Future<List<String>> getCompletedCollectionIdsForDate(String date) async {
    final rows = await _adhkarDao.getCompletionsForDate(date);
    return rows.map((r) => r.collectionId).toList();
  }

  @override
  Future<void> removeCollectionCompletion(String collectionId, {String? date}) {
    final targetDate =
        date ?? DateTime.now().toIso8601String().substring(0, 10);
    return _adhkarDao.removeCompletion(
      _canonicalCollectionId(collectionId),
      targetDate,
    );
  }

  // --- Migration ---

  @override
  Future<void> migrateFromSharedPreferencesIfNeeded(
    SharedPreferences prefs,
  ) async {
    const migrationKey = 'adhkar_migrated_to_drift_v1';
    if (prefs.getBool(migrationKey) == true) return;

    final keys = prefs.getKeys();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final sessionsToSave = <String, Map<String, int>>{};
    final dateCompletionsToLog = <String, Set<String>>{};

    for (final key in keys) {
      if (key.startsWith('adhkar_done_')) {
        final date = key.replaceFirst('adhkar_done_', '');
        final completedIds = prefs.getStringList(key) ?? [];
        for (final id in completedIds) {
          final item = AdhkarCatalog.getById(id, includePendingReview: true);
          if (item != null) {
            final colId = _categoryToCollectionId(item.category);
            if (date == todayStr) {
              sessionsToSave.putIfAbsent(colId, () => {})[id] =
                  item.targetCount;
            }
          }
        }

        // Check if any canonical collection was fully completed on this date
        for (final cat in [
          DhikrCategory.morning,
          DhikrCategory.evening,
          DhikrCategory.postPrayer,
          DhikrCategory.general,
          DhikrCategory.sleeping,
          DhikrCategory.dailySunnah,
        ]) {
          final colId = _categoryToCollectionId(cat);
          final catItems = AdhkarCatalog.getByCategory(
            cat,
            includePendingReview: true,
          );
          if (catItems.isNotEmpty &&
              catItems.every((ci) => completedIds.contains(ci.id))) {
            dateCompletionsToLog.putIfAbsent(date, () => {}).add(colId);
          }
        }
      } else if (key.startsWith('adhkar_count_')) {
        final parts = key.split('_');
        if (parts.length >= 4) {
          final date = parts[2];
          final dhikrId = parts.sublist(3).join('_');
          final count = prefs.getInt(key) ?? 0;
          if (date == todayStr && count > 0) {
            final item = AdhkarCatalog.getById(
              dhikrId,
              includePendingReview: true,
            );
            if (item != null) {
              final colId = _categoryToCollectionId(item.category);
              sessionsToSave.putIfAbsent(colId, () => {})[dhikrId] = count;
            }
          }
        }
      }
    }

    // Save completions to database
    for (final entry in dateCompletionsToLog.entries) {
      final date = entry.key;
      for (final colId in entry.value) {
        await _adhkarDao.logCollectionCompletion(
          collectionId: colId,
          date: date,
          completedAt: DateTime.now().millisecondsSinceEpoch,
        );
      }
    }

    // Save sessions to database
    for (final entry in sessionsToSave.entries) {
      final colId = entry.key;
      final cat = _parseCategory(colId);
      final items = cat != null
          ? AdhkarCatalog.getByCategory(cat, includePendingReview: true)
          : <DhikrItem>[];
      final isCompleted =
          items.isNotEmpty &&
          items.every((i) => (entry.value[i.id] ?? 0) >= i.targetCount);
      await saveSession(
        collectionId: colId,
        lastPageIndex: 0,
        counts: entry.value,
        isCompleted: isCompleted,
      );
      if (isCompleted) {
        await recordCollectionCompletion(colId, date: todayStr);
      }
    }

    // Clean up legacy keys if any adhkar data was present
    final hasLegacyData = keys.any(
      (k) => k.startsWith('adhkar_done_') || k.startsWith('adhkar_count_'),
    );
    if (hasLegacyData) {
      for (final key in keys) {
        if (key.startsWith('adhkar_done_') || key.startsWith('adhkar_count_')) {
          await prefs.remove(key);
        }
      }
      await prefs.setBool(migrationKey, true);
    }
  }

  // --- Helpers ---

  static String _canonicalCollectionId(String collectionId) {
    if (collectionId == DhikrCategory.wakingUp.name) {
      return DhikrCategory.morning.name;
    }
    return collectionId;
  }

  static String _categoryToCollectionId(DhikrCategory category) {
    if (category == DhikrCategory.wakingUp) {
      return DhikrCategory.morning.name;
    }
    return category.name;
  }

  AdhkarSessionRecord _mapSessionRow(AdhkarSession row) {
    Map<String, int> counts = {};
    try {
      final decoded = jsonDecode(row.countsJson);
      if (decoded is Map) {
        counts = decoded.map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        );
      }
    } catch (_) {}

    return AdhkarSessionRecord(
      collectionId: row.collectionId,
      lastPageIndex: row.lastPageIndex,
      counts: counts,
      lastAccessedAt: DateTime.fromMillisecondsSinceEpoch(row.lastAccessedAt),
      isCompleted: row.isCompleted,
    );
  }

  DhikrCategory? _parseCategory(String name) {
    if (name == DhikrCategory.wakingUp.name) {
      return DhikrCategory.morning;
    }
    for (final cat in DhikrCategory.values) {
      if (cat.name == name) return cat;
    }
    return null;
  }
}
