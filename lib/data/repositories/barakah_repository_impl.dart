import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/barakah_dao.dart';
import 'package:productive_muslim/data/mappers/barakah_mapper.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart'
    as barakah_model;
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';

class BarakahRepositoryImpl implements BarakahRepository {
  BarakahRepositoryImpl({required BarakahDao barakahDao})
    : _barakahDao = barakahDao;

  final BarakahDao _barakahDao;
  final _mapper = BarakahMapper();

  @override
  Stream<List<barakah_model.BarakahEntry>> watchEntriesForDate(String date) {
    return _barakahDao
        .watchEntriesForDate(date)
        .map((rows) => rows.map(_mapper.toDomain).toList());
  }

  @override
  Future<List<barakah_model.BarakahEntry>> getEntriesForDate(
    String date,
  ) async {
    final rows = await _barakahDao.getEntriesForDate(date);
    return rows.map(_mapper.toDomain).toList();
  }

  @override
  Future<List<barakah_model.BarakahEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  ) async {
    final rows = await _barakahDao.getEntriesForRange(startDate, endDate);
    return rows.map(_mapper.toDomain).toList();
  }

  @override
  Future<barakah_model.BarakahEntry?> getEntryById(int id) async {
    final row = await _barakahDao.getEntryById(id);
    return row == null ? null : _mapper.toDomain(row);
  }

  @override
  Future<int> insertEntry(barakah_model.BarakahEntry entry) {
    return _barakahDao.insertEntry(
      BarakahEntriesCompanion.insert(
        date: entry.date,
        sourceIds: entry.sourceIds.join(','),
        promptId: Value(entry.promptId),
        intensity: Value(entry.intensity),
        note: Value(entry.note),
        skipped: Value(entry.skipped ? 1 : 0),
        createdAt: Value(entry.createdAt),
      ),
    );
  }

  @override
  Future<bool> updateEntry(barakah_model.BarakahEntry entry) {
    return _barakahDao.updateEntry(_mapper.toRow(entry));
  }

  @override
  Future<int> deleteEntry(int id) {
    return _barakahDao.deleteEntry(id);
  }
}
