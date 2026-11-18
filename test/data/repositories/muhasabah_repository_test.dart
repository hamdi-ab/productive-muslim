import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/repositories/muhasabah_repository_impl.dart';
import 'package:productive_muslim/domain/models/muhasabah_entry.dart';
import 'package:productive_muslim/domain/repositories/muhasabah_repository.dart';

void main() {
  late AppDatabase db;
  late MuhasabahRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = MuhasabahRepositoryImpl(muhasabahDao: db.muhasabahDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('MuhasabahRepository insert, watch, get, update, and delete', () async {
    final entry = MuhasabahEntry(
      id: 0,
      date: '2026-11-18',
      promptId: 'gratitude_v1',
      promptText: 'What are you grateful for today?',
      content: 'Alhamdulillah for another day of good health.',
      tags: '#Shukr',
      createdAt: 1700000000000,
      updatedAt: 1700000000000,
    );

    // Insert
    final id = await repository.insertEntry(entry);
    expect(id, greaterThan(0));

    // Get by ID
    final fetched = await repository.getEntryById(id);
    expect(fetched, isNotNull);
    expect(
      fetched!.content,
      equals('Alhamdulillah for another day of good health.'),
    );
    expect(fetched.tags, equals('#Shukr'));

    // Get for date
    final dateEntries = await repository.getEntriesForDate('2026-11-18');
    expect(dateEntries.length, equals(1));

    // Update
    final updated = fetched.copyWith(
      content:
          'Alhamdulillah for another day of good health and peace of mind.',
      updatedAt: 1700000005000,
    );
    final success = await repository.updateEntry(updated);
    expect(success, isTrue);

    final refetched = await repository.getEntryById(id);
    expect(refetched!.content, contains('peace of mind'));

    // Range
    final rangeEntries = await repository.getEntriesForRange(
      '2026-11-01',
      '2026-11-30',
    );
    expect(rangeEntries.length, equals(1));

    // Delete
    final deletedCount = await repository.deleteEntry(id);
    expect(deletedCount, equals(1));

    final emptyEntries = await repository.getEntriesForDate('2026-11-18');
    expect(emptyEntries, isEmpty);
  });
}
