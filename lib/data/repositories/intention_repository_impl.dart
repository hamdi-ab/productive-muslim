import 'package:productive_muslim/data/local/daos/intention_dao.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart'
    as intention_model;
import 'package:productive_muslim/domain/repositories/intention_repository.dart';

class IntentionRepositoryImpl implements IntentionRepository {
  IntentionRepositoryImpl({required IntentionDao intentionDao})
    : _intentionDao = intentionDao;

  final IntentionDao _intentionDao;

  @override
  Stream<List<intention_model.IntentionEntry>> watchEntriesForDate(
    String date,
  ) {
    return _intentionDao.watchEntriesForDate(date);
  }

  @override
  Future<List<intention_model.IntentionEntry>> getEntriesForDate(String date) {
    return _intentionDao.getEntriesForDate(date);
  }

  @override
  Future<List<intention_model.IntentionEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  ) {
    return _intentionDao.getEntriesForRange(startDate, endDate);
  }

  @override
  Future<intention_model.IntentionEntry?> getEntryById(int id) {
    return _intentionDao.getEntryById(id);
  }

  @override
  Future<int> insertEntry(intention_model.IntentionEntry entry) {
    return _intentionDao.insertEntry(entry);
  }

  @override
  Future<bool> updateEntry(intention_model.IntentionEntry entry) {
    return _intentionDao.updateEntry(entry);
  }

  @override
  Future<int> deleteEntry(int id) {
    return _intentionDao.deleteEntry(id);
  }
}
