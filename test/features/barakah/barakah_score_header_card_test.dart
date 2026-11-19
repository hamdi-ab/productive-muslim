import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/barakah_activity_service.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_score_header_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  Widget buildWidget({
    BarakahActivitySummary? summary,
    bool isDark = false,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: BarakahScoreHeaderCard(
            isDark: isDark,
            isAr: locale.languageCode == 'ar',
            summary: summary,
          ),
        ),
      ),
    );
  }

  group('BarakahScoreHeaderCard (Reflective & Non-Scored)', () {
    testWidgets(
      'renders reflective header, intention dua, and disclaimer without scores',
      (tester) async {
        const sampleSummary = BarakahActivitySummary(
          completedHabitsToday: 3,
          focusMinutes: 45,
          hasDailyResponse: true,
        );

        await tester.pumpWidget(buildWidget(summary: sampleSummary));
        await tester.pumpAndSettle();

        // Reflective title and subtitle
        expect(find.text('Barakah & Reflection'), findsOneWidget);
        expect(
          find.text('Mindful intention, sincere action, and gratitude.'),
          findsOneWidget,
        );

        // Verified Hadith dua and scholarly attribution
        expect(
          find.text(
            '“O Allah, I ask You for beneficial knowledge, good provision, and accepted deeds.”',
          ),
          findsOneWidget,
        );
        expect(
          find.text('— Prophet Muhammad ﷺ · Sunan Ibn Majah (925)'),
          findsOneWidget,
        );

        // Factual activity chips
        expect(find.text("Today's Recorded Activity"), findsOneWidget);
        expect(find.text('3 habits kept'), findsOneWidget);
        expect(find.text('45 focus mins'), findsOneWidget);
        expect(find.text('Reflection saved'), findsOneWidget);

        // Explicit theological disclaimer
        expect(
          find.text(
            'Activity counts describe self-reported app usage, not a measure of divine blessing, faith, or sincerity.',
          ),
          findsOneWidget,
        );

        // Absolutely NO percentage scores, points, or tier labels
        expect(find.textContaining('%'), findsNothing);
        expect(find.textContaining('points'), findsNothing);
        expect(find.textContaining('Tier'), findsNothing);
      },
    );

    testWidgets('renders localized in Arabic RTL', (tester) async {
      const sampleSummary = BarakahActivitySummary(
        completedHabitsToday: 2,
        focusMinutes: 30,
        hasDailyResponse: false,
      );

      await tester.pumpWidget(
        buildWidget(summary: sampleSummary, locale: const Locale('ar')),
      );
      await tester.pumpAndSettle();

      expect(find.text('البركة والتأمل اليومي'), findsOneWidget);
      expect(
        find.text(
          '«اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا»',
        ),
        findsOneWidget,
      );
      expect(find.text('— النبي ﷺ · سنن ابن ماجه (٩٢٥)'), findsOneWidget);
      expect(find.text('النشاط المسجل لهذا اليوم'), findsOneWidget);
      expect(find.text('2 عادات منجزة'), findsOneWidget);
      expect(find.text('30 دقيقة تركيز'), findsOneWidget);
      expect(find.text('بانتظار التأمل'), findsOneWidget);
      expect(
        find.text(
          'يعكس هذا السجل نشاطك الذاتي في التطبيق، وليس مقياساً لمكانتك الإيمانية أو إخلاصك أمام الله.',
        ),
        findsOneWidget,
      );

      // No scoring or tiers
      expect(find.textContaining('٪'), findsNothing);
      expect(find.textContaining('رتبة'), findsNothing);
    });
  });
}
