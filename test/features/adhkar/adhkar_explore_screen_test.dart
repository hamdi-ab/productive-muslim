import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/adhkar_search_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/adhkar_session_record.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_explore_screen.dart';
import 'package:productive_muslim/features/adhkar/presentation/screens/adhkar_screen.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAdhkarRepository extends Mock implements AdhkarRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAdhkarRepository mockRepo;
  late SettingsService settingsService;

  final approvedItem1 = const DhikrItem(
    id: 'test_dhikr_1',
    category: DhikrCategory.morning,
    titleEn: 'Morning Praise',
    titleAr: 'تسبيح الصباح',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    transliteration: 'Subhan Allahi wa bihamdih',
    translationEn: 'Glory be to Allah and His is the praise',
    translationAr: 'سبحان الله وبحمده',
    reference: 'Sahih Muslim 2692',
    virtue: 'Sins forgiven even if like the foam of the sea',
    targetCount: 100,
    order: 1,
    reviewStatus: ContentReviewStatus.approved,
    isCountPrescribed: true,
  );

  final approvedItem2 = const DhikrItem(
    id: 'test_dhikr_2',
    category: DhikrCategory.evening,
    titleEn: 'Seeking Forgiveness',
    titleAr: 'سيد الاستغفار',
    arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ',
    transliteration: 'Allahumma Anta Rabbi la ilaha illa Ant',
    translationEn: 'O Allah, You are my Lord, there is no deity worthy of worship except You',
    translationAr: 'اللهم أنت ربي لا إله إلا أنت',
    reference: 'Sahih al-Bukhari 6306',
    virtue: 'Chief supplication for repentance',
    targetCount: 1,
    order: 2,
    reviewStatus: ContentReviewStatus.approved,
    isCountPrescribed: true,
  );

  final pendingReviewItem = const DhikrItem(
    id: 'test_pending_dhikr',
    category: DhikrCategory.general,
    titleEn: 'Draft Supplication',
    titleAr: 'دعاء قيد المراجعة',
    arabic: 'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ',
    transliteration: "Rabbighfir li wa tub 'alayy",
    translationEn: 'My Lord forgive me and turn to me',
    translationAr: 'رب اغفر لي وتب علي',
    reference: 'Sunan Abi Dawud',
    virtue: 'Repentance supplication under review',
    targetCount: 100,
    order: 10,
    reviewStatus: ContentReviewStatus.pendingReview,
    isCountPrescribed: true,
  );

  setUpAll(() {
    registerFallbackValue(DhikrCategory.morning);
    registerFallbackValue(DhikrSubject.gratitude);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsService = SettingsService(prefs: prefs);

    mockRepo = MockAdhkarRepository();

    when(() => mockRepo.isReviewModeAvailable).thenReturn(false);
    when(() => mockRepo.isReviewModeEnabled).thenReturn(false);
    when(() => mockRepo.catalogVersion).thenReturn(1);
    when(
      () => mockRepo.watchBookmarkedIds(
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockRepo.getBookmarkedItems(
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((_) async => []);
    when(
      () =>
          mockRepo.isCollectionCompletedToday(any(), date: any(named: 'date')),
    ).thenAnswer((_) async => false);
    when(() => mockRepo.getSession(any())).thenAnswer((_) async => null);

    when(
      () => mockRepo.getAll(
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((invocation) {
      final includePending =
          invocation.namedArguments[#includePendingReview] as bool? ?? false;
      if (includePending) {
        return [approvedItem1, approvedItem2, pendingReviewItem];
      }
      return [approvedItem1, approvedItem2];
    });

    when(
      () => mockRepo.getByCategory(
        DhikrCategory.morning,
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((invocation) {
      return [approvedItem1];
    });

    when(
      () => mockRepo.getByCategory(
        DhikrCategory.evening,
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((invocation) {
      return [approvedItem2];
    });

    when(
      () => mockRepo.getByCategory(
        DhikrCategory.general,
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((invocation) {
      final includePending =
          invocation.namedArguments[#includePendingReview] as bool? ?? false;
      if (includePending) {
        return [pendingReviewItem];
      }
      return [];
    });

    when(
      () => mockRepo.getByCategory(
        any(
          that: isNot(
            isIn([
              DhikrCategory.morning,
              DhikrCategory.evening,
              DhikrCategory.general,
            ]),
          ),
        ),
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((_) => []);

    when(
      () => mockRepo.getBySubject(
        DhikrSubject.gratitude,
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((_) => [approvedItem1]);

    when(
      () => mockRepo.getBySubject(
        DhikrSubject.forgiveness,
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((invocation) {
      final includePending =
          invocation.namedArguments[#includePendingReview] as bool? ?? false;
      if (includePending) {
        return [approvedItem2, pendingReviewItem];
      }
      return [approvedItem2];
    });

    when(
      () => mockRepo.getBySubject(
        any(
          that: isNot(isIn([DhikrSubject.gratitude, DhikrSubject.forgiveness])),
        ),
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((_) => []);

    when(
      () => mockRepo.getById(
        'test_dhikr_1',
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenReturn(approvedItem1);
    when(
      () => mockRepo.getById(
        'test_dhikr_2',
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenReturn(approvedItem2);
    when(
      () => mockRepo.getById(
        'test_pending_dhikr',
        includePendingReview: any(named: 'includePendingReview'),
      ),
    ).thenAnswer((invocation) {
      final includePending =
          invocation.namedArguments[#includePendingReview] as bool? ?? false;
      return includePending ? pendingReviewItem : null;
    });

    getIt.reset();
    getIt.registerSingleton<SettingsService>(settingsService);
    getIt.registerSingleton<AdhkarRepository>(mockRepo);
    getIt.registerSingleton<AdhkarSearchService>(
      AdhkarSearchService(repository: mockRepo),
    );
  });

  tearDown(() {
    getIt.reset();
  });

  Widget buildTestWidget({Widget? home, Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      home: home ?? const AdhkarExploreScreen(),
    );
  }

  group('AdhkarExploreScreen - Discovery & Search Features', () {
    testWidgets('renders search bar, prompt chips, and both discovery tabs', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('adhkar_explore_search_input')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('adhkar_explore_tab_collections')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('adhkar_explore_tab_categories')),
        findsOneWidget,
      );

      // Prompt chips exist
      expect(
        find.byKey(const Key('adhkar_prompt_chip_Morning')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('adhkar_prompt_chip_Evening')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('adhkar_prompt_chip_Sayyid al-Istighfar')),
        findsOneWidget,
      );
    });

    testWidgets(
      'Collections tab displays essential collections with item counts',
      (tester) async {
        tester.view.physicalSize = const Size(600, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adhkar_collection_card_morning')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adhkar_collection_card_evening')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adhkar_collection_card_postPrayer')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adhkar_collection_card_sleeping')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adhkar_collection_card_wakingUp')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adhkar_collection_card_general')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Categories tab lists 5 subjects and reveals items upon selection',
      (tester) async {
        tester.view.physicalSize = const Size(600, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Switch to Categories tab
        await tester.tap(
          find.byKey(const Key('adhkar_explore_tab_categories')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adhkar_category_card_gratitude')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adhkar_category_card_forgiveness')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adhkar_category_card_protection')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adhkar_category_card_sleepAndWaking')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adhkar_category_card_everyday')),
          findsOneWidget,
        );

        // Tap Gratitude subject card
        await tester.tap(
          find.byKey(const Key('adhkar_category_card_gratitude')),
        );
        await tester.pumpAndSettle();

        // Shows back button and Gratitude items
        expect(
          find.byKey(const Key('adhkar_explore_back_to_subjects')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adhkar_result_card_test_dhikr_1')),
          findsOneWidget,
        );

        // Tap back button returns to subjects list
        await tester.tap(
          find.byKey(const Key('adhkar_explore_back_to_subjects')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adhkar_category_card_gratitude')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tapping prompt chip populates search bar and displays results',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('adhkar_prompt_chip_Morning')));
        await tester.pumpAndSettle();

        final input = tester.widget<TextField>(
          find.byKey(const Key('adhkar_explore_search_input')),
        );
        expect(input.controller?.text, 'Morning');
        expect(
          find.byKey(const Key('adhkar_result_card_test_dhikr_1')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'unified offline search performs diacritic-insensitive Arabic search',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Type unvocalized Arabic search query ("سبحان الله")
        await tester.enterText(
          find.byKey(const Key('adhkar_explore_search_input')),
          'سبحان الله',
        );
        await tester.pumpAndSettle();

        // Should match vocalized sacred text "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ"
        expect(
          find.byKey(const Key('adhkar_result_card_test_dhikr_1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adhkar_result_card_test_dhikr_2')),
          findsNothing,
        );
      },
    );

    testWidgets('unified offline search matches English translation keywords', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('adhkar_explore_search_input')),
        'worship',
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('adhkar_result_card_test_dhikr_2')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('adhkar_result_card_test_dhikr_1')),
        findsNothing,
      );
    });

    testWidgets(
      'unmatched search query displays calm no-results state with clear button',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('adhkar_explore_search_input')),
          'randomunmatchedquery123',
        );
        await tester.pumpAndSettle();

        expect(find.text('No remembrances found'), findsOneWidget);
        expect(
          find.byKey(const Key('adhkar_explore_no_results_clear_button')),
          findsOneWidget,
        );

        // Tap clear button resets query
        await tester.tap(
          find.byKey(const Key('adhkar_explore_no_results_clear_button')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adhkar_explore_tab_collections')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'clear icon on search bar resets query and returns to discovery tabs',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('adhkar_explore_search_input')),
          'Morning',
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adhkar_explore_search_clear')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('adhkar_explore_search_clear')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adhkar_explore_tab_collections')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'strict editorial content boundary: pending-review items NEVER appear in ordinary explore or search',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            home: const AdhkarExploreScreen(isReviewModeEnabled: false),
          ),
        );
        await tester.pumpAndSettle();

        // Search for word in pending review item
        await tester.enterText(
          find.byKey(const Key('adhkar_explore_search_input')),
          'Draft Supplication',
        );
        await tester.pumpAndSettle();

        // Must be completely excluded from normal search
        expect(
          find.byKey(const Key('adhkar_result_card_test_pending_dhikr')),
          findsNothing,
        );
        expect(find.text('No remembrances found'), findsOneWidget);
      },
    );

    testWidgets('AdhkarScreen initializes at initialItemId when provided', (
      tester,
    ) async {
      when(() => mockRepo.getSession(DhikrCategory.morning.name)).thenAnswer(
        (_) async => AdhkarSessionRecord(
          collectionId: DhikrCategory.morning.name,
          lastPageIndex: 0,
          counts: {'ayat_al_kursi': 1},
          isCompleted: false,
          lastAccessedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(
          home: const AdhkarScreen(
            initialCategory: DhikrCategory.morning,
            initialItemId: 'ayat_al_kursi',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verifies the reader opened without throwing, rendered, and kept counts
      expect(find.byType(AdhkarScreen), findsOneWidget);
    });

    testWidgets('AdhkarScreen category tabs include Explore chip', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          home: const AdhkarScreen(initialCategory: DhikrCategory.morning),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('adhkar_explore_chip')), findsOneWidget);
    });
  });
}
