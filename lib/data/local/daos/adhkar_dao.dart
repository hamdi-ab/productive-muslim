import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/database/tables/adhkar_bookmarks.dart';
import 'package:productive_muslim/data/local/database/tables/adhkar_completions.dart';
import 'package:productive_muslim/data/local/database/tables/adhkar_sessions.dart';

part 'adhkar_dao.g.dart';

@DriftAccessor(tables: [AdhkarBookmarks, AdhkarSessions, AdhkarCompletions])
class AdhkarDao extends DatabaseAccessor<AppDatabase> with _$AdhkarDaoMixin {
  AdhkarDao(super.db);

  // --- Bookmarks ---

  Future<void> addBookmark(String dhikrId, {int? createdAt}) {
    final timestamp = createdAt ?? DateTime.now().millisecondsSinceEpoch;
    return into(adhkarBookmarks).insertOnConflictUpdate(
      AdhkarBookmarksCompanion.insert(dhikrId: dhikrId, createdAt: timestamp),
    );
  }

  Future<void> removeBookmark(String dhikrId) {
    return (delete(
      adhkarBookmarks,
    )..where((t) => t.dhikrId.equals(dhikrId))).go();
  }

  Future<bool> isBookmarked(String dhikrId) async {
    final row = await (select(
      adhkarBookmarks,
    )..where((t) => t.dhikrId.equals(dhikrId))).getSingleOrNull();
    return row != null;
  }

  Future<List<String>> getBookmarkedDhikrIds() async {
    final rows = await (select(
      adhkarBookmarks,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    return rows.map((r) => r.dhikrId).toList();
  }

  Stream<List<String>> watchBookmarkedDhikrIds() {
    return (select(adhkarBookmarks)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map((r) => r.dhikrId).toList());
  }

  // --- Sessions ---

  Future<AdhkarSession?> getSession(String collectionId) {
    return (select(
      adhkarSessions,
    )..where((t) => t.collectionId.equals(collectionId))).getSingleOrNull();
  }

  Stream<AdhkarSession?> watchSession(String collectionId) {
    return (select(
      adhkarSessions,
    )..where((t) => t.collectionId.equals(collectionId))).watchSingleOrNull();
  }

  Future<void> saveSession({
    required String collectionId,
    required int lastPageIndex,
    required String countsJson,
    required int lastAccessedAt,
    bool isCompleted = false,
  }) {
    return into(adhkarSessions).insertOnConflictUpdate(
      AdhkarSessionsCompanion.insert(
        collectionId: collectionId,
        lastPageIndex: Value(lastPageIndex),
        countsJson: Value(countsJson),
        lastAccessedAt: lastAccessedAt,
        isCompleted: Value(isCompleted),
      ),
    );
  }

  Future<void> clearSession(String collectionId) {
    return (delete(
      adhkarSessions,
    )..where((t) => t.collectionId.equals(collectionId))).go();
  }

  Future<List<AdhkarSession>> getAllSessions() {
    return select(adhkarSessions).get();
  }

  // --- Completions ---

  Future<void> logCollectionCompletion({
    required String collectionId,
    required String date,
    required int completedAt,
  }) {
    final companion = AdhkarCompletionsCompanion.insert(
      collectionId: collectionId,
      date: date,
      completedAt: completedAt,
    );
    return into(adhkarCompletions).insert(
      companion,
      onConflict: DoUpdate(
        (_) => AdhkarCompletionsCompanion(completedAt: Value(completedAt)),
        target: [adhkarCompletions.collectionId, adhkarCompletions.date],
      ),
    );
  }

  Future<bool> isCollectionCompletedOnDate(
    String collectionId,
    String date,
  ) async {
    final row =
        await (select(adhkarCompletions)..where(
              (t) => t.collectionId.equals(collectionId) & t.date.equals(date),
            ))
            .getSingleOrNull();
    return row != null;
  }

  Stream<bool> watchIsCollectionCompletedOnDate(
    String collectionId,
    String date,
  ) {
    return (select(adhkarCompletions)..where(
          (t) => t.collectionId.equals(collectionId) & t.date.equals(date),
        ))
        .watchSingleOrNull()
        .map((row) => row != null);
  }

  Future<List<AdhkarCompletion>> getCompletionsForDate(String date) {
    return (select(adhkarCompletions)..where((t) => t.date.equals(date))).get();
  }

  Stream<List<AdhkarCompletion>> watchCompletionsForDate(String date) {
    return (select(
      adhkarCompletions,
    )..where((t) => t.date.equals(date))).watch();
  }

  Future<List<AdhkarCompletion>> getCompletionsForCollection(
    String collectionId,
  ) {
    return (select(adhkarCompletions)
          ..where((t) => t.collectionId.equals(collectionId))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .get();
  }

  Future<List<AdhkarCompletion>> getAllCompletions() {
    return select(adhkarCompletions).get();
  }

  Future<void> removeCompletion(String collectionId, String date) {
    return (delete(adhkarCompletions)..where(
          (t) => t.collectionId.equals(collectionId) & t.date.equals(date),
        ))
        .go();
  }
}
