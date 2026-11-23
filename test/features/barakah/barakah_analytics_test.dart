import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/domain/models/barakah_analytics_summary.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_weekly_review.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_analytics_cards.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  group('BarakahWeeklyAnalytics Domain Logic', () {
    test('calculates correct averages, totals, and active days', () {
      final now = DateTime(2026, 9, 29); // Tuesday
      final week = BarakahReviewWeek.forDate(now, now: now);

      final responses = [
        BarakahDailyResponse(
          date: '2026-09-28',
          promptId: 'gratitude',
          answer: BarakahAnswer.yes,
          sourceIds: const ['quran'],
          createdAt: 1,
          updatedAt: 2,
        ),
        BarakahDailyResponse(
          date: '2026-09-29',
          promptId: 'mindfulness',
          answer: BarakahAnswer.somewhat,
          sourceIds: const ['prayer'],
          createdAt: 1,
          updatedAt: 2,
        ),
      ];

      final review = BarakahWeeklyReview(week, responses);

      final analytics = BarakahWeeklyAnalytics.calculate(
        review: review,
        week: week,
        getEnergy: (date) => (physical: 4, spiritual: 5, mental: 4),
        getDhikr: (date) => ['morning_1', 'morning_2', 'evening_1'],
        isFasting: (date) => date == '2026-09-28',
        languageCode: 'en',
      );

      expect(analytics.avgSpiritual, equals(5.0));
      expect(analytics.avgMental, equals(4.0));
      expect(analytics.avgPhysical, equals(4.0));
      expect(analytics.totalFastingDays, equals(1));
      expect(analytics.totalDhikrCompleted, equals(6)); // 2 days * 3 dhikrs
      expect(analytics.activeDaysCount, equals(2));
      expect(analytics.insights, isNotEmpty);
    });

    test('generates localized Arabic insights when languageCode is ar', () {
      final now = DateTime(2026, 9, 29);
      final week = BarakahReviewWeek.forDate(now, now: now);

      final responses = [
        BarakahDailyResponse(
          date: '2026-09-28',
          promptId: 'gratitude',
          answer: BarakahAnswer.yes,
          sourceIds: const ['quran'],
          createdAt: 1,
          updatedAt: 2,
        ),
      ];

      final review = BarakahWeeklyReview(week, responses);

      final analytics = BarakahWeeklyAnalytics.calculate(
        review: review,
        week: week,
        getEnergy: (date) => (physical: 5, spiritual: 5, mental: 5),
        getDhikr: (date) => [
          'dhikr_1',
          'dhikr_2',
          'dhikr_3',
          'dhikr_4',
          'dhikr_5',
          'dhikr_6',
        ],
        isFasting: (date) => true,
        languageCode: 'ar',
      );

      expect(analytics.insights.any((i) => i.contains('أذكار')), isTrue);
      expect(analytics.insights.any((i) => i.contains('صيام')), isTrue);
    });
  });

  group('Barakah Analytics UI Cards', () {
    testWidgets(
      'renders consistency grid, energy triad, and coaching insights',
      (tester) async {
        final now = DateTime(2026, 9, 29);
        final week = BarakahReviewWeek.forDate(now, now: now);

        final responses = [
          BarakahDailyResponse(
            date: '2026-09-28',
            promptId: 'gratitude',
            answer: BarakahAnswer.yes,
            sourceIds: const ['quran'],
            createdAt: 1,
            updatedAt: 2,
          ),
        ];

        final review = BarakahWeeklyReview(week, responses);

        final analytics = BarakahWeeklyAnalytics.calculate(
          review: review,
          week: week,
          getEnergy: (date) => (physical: 4, spiritual: 5, mental: 4),
          getDhikr: (date) => ['morning_1'],
          isFasting: (date) => false,
          languageCode: 'en',
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    BarakahConsistencyMatrixCard(analytics: analytics),
                    EnergyTriadBreakdownCard(analytics: analytics),
                    BarakahCoachingInsightsCard(analytics: analytics),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(BarakahConsistencyMatrixCard), findsOneWidget);
        expect(find.byType(EnergyTriadBreakdownCard), findsOneWidget);
        expect(find.byType(BarakahCoachingInsightsCard), findsOneWidget);
        expect(find.text('7-Day Barakah Matrix'), findsOneWidget);
        expect(find.text('Holistic Energy Triad'), findsOneWidget);
        expect(find.text('Spiritual Growth Insights'), findsOneWidget);
        expect(find.text('Vibrant'), findsOneWidget);
        expect(find.text('Steady'), findsNWidgets(2));
        expect(find.textContaining('/ 5.0'), findsNothing);
      },
    );
  });
}
