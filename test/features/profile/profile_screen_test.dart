import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';
import 'package:productive_muslim/domain/repositories/barakah_repository.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_heatmap_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_radar_chart_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_score_header_card.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_weekly_review_card.dart';
import 'package:productive_muslim/features/profile/presentation/screens/profile_screen.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:productive_muslim/features/profile/presentation/widgets/profile_preferences_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockBarakahRepository extends Mock implements BarakahRepository {}

void main() {
  late MockBarakahRepository mockRepository;

  const testEntry = BarakahEntry(
    id: 1,
    date: '2026-11-09',
    sourceIds: ['Charity', 'GoodIntentions'],
    createdAt: 0,
  );

  setUpAll(() {
    registerFallbackValue(testEntry);
  });

  setUp(() {
    mockRepository = MockBarakahRepository();
    when(() => mockRepository.getEntriesForDate(any()))
        .thenAnswer((_) async => [testEntry]);
  });

  Widget buildScreen({Locale locale = const Locale('en')}) {
    return RepositoryProvider<BarakahRepository>.value(
      value: mockRepository,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProfileScreen(),
      ),
    );
  }

  testWidgets('renders Profile screen with hero identity card', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.byType(ProfileHeaderCard), findsOneWidget);
    expect(find.text('Productive Seeker'), findsOneWidget);
    expect(find.textContaining('Al-Mubarak'), findsOneWidget);
  });

  testWidgets('renders 9-qualities radar chart and capacity score cards', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.byType(BarakahScoreHeaderCard), findsOneWidget);
    expect(find.byType(BarakahRadarChartCard), findsOneWidget);
    expect(find.byType(BarakahHeatmapCard), findsOneWidget);
    expect(find.byType(BarakahWeeklyReviewCard), findsOneWidget);
    expect(find.byType(ProfilePreferencesCard), findsOneWidget);
  });

  testWidgets('renders Arabic RTL locale correctly', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildScreen(locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileHeaderCard), findsOneWidget);
    expect(find.text('طالب البركة'), findsOneWidget);
    expect(find.textContaining('الـمُبـارك'), findsOneWidget);
  });
}
