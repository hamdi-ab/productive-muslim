import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/local/daos/adhkar_dao.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/repositories/adhkar_repository_impl.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/adhkar_routine.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_routine_edit_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_routines_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_retired_item_card.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_routine_card.dart';

import '../../helpers/overflow_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs: prefs);
    getIt.registerSingleton<SettingsService>(settingsService);

    db = AppDatabase.forTesting(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    final dao = AdhkarDao(db);
    final repo = AdhkarRepositoryImpl(
      adhkarDao: dao,
      settingsService: settingsService,
    );
    getIt.registerSingleton<AppDatabase>(db);
    getIt.registerSingleton<AdhkarDao>(dao);
    getIt.registerSingleton<AdhkarRepository>(repo);
  });

  tearDown(() async {
    await db.close();
    await getIt.reset();
  });

  group('Adhkar Routines RTL and Text Scale Resilience', () {
    testWidgets(
      'AdhkarRoutinesScreen has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const AdhkarRoutinesScreen(),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
          wrapInScrollView: false,
        );
      },
    );

    testWidgets(
      'AdhkarRoutineEditScreen has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const SizedBox(height: 900, child: AdhkarRoutineEditScreen()),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'AdhkarRetiredItemCard has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: SizedBox(
            height: 500,
            child: AdhkarRetiredItemCard(
              itemId: 'long_retired_dhikr_item_id_identifier',
              onSkip: () {},
              onReplace: () {},
              onExit: () {},
            ),
          ),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );

    testWidgets(
      'AdhkarRoutineCard has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        final now = DateTime.now();
        final routine = AdhkarRoutine(
          id: 'routine_card_overflow_test',
          name: 'ورد الصباح الطويل مع الكثير من التفاصيل',
          itemIds: ['item_1', 'item_2', 'item_3'],
          preferredTime: '06:30',
          weekdays: [1, 2, 3, 4, 5, 6, 7],
          createdAt: now,
          updatedAt: now,
        );

        await pumpAndCheckOverflow(
          tester,
          child: SizedBox(
            height: 350,
            child: AdhkarRoutineCard(
              routine: routine,
              isCompletedToday: true,
              hasActiveSession: true,
              onStartOrContinue: () {},
            ),
          ),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
        );
      },
    );
  });
}
