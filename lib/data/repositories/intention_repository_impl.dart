import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/intention_dao.dart';
import 'package:productive_muslim/data/mappers/intention_mapper.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart'
    as intention_model;
import 'package:productive_muslim/domain/repositories/intention_repository.dart';

class IntentionRepositoryImpl implements IntentionRepository {
  IntentionRepositoryImpl({required IntentionDao intentionDao})
    : _intentionDao = intentionDao;

  final IntentionDao _intentionDao;
  final _mapper = IntentionMapper();

  @override
  Stream<List<intention_model.IntentionEntry>> watchEntriesForDate(
    String date,
  ) {
    return _intentionDao
        .watchEntriesForDate(date)
        .map((rows) => rows.map(_mapper.toDomain).toList());
  }

  @override
  Future<List<intention_model.IntentionEntry>> getEntriesForDate(
    String date,
  ) async {
    final rows = await _intentionDao.getEntriesForDate(date);
    return rows.map(_mapper.toDomain).toList();
  }

  @override
  Future<List<intention_model.IntentionEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  ) async {
    final rows = await _intentionDao.getEntriesForRange(startDate, endDate);
    return rows.map(_mapper.toDomain).toList();
  }

  @override
  Future<intention_model.IntentionEntry?> getEntryById(int id) async {
    final row = await _intentionDao.getEntryById(id);
    return row == null ? null : _mapper.toDomain(row);
  }

  @override
  Future<int> insertEntry(intention_model.IntentionEntry entry) {
    return _intentionDao.insertEntry(
      IntentionEntriesCompanion.insert(
        date: entry.date,
        title: entry.title,
        statement: Value(entry.statement),
        category: Value(entry.category),
        completed: Value(entry.completed ? 1 : 0),
        reflection: Value(entry.reflection),
        createdAt: Value(entry.createdAt),
      ),
    );
  }

  @override
  Future<bool> updateEntry(intention_model.IntentionEntry entry) {
    return _intentionDao.updateEntry(_mapper.toRow(entry));
  }

  @override
  Future<int> deleteEntry(int id) {
    return _intentionDao.deleteEntry(id);
  }
}
