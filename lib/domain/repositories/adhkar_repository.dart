import 'package:shared_preferences/shared_preferences.dart';

import 'package:productive_muslim/domain/models/adhkar_session_record.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';

abstract class AdhkarRepository {
  List<DhikrItem> getAll();
  List<DhikrItem> getByCategory(DhikrCategory category);
  DhikrItem? getById(String id);
  int get catalogVersion;

  // Bookmarks
  Future<void> toggleBookmark(String dhikrId);
  Future<bool> isBookmarked(String dhikrId);
  Future<List<DhikrItem>> getBookmarkedItems();
  Stream<List<String>> watchBookmarkedIds();
  Stream<List<DhikrItem>> watchBookmarkedItems();

  // Sessions
  Future<AdhkarSessionRecord?> getSession(String collectionId);
  Stream<AdhkarSessionRecord?> watchSession(String collectionId);
  Future<void> saveSession({
    required String collectionId,
    required int lastPageIndex,
    required Map<String, int> counts,
    bool isCompleted = false,
  });
  Future<void> clearSession(String collectionId);

  // Progress & Counts
  Future<int> getCategoryCompletedCount(DhikrCategory category);
  Stream<int> watchCategoryCompletedCount(DhikrCategory category);

  // Daily Completions
  Future<void> recordCollectionCompletion(String collectionId, {String? date});
  Future<bool> isCollectionCompletedToday(String collectionId, {String? date});
  Stream<bool> watchIsCollectionCompletedToday(
    String collectionId, {
    String? date,
  });
  Future<List<String>> getCompletedCollectionIdsForDate(String date);
  Future<void> removeCollectionCompletion(String collectionId, {String? date});

  // Migration
  Future<void> migrateFromSharedPreferencesIfNeeded(SharedPreferences prefs);
}
