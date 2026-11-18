import 'dart:convert';

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

  AdhkarRepositoryImpl({
    required AdhkarDao adhkarDao,
    SettingsService? settingsService,
  }) : _adhkarDao = adhkarDao,
       _settingsService = settingsService;

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
