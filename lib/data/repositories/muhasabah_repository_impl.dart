import 'package:drift/drift.dart';

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/muhasabah_dao.dart';
import 'package:productive_muslim/data/mappers/muhasabah_mapper.dart';
import 'package:productive_muslim/domain/models/muhasabah_entry.dart'
    as muhasabah_model;
import 'package:productive_muslim/domain/repositories/muhasabah_repository.dart';

class MuhasabahRepositoryImpl implements MuhasabahRepository {
  MuhasabahRepositoryImpl({required MuhasabahDao muhasabahDao})
    : _muhasabahDao = muhasabahDao;

  final MuhasabahDao _muhasabahDao;
  final _mapper = MuhasabahMapper();

  @override
  Stream<List<muhasabah_model.MuhasabahEntry>> watchEntriesForDate(
    String date,
  ) {
    return _muhasabahDao
        .watchEntriesForDate(date)
        .map((rows) => rows.map(_mapper.toDomain).toList());
  }

  @override
  Future<List<muhasabah_model.MuhasabahEntry>> getEntriesForDate(
    String date,
  ) async {
    final rows = await _muhasabahDao.getEntriesForDate(date);
    return rows.map(_mapper.toDomain).toList();
  }

  @override
  Future<List<muhasabah_model.MuhasabahEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  ) async {
    final rows = await _muhasabahDao.getEntriesForRange(startDate, endDate);
    return rows.map(_mapper.toDomain).toList();
  }

  @override
  Future<muhasabah_model.MuhasabahEntry?> getEntryById(int id) async {
    final row = await _muhasabahDao.getEntryById(id);
    return row == null ? null : _mapper.toDomain(row);
  }

  @override
  Future<int> insertEntry(muhasabah_model.MuhasabahEntry entry) {
    return _muhasabahDao.insertEntry(
      MuhasabahEntriesCompanion.insert(
        date: entry.date,
        promptId: Value(entry.promptId),
        promptText: Value(entry.promptText),
        content: entry.content,
        tags: Value(entry.tags),
        createdAt: Value(entry.createdAt),
        updatedAt: Value(entry.updatedAt),
      ),
    );
  }

  @override
  Future<bool> updateEntry(muhasabah_model.MuhasabahEntry entry) {
    return _muhasabahDao.updateEntry(_mapper.toRow(entry));
  }

  @override
  Future<int> deleteEntry(int id) {
    return _muhasabahDao.deleteEntry(id);
  }
}
