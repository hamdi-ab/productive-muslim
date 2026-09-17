import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/repositories/barakah_repository_impl.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart' as legacy;
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';

void main() {
  late AppDatabase database;
  late BarakahRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = BarakahRepositoryImpl(barakahDao: database.barakahDao);
  });
  tearDown(() => database.close());

  BarakahDailyResponse response(String date, {String? note}) =>
      BarakahDailyResponse(
        date: date,
        promptId: 'good_intentions_v1',
        answer: BarakahAnswer.yes,
        sourceIds: ['good_intentions'],
        note: note,
        createdAt: 1,
        updatedAt: 2,
      );

  test(
    'range includes both endpoints, sorts by date and excludes legacy rows',
    () async {
      for (final date in [
        '2026-09-21',
        '2026-09-20',
        '2026-09-17',
        '2026-09-14',
        '2026-09-13',
      ]) {
        await repository.saveDailyResponse(response(date));
      }
      await repository.insertEntry(
        legacy.BarakahEntry(
          id: 0,
          date: '2026-09-15',
          sourceIds: [],
          createdAt: 3,
        ),
      );
      final rows = await repository
          .watchDailyResponsesForRange('2026-09-14', '2026-09-20')
          .first;
      expect(rows.map((row) => row.date), [
        '2026-09-14',
        '2026-09-17',
        '2026-09-20',
      ]);
      expect(
        await repository
            .watchDailyResponsesForRange('2026-09-14', '2026-09-14')
            .first,
        hasLength(1),
      );
      expect(
        await repository
            .watchDailyResponsesForRange('2026-09-01', '2026-09-07')
            .first,
        isEmpty,
      );
    },
  );

  test(
    'one active range subscription emits inserts and edits with notes',
    () async {
      final queue = StreamIterator(
        repository.watchDailyResponsesForRange('2026-09-14', '2026-09-20'),
      );
      addTearDown(queue.cancel);
      expect(await queue.moveNext(), isTrue);
      expect(queue.current, isEmpty);
      await repository.saveDailyResponse(response('2026-09-14', note: 'First'));
      expect(await queue.moveNext(), isTrue);
      expect(queue.current.single.note, 'First');
      await repository.saveDailyResponse(
        response('2026-09-14', note: 'Edited'),
      );
      expect(await queue.moveNext(), isTrue);
      expect(queue.current.single.note, 'Edited');
      await repository.saveDailyResponse(
        response('2026-09-20', note: 'Sunday'),
      );
      expect(await queue.moveNext(), isTrue);
      expect(queue.current.map((r) => r.date), ['2026-09-14', '2026-09-20']);
    },
  );

  test(
    'reads unknown historical prompt and source IDs without catalog lookup',
    () async {
      await database
          .into(database.barakahDailyResponses)
          .insert(
            BarakahDailyResponsesCompanion.insert(
              date: '2026-09-14',
              promptId: 'retired_v0',
              answer: 'skip',
              sourceIds: '["retired_source"]',
              note: const Value('Historical note'),
              updatedAt: 1,
            ),
          );
      final row =
          (await repository
                  .watchDailyResponsesForRange('2026-09-14', '2026-09-20')
                  .first)
              .single;
      expect(row.promptId, 'retired_v0');
      expect(row.sourceIds, ['retired_source']);
      expect(row.answer, BarakahAnswer.skip);
      expect(row.note, 'Historical note');
    },
  );

  test('rejects invalid and reversed endpoints', () {
    for (final (start, end) in [
      ('2026-02-30', '2026-03-01'),
      ('2026-02-01', '2026-02-30'),
      ('2026-09-20', '2026-09-14'),
      ('2026-9-14', '2026-09-20'),
    ]) {
      expect(
        () => repository.watchDailyResponsesForRange(start, end),
        throwsArgumentError,
      );
    }
  });
}
