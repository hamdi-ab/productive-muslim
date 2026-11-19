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
import 'package:productive_muslim/features/adhkar/presentation/widgets/adhkar_collection_completion_card.dart';
import 'package:productive_muslim/features/adhkar/presentation/widgets/dhikr_card.dart';
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

  Widget buildSubject({
    DhikrCategory initialCategory = DhikrCategory.morning,
    bool isReviewModeEnabled = true,
    bool? isInternalReviewAvailable,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AdhkarScreen(
        initialCategory: initialCategory,
        isReviewModeEnabled: isReviewModeEnabled,
        isInternalReviewAvailable: isInternalReviewAvailable,
      ),
    );
  }

  testWidgets(
    'renders Adhkar screen with Content Under Editorial Review by default and reveals review mode on toggle',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(
          initialCategory: DhikrCategory.morning,
          isReviewModeEnabled: false,
          isInternalReviewAvailable: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Adhkar & Remembrances'), findsOneWidget);

      // Phase 1 essential collections strictly present
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);
      expect(find.text('Post-Salah'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Bookmarks'), findsOneWidget);

      // Default state: Content Under Editorial Review (unreviewed texts withheld)
      expect(find.text('Content Under Editorial Review'), findsOneWidget);
      expect(find.text('Preview Draft Content'), findsOneWidget);
      expect(find.byKey(const Key('adhkar_review_mode_banner')), findsNothing);

      // Tap Preview Draft Content button to enter review mode
      await tester.tap(find.text('Preview Draft Content'));
      await tester.pumpAndSettle();

      // In Review Mode: Review banner appears and draft items are shown with Pending Review badge
      expect(
        find.byKey(const Key('adhkar_review_mode_banner')),
        findsOneWidget,
      );
      expect(find.text('Pending Review'), findsOneWidget);
      expect(find.text('Authentic'), findsNothing);
      expect(find.text('Prescribed'), findsOneWidget);
      expect(find.textContaining('Tap anywhere to count'), findsOneWidget);
    },
  );

  testWidgets(
    'ordinary user build strictly hides review toggles and draft preview action',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(
          initialCategory: DhikrCategory.morning,
          isReviewModeEnabled: false,
          isInternalReviewAvailable: false,
        ),
      );
      await tester.pumpAndSettle();

      // Content Under Editorial Review message is present
      expect(find.text('Content Under Editorial Review'), findsOneWidget);
      expect(find.textContaining('undergoing verification'), findsOneWidget);

      // Ordinary users NEVER see review toggles or draft preview buttons
      expect(find.text('Preview Draft Content'), findsNothing);
      expect(
        find.byKey(const Key('adhkar_enable_review_mode_button')),
        findsNothing,
      );
      expect(find.byTooltip('Editorial Review Mode'), findsNothing);
      expect(find.byTooltip('Exit Review Mode'), findsNothing);
      expect(find.byKey(const Key('adhkar_review_mode_banner')), findsNothing);
      expect(
        find.byKey(const Key('adhkar_review_mode_toggle_shell')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'pending item bookmarked in review mode does NOT appear in Bookmarks view when review mode is off',
    (tester) async {
      // 1. Start with review mode enabled to bookmark a pending item
      await tester.pumpWidget(
        buildSubject(
          initialCategory: DhikrCategory.morning,
          isReviewModeEnabled: true,
          isInternalReviewAvailable: true,
        ),
      );
      await tester.pumpAndSettle();

      // Bookmark the pending item
      final bookmarkBtn = find.byTooltip('Bookmark dhikr');
      expect(bookmarkBtn, findsOneWidget);
      await tester.tap(bookmarkBtn);
      await tester.pumpAndSettle();

      // 2. Now toggle review mode OFF via the banner close button
      final closeReviewBannerBtn = find.descendant(
        of: find.byKey(const Key('adhkar_review_mode_banner')),
        matching: find.byIcon(Icons.close_rounded),
      );
      expect(closeReviewBannerBtn, findsOneWidget);
      await tester.tap(closeReviewBannerBtn);
      await tester.pumpAndSettle();

      // 3. Switch to Bookmarks tab
      final bookmarksTab = find.text('Bookmarks');
      expect(bookmarksTab, findsOneWidget);
      await tester.ensureVisible(bookmarksTab);
      await tester.tap(bookmarksTab);
      await tester.pumpAndSettle();

      // 4. In normal mode (review mode off), pending item MUST NOT appear in Bookmarks view!
      expect(find.text('Waking Up Remembrance'), findsNothing);
      expect(find.textContaining('No bookmarked adhkar yet'), findsOneWidget);
    },
  );

  testWidgets(
    'DhikrCard displays Authentic badge when item reviewStatus is approved',
    (tester) async {
      const approvedItem = DhikrItem(
        id: 'test_approved',
        category: DhikrCategory.morning,
        titleEn: 'Approved Dhikr',
        titleAr: 'ذكر معتمد',
        arabic: 'سبحان الله',
        transliteration: 'SubhanAllah',
        translationEn: 'Glory be to Allah',
        translationAr: 'سبحان الله',
        reference: 'Sahih Muslim',
        virtue: 'Virtue',
        targetCount: 3,
        reviewStatus: ContentReviewStatus.approved,
        isCountPrescribed: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DhikrCard(
              item: approvedItem,
              count: 0,
              onTap: () {},
              onReset: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Authentic'), findsOneWidget);
      expect(find.text('Pending Review'), findsNothing);
    },
  );

  testWidgets('tapping tap area increments count with NO forced auto-advance', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.morning),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 / 1'), findsOneWidget);
    expect(find.text('Waking Up Remembrance'), findsOneWidget);

    final tapArea = find.text('Tap anywhere to count');
    expect(tapArea, findsOneWidget);

    // Tap once to complete the 1-count dhikr
    await tester.tap(tapArea);
    await tester.pump(); // immediate frame

    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('Completed! Alhamdulillah'), findsOneWidget);

    // NO forced progression: user stays on card 1 to reflect calmly
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.text('Waking Up Remembrance'), findsOneWidget);
    expect(find.text('1 / 7'), findsOneWidget);
  });

  testWidgets(
    'general dhikr items display Pending Review badge and target count classification',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(initialCategory: DhikrCategory.general),
      );
      await tester.pumpAndSettle();

      expect(find.text('Glory and Praise be to Allah'), findsOneWidget);
      expect(find.textContaining('Muslim 2692'), findsOneWidget);

      // Unreviewed General Dhikr must show Pending Review badge instead of Authentic
      expect(find.text('Pending Review'), findsOneWidget);
      expect(find.text('Authentic'), findsNothing);

      // Muslim 2692 specifies 100 times, so it is Prescribed
      expect(find.text('Prescribed'), findsOneWidget);
    },
  );

  testWidgets(
    'general istighfar displays Target badge rather than Prescribed count',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(initialCategory: DhikrCategory.general),
      );
      await tester.pumpAndSettle();

      // Navigate to general_istighfar (page index 2: 0=subhanallah, 1=four_beloved, 2=istighfar)
      final nextBtn = find.text('Next Dhikr');
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(find.text('Seeking Forgiveness & Repentance'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('Prescribed'), findsNothing);
    },
  );

  testWidgets(
    'shows calm collection-completion state with Done and Read Again actions',
    (tester) async {
      // Complete all items in After Salah collection (2 items: 4x astaghfirullah, 100x tasbih)
      final repo = getIt<AdhkarRepository>();
      await repo.saveSession(
        collectionId: DhikrCategory.postPrayer.name,
        lastPageIndex: 1,
        counts: {'post_salah_astaghfirullah': 4, 'post_salah_tasbih': 100},
        isCompleted: true,
      );
      await repo.recordCollectionCompletion(DhikrCategory.postPrayer.name);

      await tester.pumpWidget(
        buildSubject(initialCategory: DhikrCategory.postPrayer),
      );
      await tester.pumpAndSettle();

      // Swipe or navigate to completion page (page index 2 = items.length)
      final nextBtn = find.text('Next Dhikr');
      expect(nextBtn, findsOneWidget);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      // Completion card is rendered
      expect(find.byType(AdhkarCollectionCompletionCard), findsOneWidget);
      expect(
        find.text('الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'),
        findsOneWidget,
      );
      expect(find.text('تقبل الله طاعتكم'), findsOneWidget);
      expect(
        find.text(
          'You have completed this remembrance collection. Your progress is saved for today.',
        ),
        findsOneWidget,
      );

      final doneBtn = find.byKey(const Key('adhkar_completion_done_button'));
      expect(doneBtn, findsOneWidget);

      final readAgainBtn = find.byKey(
        const Key('adhkar_completion_read_again_button'),
      );
      expect(readAgainBtn, findsOneWidget);

      // Tapping Read Again resets session counts to 0 and jumps to page 0
      await tester.tap(readAgainBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AdhkarCollectionCompletionCard), findsNothing);
      expect(find.text('Seeking Forgiveness after Prayer'), findsOneWidget);
      expect(find.text('0 / 4'), findsOneWidget);

      // Daily completion history is preserved!
      final completedToday = await repo.isCollectionCompletedToday(
        DhikrCategory.postPrayer.name,
      );
      expect(completedToday, isTrue);
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
    final repo = getIt<AdhkarRepository>();
    await repo.saveSession(
      collectionId: DhikrCategory.morning.name,
      lastPageIndex: 0,
      counts: {'wake_up_1': 1},
      isCompleted: false,
    );

    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.morning),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('Completed! Alhamdulillah'), findsOneWidget);
  });

  testWidgets('reset button on card resets count in session', (tester) async {
    final repo = getIt<AdhkarRepository>();
    await repo.saveSession(
      collectionId: DhikrCategory.morning.name,
      lastPageIndex: 0,
      counts: {'wake_up_1': 1},
      isCompleted: false,
    );

    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.morning),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 1'), findsOneWidget);

    final resetBtn = find.byTooltip('Reset Count');
    expect(resetBtn, findsOneWidget);
    await tester.tap(resetBtn);
    await tester.pumpAndSettle();

    expect(find.text('0 / 1'), findsOneWidget);
  });

  testWidgets('reset category button resets all items in the category', (
    tester,
  ) async {
    final repo = getIt<AdhkarRepository>();
    await repo.saveSession(
      collectionId: DhikrCategory.morning.name,
      lastPageIndex: 0,
      counts: {'wake_up_1': 1, 'wake_up_2': 1},
      isCompleted: false,
    );

    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.morning),
    );
    await tester.pumpAndSettle();

    final resetCategoryBtn = find.byTooltip('Reset Category');
    expect(resetCategoryBtn, findsOneWidget);
    await tester.tap(resetCategoryBtn);
    await tester.pumpAndSettle();

    expect(find.text('0 / 1'), findsOneWidget);
  });

  testWidgets('transliteration toggle hides and shows transliteration text', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(initialCategory: DhikrCategory.morning),
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
      buildSubject(initialCategory: DhikrCategory.morning),
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

  testWidgets(
    'progresses through structured sub-steps with dynamic Arabic text and indicators',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(
          initialCategory: DhikrCategory.postPrayer,
          isReviewModeEnabled: true,
        ),
      );
      await tester.pumpAndSettle();

      // Item 1: post_salah_astaghfirullah (Step 1: Astaghfirullah 3x, Step 2: Allahumma Antas-Salam 1x)
      expect(find.text('Seeking Forgiveness after Prayer'), findsOneWidget);
      expect(find.text('Astaghfirullah'), findsWidgets);
      expect(find.text('(0/3)'), findsOneWidget);
      expect(find.text('(1x)'), findsOneWidget);
      expect(find.text('أَسْتَغْفِرُ اللَّهَ'), findsOneWidget);
      expect(find.text('0 / 4'), findsOneWidget);

      final dial = find.byIcon(Icons.touch_app_rounded).first;
      expect(dial, findsOneWidget);

      // Tap 1: count 1/4 (Step 1 progress 1/3)
      await tester.tap(dial);
      await tester.pumpAndSettle();
      expect(find.text('1 / 4'), findsOneWidget);
      expect(find.text('(1/3)'), findsOneWidget);

      // Tap 2: count 2/4 (Step 1 progress 2/3)
      await tester.tap(dial);
      await tester.pumpAndSettle();
      expect(find.text('2 / 4'), findsOneWidget);
      expect(find.text('(2/3)'), findsOneWidget);

      // Tap 3: count 3/4 (Step 1 complete, now Step 2 active!)
      await tester.tap(dial);
      await tester.pumpAndSettle();
      expect(find.text('3 / 4'), findsOneWidget);

      // Arabic text dynamically switched to Allahumma Antas-Salam
      expect(find.text('أَسْتَغْفِرُ اللَّهَ'), findsNothing);
      expect(
        find.text(
          'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
        ),
        findsOneWidget,
      );
      expect(find.text('(0/1)'), findsOneWidget);

      // Tap 4: count 4/4 (Step 2 complete, overall dhikr completed!)
      await tester.tap(dial);
      await tester.pumpAndSettle();

      expect(find.text('4 / 4'), findsOneWidget);
      expect(find.text('Completed! Alhamdulillah'), findsOneWidget);
    },
  );
}
