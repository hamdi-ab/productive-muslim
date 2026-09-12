import 'package:productive_muslim/data/local/daos/intention_dao.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart';
import 'package:productive_muslim/domain/repositories/intention_repository.dart';

class IntentionRepositoryImpl implements IntentionRepository {
  IntentionRepositoryImpl({required IntentionDao intentionDao})
      : _intentionDao = intentionDao;

  final IntentionDao _intentionDao;

  @override
  Stream<List<IntentionEntry>> watchEntriesForDate(String date) {
    return _intentionDao.watchEntriesForDate(date);
  }

  @override
  Future<List<IntentionEntry>> getEntriesForDate(String date) {
    return _intentionDao.getEntriesForDate(date);
  }

  @override
  Future<List<IntentionEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  ) {
    return _intentionDao.getEntriesForRange(startDate, endDate);
  }

  @override
  Future<IntentionEntry?> getEntryById(int id) {
    return _intentionDao.getEntryById(id);
  }

  @override
  Future<int> insertEntry(IntentionEntry entry) {
    return _intentionDao.insertEntry(entry);
  }

  @override
  Future<bool> updateEntry(IntentionEntry entry) {
    return _intentionDao.updateEntry(entry);
  }

  @override
  Future<int> deleteEntry(int id) {
    return _intentionDao.deleteEntry(id);
  }
}