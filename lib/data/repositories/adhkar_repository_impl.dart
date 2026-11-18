import 'dart:convert';

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

  @override
  List<DhikrItem> getAll() => AdhkarCatalog.all;

  @override
  List<DhikrItem> getByCategory(DhikrCategory category) =>
      AdhkarCatalog.getByCategory(category);

  @override
  DhikrItem? getById(String id) => AdhkarCatalog.getById(id);

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
  Future<bool> isBookmarked(String dhikrId) => _adhkarDao.isBookmarked(dhikrId);

  @override
  Future<List<DhikrItem>> getBookmarkedItems() async {
    final ids = await _adhkarDao.getBookmarkedDhikrIds();
    return ids
        .map((id) => AdhkarCatalog.getById(id))
        .whereType<DhikrItem>()
        .toList();
  }

  @override
  Stream<List<String>> watchBookmarkedIds() =>
      _adhkarDao.watchBookmarkedDhikrIds();

  @override
  Stream<List<DhikrItem>> watchBookmarkedItems() {
    return _adhkarDao.watchBookmarkedDhikrIds().map((ids) {
      return ids
          .map((id) => AdhkarCatalog.getById(id))
          .whereType<DhikrItem>()
          .toList();
    });
  }

  // --- Sessions ---

  @override
  Future<AdhkarSessionRecord?> getSession(String collectionId) async {
    final row = await _adhkarDao.getSession(collectionId);
    if (row != null) {
      return _mapSessionRow(row);
    }

    // Fallback & seamless migration from SettingsService legacy counts
    if (_settingsService != null) {
      final nowStr = DateTime.now().toIso8601String().substring(0, 10);
      final category = _parseCategory(collectionId);
      if (category != null) {
        final items = AdhkarCatalog.getByCategory(category);
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
            collectionId: collectionId,
            lastPageIndex: 0,
            counts: counts,
            lastAccessedAt: DateTime.now(),
            isCompleted: isCompleted,
          );
          await saveSession(
            collectionId: collectionId,
            lastPageIndex: 0,
            counts: counts,
            isCompleted: isCompleted,
          );
          if (isCompleted) {
            await recordCollectionCompletion(collectionId, date: nowStr);
          }
          return record;
        }
      }
    }

    return null;
  }

  @override
  Stream<AdhkarSessionRecord?> watchSession(String collectionId) {
    return _adhkarDao.watchSession(collectionId).map((row) {
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
      collectionId: collectionId,
      lastPageIndex: lastPageIndex,
      countsJson: jsonEncode(counts),
      lastAccessedAt: DateTime.now().millisecondsSinceEpoch,
      isCompleted: isCompleted,
    );
  }

  @override
  Future<void> clearSession(String collectionId) {
    return _adhkarDao.clearSession(collectionId);
  }

  // --- Progress & Counts ---

  @override
  Future<int> getCategoryCompletedCount(DhikrCategory category) async {
    final session = await getSession(category.name);
    if (session == null) return 0;
    final items = AdhkarCatalog.getByCategory(category);
    return items
        .where((i) => (session.counts[i.id] ?? 0) >= i.targetCount)
        .length;
  }

  @override
  Stream<int> watchCategoryCompletedCount(DhikrCategory category) {
    final items = AdhkarCatalog.getByCategory(category);
    return watchSession(category.name).map((session) {
      if (session == null) return 0;
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
      collectionId: collectionId,
      date: targetDate,
      completedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<bool> isCollectionCompletedToday(String collectionId, {String? date}) {
    final targetDate =
        date ?? DateTime.now().toIso8601String().substring(0, 10);
    return _adhkarDao.isCollectionCompletedOnDate(collectionId, targetDate);
  }

  @override
  Stream<bool> watchIsCollectionCompletedToday(
    String collectionId, {
    String? date,
  }) {
    final targetDate =
        date ?? DateTime.now().toIso8601String().substring(0, 10);
    return _adhkarDao.watchIsCollectionCompletedOnDate(
      collectionId,
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
    return _adhkarDao.removeCompletion(collectionId, targetDate);
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

    for (final key in keys) {
      if (key.startsWith('adhkar_done_')) {
        final date = key.replaceFirst('adhkar_done_', '');
        final completedIds = prefs.getStringList(key) ?? [];
        for (final id in completedIds) {
          final item = AdhkarCatalog.getById(id);
          if (item != null) {
            final cat = item.category.name;
            sessionsToSave.putIfAbsent(cat, () => {})[id] = item.targetCount;
            // Check if collection completed
            final catItems = AdhkarCatalog.getByCategory(item.category);
            final allDone =
                catItems.isNotEmpty &&
                catItems.every(
                  (ci) =>
                      completedIds.contains(ci.id) ||
                      (sessionsToSave[cat]?[ci.id] ?? 0) >= ci.targetCount,
                );
            if (allDone) {
              await _adhkarDao.logCollectionCompletion(
                collectionId: cat,
                date: date,
                completedAt: DateTime.now().millisecondsSinceEpoch,
              );
            }
          }
        }
      } else if (key.startsWith('adhkar_count_')) {
        final parts = key.split('_');
        if (parts.length >= 4) {
          final date = parts[2];
          final dhikrId = parts.sublist(3).join('_');
          final count = prefs.getInt(key) ?? 0;
          if (date == todayStr && count > 0) {
            final item = AdhkarCatalog.getById(dhikrId);
            if (item != null) {
              final cat = item.category.name;
              sessionsToSave.putIfAbsent(cat, () => {})[dhikrId] = count;
            }
          }
        }
      }
    }

    for (final entry in sessionsToSave.entries) {
      final cat = _parseCategory(entry.key);
      final items = cat != null
          ? AdhkarCatalog.getByCategory(cat)
          : <DhikrItem>[];
      final isCompleted =
          items.isNotEmpty &&
          items.every((i) => (entry.value[i.id] ?? 0) >= i.targetCount);
      await saveSession(
        collectionId: entry.key,
        lastPageIndex: 0,
        counts: entry.value,
        isCompleted: isCompleted,
      );
    }

    // Clean up legacy keys if any migrated
    if (sessionsToSave.isNotEmpty) {
      for (final key in keys) {
        if (key.startsWith('adhkar_done_') || key.startsWith('adhkar_count_')) {
          await prefs.remove(key);
        }
      }
      await prefs.setBool(migrationKey, true);
    }
  }

  // --- Helpers ---

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
    for (final cat in DhikrCategory.values) {
      if (cat.name == name) return cat;
    }
    return null;
  }
}
