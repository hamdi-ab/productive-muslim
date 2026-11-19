import 'package:shared_preferences/shared_preferences.dart';

import 'package:productive_muslim/domain/models/adhkar_session_record.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';

abstract class AdhkarRepository {
  List<DhikrItem> getAll({bool? includePendingReview});
  List<DhikrItem> getByCategory(
    DhikrCategory category, {
    bool? includePendingReview,
  });
  DhikrItem? getById(String id, {bool? includePendingReview});
  int get catalogVersion;

  // Review Mode
  bool get isReviewModeAvailable;
  bool get isReviewModeEnabled;
  Future<void> setReviewModeEnabled(bool enabled);

  // Bookmarks
  Future<void> toggleBookmark(String dhikrId);
  Future<bool> isBookmarked(String dhikrId, {bool? includePendingReview});
  Future<List<DhikrItem>> getBookmarkedItems({bool? includePendingReview});
  Stream<List<String>> watchBookmarkedIds({bool? includePendingReview});
  Stream<List<DhikrItem>> watchBookmarkedItems({bool? includePendingReview});

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
