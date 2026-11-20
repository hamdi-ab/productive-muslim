import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/local/daos/adhkar_dao.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/repositories/adhkar_repository_impl.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/models/tasbih_state.dart';

void main() {
  late AppDatabase db;
  late AdhkarDao dao;
  late AdhkarRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = AdhkarDao(db);
    repo = AdhkarRepositoryImpl(adhkarDao: dao);
  });

  tearDown(() async {
    await db.close();
  });

  group('AdhkarRepository Tasbih operations', () {
    test('returns initial state when no record exists', () async {
      final state = await repo.getTasbihState();
      expect(state.currentCount, 0);
      expect(state.targetCount, isNull);
      expect(state.dhikrId, isNull);
      expect(state.customLabel, isNull);
      expect(state.lastCount, isNull);
      expect(state.hasTarget, isFalse);
      expect(state.isTargetReached, isFalse);
    });

    test('saves and retrieves updated TasbihState', () async {
      final now = DateTime.now();
      final newState = TasbihState(
        currentCount: 33,
        targetCount: 100,
        dhikrId: 'subhanallah_wa_bihamdihi',
        customLabel: null,
        lastCount: 32,
        updatedAt: now,
      );

      await repo.saveTasbihState(newState);

      final loaded = await repo.getTasbihState();
      expect(loaded.currentCount, 33);
      expect(loaded.targetCount, 100);
      expect(loaded.dhikrId, 'subhanallah_wa_bihamdihi');
      expect(loaded.customLabel, isNull);
      expect(loaded.lastCount, 32);
      expect(loaded.hasTarget, isTrue);
      expect(loaded.isTargetReached, isFalse);
    });

    test(
      'reaches target when currentCount meets or exceeds targetCount',
      () async {
        final now = DateTime.now();
        final targetMetState = TasbihState(
          currentCount: 33,
          targetCount: 33,
          dhikrId: null,
          customLabel: 'Istighfar',
          updatedAt: now,
        );

        await repo.saveTasbihState(targetMetState);

        final loaded = await repo.getTasbihState();
        expect(loaded.isTargetReached, isTrue);
        expect(loaded.hasCustomLabel, isTrue);
        expect(loaded.customLabel, 'Istighfar');
      },
    );

    test(
      'resets count to 0 while preserving target and remembrance label',
      () async {
        final now = DateTime.now();
        final state = TasbihState(
          currentCount: 45,
          targetCount: 100,
          dhikrId: 'alhamdulillah',
          customLabel: 'My Label',
          lastCount: 44,
          updatedAt: now,
        );

        await repo.saveTasbihState(state);
        await repo.resetTasbihCount();

        final resetState = await repo.getTasbihState();
        expect(resetState.currentCount, 0);
        expect(resetState.lastCount, isNull);
        // Preserves configuration
        expect(resetState.targetCount, 100);
        expect(resetState.dhikrId, 'alhamdulillah');
        expect(resetState.customLabel, 'My Label');
      },
    );

    test('watches Tasbih state stream reactively', () async {
      final stream = repo.watchTasbihState();
      expect(
        stream,
        emitsInOrder([
          predicate<TasbihState>((s) => s.currentCount == 0),
          predicate<TasbihState>((s) => s.currentCount == 1),
          predicate<TasbihState>((s) => s.currentCount == 2),
        ]),
      );

      await Future.delayed(const Duration(milliseconds: 20));
      await repo.saveTasbihState(
        TasbihState(currentCount: 1, updatedAt: DateTime.now()),
      );
      await Future.delayed(const Duration(milliseconds: 20));
      await repo.saveTasbihState(
        TasbihState(currentCount: 2, updatedAt: DateTime.now()),
      );
    });

    test('tasbih operations are strictly isolated from official sessions and routines', () async {
      // 1. Establish official session and routine session
      await repo.saveSession(
        collectionId: DhikrCategory.morning.name,
        lastPageIndex: 1,
        counts: {'morning_1': 3},
      );
      await dao.saveRoutine(
        id: 'routine_test',
        name: 'Test Routine',
        itemIdsJson: '["item_1"]',
        createdAt: 1000,
        updatedAt: 1000,
      );
      await repo.saveSession(
        collectionId: 'routine_routine_test',
        lastPageIndex: 0,
        counts: {'item_1': 1},
      );

      // 2. Perform Tasbih counter updates and reset
      await repo.saveTasbihState(
        TasbihState(
          currentCount: 100,
          targetCount: 100,
          dhikrId: 'morning_1',
          updatedAt: DateTime.now(),
        ),
      );
      await repo.resetTasbihCount();

      // 3. Verify official session remains completely unmodified
      final morningSession = await repo.getSession(DhikrCategory.morning.name);
      expect(morningSession, isNotNull);
      expect(morningSession!.lastPageIndex, 1);
      expect(morningSession.counts['morning_1'], 3);

      // 4. Verify routine session remains unmodified
      final routineSession = await repo.getSession('routine_routine_test');
      expect(routineSession, isNotNull);
      expect(routineSession!.lastPageIndex, 0);
      expect(routineSession.counts['item_1'], 1);

      // 5. Verify no routine or collection completions were generated
      final completions = await repo.getCompletedCollectionIdsForDate(
        '2026-11-20',
      );
      expect(completions, isEmpty);
      final routineCompletions = await repo.getRoutineCompletionsForDate(
        '2026-11-20',
      );
      expect(routineCompletions, isEmpty);
    });
  });
}
