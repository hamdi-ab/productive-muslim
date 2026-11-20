import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/database/tables/adhkar_bookmarks.dart';
import 'package:productive_muslim/data/local/database/tables/adhkar_completions.dart';
import 'package:productive_muslim/data/local/database/tables/adhkar_routine_completions.dart';
import 'package:productive_muslim/data/local/database/tables/adhkar_routines.dart';
import 'package:productive_muslim/data/local/database/tables/adhkar_sessions.dart';

part 'adhkar_dao.g.dart';

@DriftAccessor(
  tables: [
    AdhkarBookmarks,
    AdhkarSessions,
    AdhkarCompletions,
    AdhkarRoutines,
    AdhkarRoutineCompletions,
  ],
)
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
    final query = select(adhkarCompletions)
      ..where((t) => t.collectionId.equals(collectionId) & t.date.equals(date))
      ..limit(1);
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  Stream<bool> watchIsCollectionCompletedOnDate(
    String collectionId,
    String date,
  ) {
    final query = select(adhkarCompletions)
      ..where((t) => t.collectionId.equals(collectionId) & t.date.equals(date))
      ..limit(1);
    return query.watch().map((rows) => rows.isNotEmpty);
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

  // --- Routines ---

  Future<void> saveRoutine({
    required String id,
    required String name,
    required String itemIdsJson,
    String? preferredTime,
    String? weekdaysJson,
    required int createdAt,
    required int updatedAt,
    String? retiredItemIdsJson,
  }) {
    return into(adhkarRoutines).insertOnConflictUpdate(
      AdhkarRoutinesCompanion.insert(
        id: id,
        name: name,
        itemIdsJson: itemIdsJson,
        preferredTime: Value(preferredTime),
        weekdaysJson: Value(weekdaysJson),
        createdAt: createdAt,
        updatedAt: updatedAt,
        retiredItemIdsJson: Value(retiredItemIdsJson),
      ),
    );
  }

  Future<void> deleteRoutine(String routineId) async {
    await (delete(adhkarRoutines)..where((t) => t.id.equals(routineId))).go();
    await clearSession('routine_$routineId');
  }

  Future<AdhkarRoutineEntry?> getRoutine(String routineId) {
    return (select(
      adhkarRoutines,
    )..where((t) => t.id.equals(routineId))).getSingleOrNull();
  }

  Future<List<AdhkarRoutineEntry>> getAllRoutines() {
    return (select(
      adhkarRoutines,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
  }

  Stream<List<AdhkarRoutineEntry>> watchAllRoutines() {
    return (select(
      adhkarRoutines,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch();
  }

  // --- Routine Completions ---

  Future<void> logRoutineCompletion({
    required String routineId,
    required String routineName,
    required String date,
    required int completedAt,
  }) {
    return into(adhkarRoutineCompletions).insert(
      AdhkarRoutineCompletionsCompanion.insert(
        routineId: routineId,
        routineName: routineName,
        date: date,
        completedAt: completedAt,
      ),
    );
  }

  Future<bool> isRoutineCompletedOnDate(String routineId, String date) async {
    final query = select(adhkarRoutineCompletions)
      ..where((t) => t.routineId.equals(routineId) & t.date.equals(date))
      ..limit(1);
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  Stream<bool> watchIsRoutineCompletedOnDate(String routineId, String date) {
    final query = select(adhkarRoutineCompletions)
      ..where((t) => t.routineId.equals(routineId) & t.date.equals(date))
      ..limit(1);
    return query.watch().map((rows) => rows.isNotEmpty);
  }

  Future<List<AdhkarRoutineCompletionEntry>> getRoutineCompletionsForDate(
    String date,
  ) {
    return (select(
      adhkarRoutineCompletions,
    )..where((t) => t.date.equals(date))).get();
  }

  Future<List<AdhkarRoutineCompletionEntry>> getAllRoutineCompletions({
    String? routineId,
  }) {
    final query = select(adhkarRoutineCompletions);
    if (routineId != null) {
      query.where((t) => t.routineId.equals(routineId));
    }
    return (query..orderBy([(t) => OrderingTerm.desc(t.completedAt)])).get();
  }
}
