import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/local/daos/adhkar_dao.dart';
import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/repositories/adhkar_repository_impl.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs: prefs);
    getIt.registerSingleton<SettingsService>(settingsService);

    db = AppDatabase.forTesting(NativeDatabase.memory());
    final dao = AdhkarDao(db);
    final repo = AdhkarRepositoryImpl(
      adhkarDao: dao,
      settingsService: settingsService,
    );
    getIt.registerSingleton<AppDatabase>(db);
    getIt.registerSingleton<AdhkarDao>(dao);
    getIt.registerSingleton<AdhkarRepository>(repo);

    getIt.registerSingleton<AdhkarService>(
      AdhkarService(settingsService: settingsService, adhkarRepository: repo),
    );
  });

  tearDown(() async {
    await db.close();
    await getIt.reset();
  });

  Widget buildSubject({DhikrCategory initialCategory = DhikrCategory.morning}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AdhkarScreen(initialCategory: initialCategory),
    );
  }

  testWidgets(
    'renders Adhkar screen with category tabs, Arabic card and counter',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(initialCategory: DhikrCategory.morning),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Adhkar & Remembrances'), findsOneWidget);
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);
      expect(find.text('Waking Up Remembrance'), findsOneWidget);
      expect(find.text('Tap anywhere to count'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping full-screen tap area increments count and records completion',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(initialCategory: DhikrCategory.wakingUp),
      );
      await tester.pumpAndSettle();

      expect(find.text('0 / 1'), findsOneWidget);

      final tapArea = find.text('Tap anywhere to count');
      expect(tapArea, findsOneWidget);

      // Tap once to complete the 1-count dhikr
      await tester.tap(tapArea);
      await tester.pump(); // immediate frame

      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.text('Completed! Alhamdulillah'), findsOneWidget);

      // After 600ms + animation, auto-advances to card 2
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(getIt<AdhkarService>().isDhikrCompleted('wake_up_1'), isTrue);
      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.text('Affirmation of Tawheed upon Waking'), findsOneWidget);
    },
  );

  testWidgets('switching category tabs updates the dhikr list', (tester) async {
    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.morning),
    );
    await tester.pumpAndSettle();

    final eveningTab = find.text('Evening');
    expect(eveningTab, findsOneWidget);

    await tester.tap(eveningTab);
    await tester.pumpAndSettle();

    expect(find.text('Entering the Evening Supplication'), findsOneWidget);
  });

  testWidgets('restores persisted counts and completed state on init', (
    tester,
  ) async {
    final adhkarService = getIt<AdhkarService>();
    await adhkarService.recordDhikrCompletion(dhikrId: 'wake_up_1');

    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.wakingUp),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('Completed! Alhamdulillah'), findsOneWidget);
  });

  testWidgets('reset button on card resets count and removes completion', (
    tester,
  ) async {
    final adhkarService = getIt<AdhkarService>();
    await adhkarService.recordDhikrCompletion(dhikrId: 'wake_up_1');

    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.wakingUp),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 1'), findsOneWidget);

    final resetBtn = find.byTooltip('Reset Count');
    expect(resetBtn, findsOneWidget);
    await tester.tap(resetBtn);
    await tester.pumpAndSettle();

    expect(find.text('0 / 1'), findsOneWidget);
    expect(adhkarService.isDhikrCompleted('wake_up_1'), isFalse);
  });

  testWidgets('reset category button resets all items in the category', (
    tester,
  ) async {
    final adhkarService = getIt<AdhkarService>();
    await adhkarService.recordDhikrCompletion(dhikrId: 'wake_up_1');
    await adhkarService.recordDhikrCompletion(dhikrId: 'wake_up_2');

    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.wakingUp),
    );
    await tester.pumpAndSettle();

    expect(adhkarService.isDhikrCompleted('wake_up_1'), isTrue);
    expect(adhkarService.isDhikrCompleted('wake_up_2'), isTrue);

    final resetCategoryBtn = find.byTooltip('Reset Category');
    expect(resetCategoryBtn, findsOneWidget);
    await tester.tap(resetCategoryBtn);
    await tester.pumpAndSettle();

    expect(find.text('0 / 1'), findsOneWidget);
    expect(adhkarService.isDhikrCompleted('wake_up_1'), isFalse);
    expect(adhkarService.isDhikrCompleted('wake_up_2'), isFalse);
  });

  testWidgets('transliteration toggle hides and shows transliteration text', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.wakingUp),
    );
    await tester.pumpAndSettle();

    // Default: transliteration is hidden
    expect(find.textContaining('Alhamdu lillahil-ladhi ahyana'), findsNothing);

    // Tap toggle transliteration
    final toggleBtn = find.byTooltip('Toggle transliteration');
    expect(toggleBtn, findsOneWidget);
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();

    // Transliteration is now visible
    expect(
      find.textContaining('Alhamdu lillahil-ladhi ahyana'),
      findsOneWidget,
    );

    // Tap toggle again
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining('Alhamdu lillahil-ladhi ahyana'), findsNothing);
  });

  testWidgets('bookmarks tab shows empty state then displays bookmarked item', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.wakingUp),
    );
    await tester.pumpAndSettle();

    // Bookmark the first item
    final bookmarkBtn = find.byTooltip('Bookmark dhikr');
    expect(bookmarkBtn, findsOneWidget);
    await tester.tap(bookmarkBtn);
    await tester.pumpAndSettle();

    // Switch to Bookmarks tab
    final bookmarksTab = find.text('Bookmarks');
    expect(bookmarksTab, findsOneWidget);
    await tester.ensureVisible(bookmarksTab);
    await tester.tap(bookmarksTab);
    await tester.pumpAndSettle();

    // The bookmarked waking up dhikr is shown in the bookmarks view
    expect(find.text('Waking Up Remembrance'), findsOneWidget);
  });

  testWidgets('general dhikr collection tab displays general dhikr items', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.general),
    );
    await tester.pumpAndSettle();

    expect(find.text('Glory and Praise be to Allah'), findsOneWidget);
    expect(find.textContaining('Muslim 2692'), findsOneWidget);
  });
}
