import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/barakah_dao.dart';
import 'package:productive_muslim/data/models/barakah_entry.dart' as barakah_model;
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';

class BarakahRepositoryImpl implements BarakahRepository {
  BarakahRepositoryImpl({required BarakahDao barakahDao}) : _barakahDao = barakahDao;

  final BarakahDao _barakahDao;

  @override
  Stream<List<barakah_model.BarakahEntry>> watchEntriesForDate(String date) {
    return _barakahDao.watchEntriesForDate(date);
  }

  @override
  Future<List<barakah_model.BarakahEntry>> getEntriesForDate(String date) {
    return _barakahDao.getEntriesForDate(date);
  }

  @override
  Future<List<barakah_model.BarakahEntry>> getEntriesForRange(String startDate, String endDate) {
    return _barakahDao.getEntriesForRange(startDate, endDate);
  }

  @override
  Future<barakah_model.BarakahEntry?> getEntryById(int id) {
    return _barakahDao.getEntryById(id);
  }

  @override
  Future<int> insertEntry(barakah_model.BarakahEntry entry) {
    return _barakahDao.insertEntry(BarakahEntriesCompanion(
      date: Value(entry.date),
      sourceIds: Value(entry.sourceIds.join(',')),
      promptId: Value(entry.promptId),
      intensity: Value(entry.intensity),
      note: Value(entry.note),
      skipped: Value(entry.skipped),
      createdAt: Value(entry.createdAt),
    ));
  }

  @override
  Future<bool> updateEntry(barakah_model.BarakahEntry entry) {
    return _barakahDao.updateEntry(entry);
  }

  @override
  Future<int> deleteEntry(int id) {
    return _barakahDao.deleteEntry(id);
  }
}