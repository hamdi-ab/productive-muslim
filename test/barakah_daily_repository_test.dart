import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/repositories/barakah_repository_impl.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart' as legacy;
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';

class _VersionOneDatabase extends AppDatabase {
  _VersionOneDatabase(super.e) : super.forTesting();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      for (final table in allTables) {
        if (table.actualTableName != 'barakah_daily_responses') {
          await m.createTable(table);
        }
      }
    },
  );
}

BarakahDailyResponse _response({
  String date = '1970-01-01',
  String promptId = 'good_intentions_v1',
  BarakahAnswer answer = BarakahAnswer.yes,
  List<String> sourceIds = const ['good_intentions'],
  String? note,
  int createdAt = 100,
  int updatedAt = 100,
}) => BarakahDailyResponse(
  date: date,
  promptId: promptId,
  answer: answer,
  sourceIds: sourceIds,
  note: note,
  createdAt: createdAt,
  updatedAt: updatedAt,
);

void main() {
  late AppDatabase database;
  late BarakahRepository repository;

  group('in-memory repository', () {
    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = BarakahRepositoryImpl(barakahDao: database.barakahDao);
    });

    tearDown(() => database.close());

    test('watch emits absent, inserted and edited responses', () async {
      final initial = _response(note: 'Initial');
      final edited = _response(
        answer: BarakahAnswer.somewhat,
        note: 'Edited',
        createdAt: 999,
        updatedAt: 200,
      );
      final expectation = expectLater(
        repository.watchDailyResponse(initial.date),
        emitsInOrder([
          isNull,
          isA<BarakahDailyResponse>()
              .having((r) => r.answer, 'answer', BarakahAnswer.yes)
              .having((r) => r.note, 'note', 'Initial'),
          isA<BarakahDailyResponse>()
              .having((r) => r.answer, 'answer', BarakahAnswer.somewhat)
              .having((r) => r.note, 'note', 'Edited')
              .having((r) => r.createdAt, 'createdAt', 100)
              .having((r) => r.updatedAt, 'updatedAt', 200),
        ]),
      );
      await repository.watchDailyResponse(initial.date).first;
      await repository.saveDailyResponse(initial);
      await repository
          .watchDailyResponse(initial.date)
          .firstWhere((r) => r != null);
      await repository.saveDailyResponse(edited);
      await expectation;
      expect(
        await database.select(database.barakahDailyResponses).get(),
        hasLength(1),
      );
    });

    test(
      'upsert persists all answers and clears nullable notes and sources',
      () async {
        await repository.saveDailyResponse(_response(note: 'Before'));
        for (final answer in BarakahAnswer.values) {
          final sources =
              answer == BarakahAnswer.no || answer == BarakahAnswer.skip
              ? <String>[]
              : ['good_intentions'];
          await repository.saveDailyResponse(
            _response(
              answer: answer,
              sourceIds: sources,
              createdAt: 999,
              updatedAt: 200 + answer.index,
            ),
          );
          final saved = (await repository
              .watchDailyResponse('1970-01-01')
              .first)!;
          expect(saved.answer, answer);
          expect(saved.sourceIds, sources);
          expect(saved.note, isNull);
          expect(saved.createdAt, 100);
          expect(saved.updatedAt, 200 + answer.index);
          expect(saved.promptId, 'good_intentions_v1');
          final row = await database
              .select(database.barakahDailyResponses)
              .getSingle();
          expect(jsonDecode(row.sourceIds), sources);
          expect(row.answer, answer.name);
        }
      },
    );

    test(
      'dates are independent and concurrent edits keep one original row',
      () async {
        await repository.saveDailyResponse(_response());
        await Future.wait([
          for (var i = 1; i <= 10; i++)
            repository.saveDailyResponse(
              _response(note: '$i', createdAt: 1000 + i, updatedAt: 200 + i),
            ),
        ]);
        await repository.saveDailyResponse(
          _response(
            date: '1970-01-02',
            promptId: 'piety_v1',
            sourceIds: ['piety'],
          ),
        );
        final rows = await database
            .select(database.barakahDailyResponses)
            .get();
        expect(rows, hasLength(2));
        final first = (await repository
            .watchDailyResponse('1970-01-01')
            .first)!;
        expect(first.createdAt, 100);
        expect(first.promptId, 'good_intentions_v1');
        expect(await repository.watchDailyResponse('1970-01-03').first, isNull);
      },
    );

    test(
      'validates mappings, duplicates, dates, answers and note length',
      () async {
        final invalid = [
          _response(date: '2026-02-30'),
          _response(date: '2026-09-17T00:00:00Z'),
          _response(promptId: 'unknown_v1'),
          _response(promptId: 'good_intentions_v2'),
          _response(sourceIds: ['unknown']),
          _response(sourceIds: ['piety']),
          _response(sourceIds: ['good_intentions', 'good_intentions']),
          _response(answer: BarakahAnswer.no),
          _response(answer: BarakahAnswer.skip),
          _response(note: 'x' * 281),
          _response(note: 'a\u0301' * 281),
        ];
        for (final response in invalid) {
          await expectLater(
            repository.saveDailyResponse(response),
            throwsArgumentError,
          );
        }
        expect(
          await database.select(database.barakahDailyResponses).get(),
          isEmpty,
        );
        expect(
          () => repository.watchDailyResponse('2026-02-30'),
          throwsArgumentError,
        );
      },
    );

    test('notes use grapheme clusters rather than code units', () async {
      for (final character in [
        'a',
        'a\u0301',
        '\u{1F468}\u200D\u{1F469}\u200D\u{1F467}',
      ]) {
        final note = character * 280;
        await repository.saveDailyResponse(_response(note: note));
        expect(
          (await repository.watchDailyResponse('1970-01-01').first)!.note,
          note,
        );
        await expectLater(
          repository.saveDailyResponse(_response(note: '$note$character')),
          throwsArgumentError,
        );
      }
    });

    test(
      'rejects a changed prompt without changing the initial response',
      () async {
        await repository.saveDailyResponse(_response(note: 'Original'));
        await expectLater(
          repository.saveDailyResponse(
            _response(
              promptId: 'piety_v1',
              sourceIds: ['piety'],
              note: 'Replacement',
            ),
          ),
          throwsArgumentError,
        );
        final saved = (await repository
            .watchDailyResponse('1970-01-01')
            .first)!;
        expect(saved.promptId, 'good_intentions_v1');
        expect(saved.sourceIds, ['good_intentions']);
        expect(saved.note, 'Original');
        expect(saved.createdAt, 100);
        expect(saved.updatedAt, 100);
      },
    );

    test('invalid edits leave the saved response intact', () async {
      await repository.saveDailyResponse(_response(note: 'Original'));
      await expectLater(
        repository.saveDailyResponse(_response(answer: BarakahAnswer.no)),
        throwsArgumentError,
      );
      expect(
        (await repository.watchDailyResponse('1970-01-01').first)!.note,
        'Original',
      );
    });
  });

  test('daily response survives closing and reopening the database', () async {
    final directory = await Directory.systemTemp.createTemp(
      'barakah_daily_test_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/database.sqlite');
    final first = AppDatabase.forTesting(NativeDatabase(file));
    try {
      await BarakahRepositoryImpl(barakahDao: first.barakahDao)
          .saveDailyResponse(_response(note: 'Persistent'));
    } finally {
      await first.close();
    }
    final reopened = AppDatabase.forTesting(NativeDatabase(file));
    try {
      final saved = (await BarakahRepositoryImpl(
        barakahDao: reopened.barakahDao,
      ).watchDailyResponse('1970-01-01').first)!;
      expect(saved.date, '1970-01-01');
      expect(saved.promptId, 'good_intentions_v1');
      expect(saved.answer, BarakahAnswer.yes);
      expect(saved.sourceIds, ['good_intentions']);
      expect(saved.note, 'Persistent');
      expect(saved.createdAt, 100);
      expect(saved.updatedAt, 100);
    } finally {
      await reopened.close();
    }
  });

  test(
    'v1 upgrade adds only daily responses and preserves legacy data and APIs',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'barakah_upgrade_test_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/database.sqlite');
      final v1 = _VersionOneDatabase(NativeDatabase(file));
      late Map<String, List<Map<String, dynamic>>> before;
      try {
        await v1
            .into(v1.barakahEntries)
            .insert(
              BarakahEntriesCompanion.insert(
                date: '1970-01-01',
                sourceIds: 'Charity,Dua',
                promptId: const Value('legacy'),
                intensity: const Value(3),
                note: const Value('Legacy note'),
                skipped: const Value(1),
                createdAt: const Value(42),
              ),
            );
        await v1
            .into(v1.barakahPrompts)
            .insert(
              BarakahPromptsCompanion.insert(
                sourceIds: 'Charity',
                question: 'Legacy question',
                displayOrder: 7,
              ),
            );
        await v1
            .into(v1.habits)
            .insert(
              HabitsCompanion.insert(name: 'Habit', category: 'spiritual'),
            );
        await v1
            .into(v1.tasks)
            .insert(
              TasksCompanion.insert(
                title: 'Task',
                lifeArea: 'islam',
                date: '1970-01-01',
              ),
            );
        await v1
            .into(v1.intentionEntries)
            .insert(
              IntentionEntriesCompanion.insert(
                date: '1970-01-01',
                title: 'Intention',
              ),
            );
        before = await _legacySnapshot(v1);
      } finally {
        await v1.close();
      }
      final upgraded = AppDatabase.forTesting(NativeDatabase(file));
      try {
        final repo = BarakahRepositoryImpl(barakahDao: upgraded.barakahDao);
        expect(await repo.watchDailyResponse('1970-01-01').first, isNull);
        expect(await _legacySnapshot(upgraded), before);
        await repo.saveDailyResponse(_response());
        expect(await _legacySnapshot(upgraded), before);
        final entries = await repo.getEntriesForDate('1970-01-01');
        expect(entries, hasLength(1));
        expect(entries.single.sourceIds, ['Charity', 'Dua']);
        expect(entries.single.promptId, 'legacy');
        expect(entries.single.intensity, 3);
        expect(entries.single.note, 'Legacy note');
        expect(entries.single.skipped, isTrue);
        expect(entries.single.createdAt, 42);
        expect(
          await repo.getEntriesForRange('1969-01-01', '1971-01-01'),
          hasLength(1),
        );
        expect(
          await repo.watchEntriesForDate('1970-01-01').first,
          hasLength(1),
        );
        expect(
          await repo.updateEntry(
            entries.single.copyWith(note: 'Edited legacy'),
          ),
          isTrue,
        );
        expect(
          (await repo.getEntryById(entries.single.id))!.note,
          'Edited legacy',
        );
        final id = await repo.insertEntry(
          const legacy.BarakahEntry(
            id: 0,
            date: '1970-01-02',
            sourceIds: ['Dua'],
            createdAt: 50,
          ),
        );
        expect(await repo.deleteEntry(id), 1);
        expect(await repo.getEntryById(id), isNull);
        expect(await repo.watchDailyResponse('1970-01-01').first, isNotNull);
      } finally {
        await upgraded.close();
      }
    },
  );
}

Future<Map<String, List<Map<String, dynamic>>>> _legacySnapshot(
  AppDatabase db,
) async {
  return {
    for (final table in db.allTables)
      if (table.actualTableName != 'barakah_daily_responses')
        table.actualTableName: [
          for (final row in await db.select(table).get())
            (row as DataClass).toJson(),
        ],
  };
}
