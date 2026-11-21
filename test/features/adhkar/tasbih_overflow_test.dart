import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/local/daos/adhkar_dao.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/repositories/adhkar_repository_impl.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/models/tasbih_state.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/tasbih_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_category_tabs.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

import '../../helpers/overflow_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late AdhkarRepository repo;

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
    repo = AdhkarRepositoryImpl(
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

  group('Tasbih RTL and Text Scale Resilience', () {
    testWidgets(
      'TasbihScreen in free counter mode has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: const TasbihScreen(),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
          wrapInScrollView: false,
        );
      },
    );

    testWidgets(
      'TasbihScreen with approved library item and target reached has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await repo.setReviewModeEnabled(true);
        final item = AdhkarCatalog.all.first;
        await repo.saveTasbihState(
          TasbihState(
            currentCount: 33,
            targetCount: 33,
            dhikrId: item.id,
            updatedAt: DateTime.now(),
          ),
        );

        await pumpAndCheckOverflow(
          tester,
          child: const TasbihScreen(isReviewModeEnabled: true),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
          wrapInScrollView: false,
        );
      },
    );

    testWidgets(
      'TasbihScreen with custom personal label has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await repo.saveTasbihState(
          TasbihState(
            currentCount: 150,
            targetCount: 500,
            customLabel:
                'دعاء وتضرع شخصي طويل للتجربة والتأكد من عدم وجود تجاوزات',
            updatedAt: DateTime.now(),
          ),
        );

        await pumpAndCheckOverflow(
          tester,
          child: const TasbihScreen(),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: true,
          screenSize: const Size(360, 780),
          wrapInScrollView: false,
        );
      },
    );

    testWidgets(
      'TasbihScreen with retired item warning card has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await repo.saveTasbihState(
          TasbihState(
            currentCount: 10,
            dhikrId: 'retired_item_id_not_in_library',
            updatedAt: DateTime.now(),
          ),
        );

        await pumpAndCheckOverflow(
          tester,
          child: const TasbihScreen(isReviewModeEnabled: false),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
          wrapInScrollView: false,
        );
      },
    );

    testWidgets(
      'AdhkarCategoryTabs with Tasbih chip has zero overflow at 1.5x scale in Arabic RTL',
      (tester) async {
        await pumpAndCheckOverflow(
          tester,
          child: Scaffold(
            body: Builder(
              builder: (context) => AdhkarCategoryTabs(
                selectedCategory: DhikrCategory.morning,
                onCategorySelected: (_) {},
                onBookmarksSelected: () {},
                onRoutinesSelected: () {},
                onExploreTap: () {},
                onTasbihTap: () {},
                l10n: AppLocalizations.of(context)!,
                isDark: false,
              ),
            ),
          ),
          locale: const Locale('ar'),
          textScale: 1.5,
          isDark: false,
          screenSize: const Size(360, 780),
          wrapInScrollView: false,
        );
      },
    );
  });
}
