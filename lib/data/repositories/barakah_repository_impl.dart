import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart' show StringCharacters;

import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/local/daos/barakah_dao.dart';
import 'package:productive_muslim/data/mappers/barakah_mapper.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_prompt.dart'
    as prompt_model;
import 'package:productive_muslim/domain/models/barakah_entry.dart'
    as barakah_model;
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';

class BarakahRepositoryImpl implements BarakahRepository {
  BarakahRepositoryImpl({required BarakahDao barakahDao})
    : _barakahDao = barakahDao;

  final BarakahDao _barakahDao;
  final _mapper = BarakahMapper();

  @override
  Stream<BarakahDailyResponse?> watchDailyResponse(String date) {
    prompt_model.BarakahPrompt.forDate(date);
    return _barakahDao.watchDailyResponse(date).map((row) {
      if (row == null) return null;
      return _dailyResponse(row);
    });
  }

  BarakahDailyResponse _dailyResponse(BarakahDailyResponseRow row) =>
      BarakahDailyResponse(
        date: row.date,
        promptId: row.promptId,
        answer: BarakahAnswer.values.byName(row.answer),
        sourceIds: (jsonDecode(row.sourceIds) as List).cast<String>(),
        note: row.note,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  @override
  Stream<List<BarakahDailyResponse>> watchDailyResponsesForRange(
    String startDate,
    String endDate,
  ) {
    prompt_model.BarakahPrompt.forDate(startDate);
    prompt_model.BarakahPrompt.forDate(endDate);
    if (startDate.compareTo(endDate) > 0) {
      throw ArgumentError('The range end must not precede its start');
    }
    return _barakahDao
        .watchDailyResponsesForRange(startDate, endDate)
        .map((rows) => rows.map(_dailyResponse).toList());
  }

  @override
  Future<void> saveDailyResponse(BarakahDailyResponse response) async {
    prompt_model.BarakahPrompt.forDate(response.date);
    final prompts = prompt_model.BarakahPrompt.all.where(
      (prompt) => prompt.id == response.promptId,
    );
    if (prompts.isEmpty) {
      throw ArgumentError.value(
        response.promptId,
        'promptId',
        'Unknown prompt',
      );
    }
    final prompt = prompts.single;
    if (response.sourceIds.toSet().length != response.sourceIds.length ||
        response.sourceIds.any(
          (source) => !prompt.sourceIds.contains(source),
        )) {
      throw ArgumentError.value(
        response.sourceIds,
        'sourceIds',
        'Invalid sources',
      );
    }
    if ((response.answer == BarakahAnswer.skip ||
            response.answer == BarakahAnswer.no) &&
        response.sourceIds.isNotEmpty) {
      throw ArgumentError.value(
        response.sourceIds,
        'sourceIds',
        'This answer cannot affirm sources',
      );
    }
    if ((response.note?.characters.length ?? 0) > 280) {
      throw ArgumentError.value(
        response.note,
        'note',
        'Maximum 280 characters',
      );
    }
    await _barakahDao.saveDailyResponse(
      BarakahDailyResponsesCompanion.insert(
        date: response.date,
        promptId: response.promptId,
        answer: response.answer.name,
        sourceIds: jsonEncode(response.sourceIds),
        note: Value(response.note),
        createdAt: Value(response.createdAt),
        updatedAt: response.updatedAt,
      ),
    );
  }

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
