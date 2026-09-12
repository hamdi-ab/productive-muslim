import 'package:productive_muslim/data/local/daos/barakah_dao.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';

class BarakahRepositoryImpl implements BarakahRepository {
  BarakahRepositoryImpl({required BarakahDao barakahDao})
      : _barakahDao = barakahDao;

  final BarakahDao _barakahDao;

  @override
  Stream<List<BarakahEntry>> watchEntriesForDate(String date) {
    return _barakahDao.watchEntriesForDate(date);
  }

  @override
  Future<List<BarakahEntry>> getEntriesForDate(String date) {
    return _barakahDao.getEntriesForDate(date);
  }

  @override
  Future<List<BarakahEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  ) {
    return _barakahDao.getEntriesForRange(startDate, endDate);
  }

  @override
  Future<BarakahEntry?> getEntryById(int id) {
    return _barakahDao.getEntryById(id);
  }

  @override
  Future<int> insertEntry(BarakahEntry entry) {
    return _barakahDao.insertEntry(entry);
  }

  @override
  Future<bool> updateEntry(BarakahEntry entry) {
    return _barakahDao.updateEntry(entry);
  }

  @override
  Future<int> deleteEntry(int id) {
    return _barakahDao.deleteEntry(id);
  }
}