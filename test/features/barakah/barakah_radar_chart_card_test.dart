import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_radar_chart_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  const customDimensions = [
    BarakahQualityDimension(
      key: 'ruh',
      nameEn: 'Ruh (Spiritual)',
      nameAr: 'الروح',
      score: 95,
      color: Color(0xFFE9C349),
    ),
    BarakahQualityDimension(
      key: 'jism',
      nameEn: 'Jism (Physical)',
      nameAr: 'الجسد',
      score: 85,
      color: Color(0xFF6FFBBE),
    ),
    BarakahQualityDimension(
      key: 'aql',
      nameEn: 'Aql (Mindset)',
      nameAr: 'العقل',
      score: 60,
      color: Color(0xFF4EDEA3),
    ),
  ];

  Widget createWidget({
    List<BarakahQualityDimension>? dimensions,
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
          child: BarakahRadarChartCard(dimensions: dimensions),
        ),
      ),
    );
  }

  testWidgets('renders dynamic average score and Al-Ihsan tier pill', (
    tester,
  ) async {
    // Average of 95, 85, 60 = 80 -> Al-Ihsan Tier
    await tester.pumpWidget(createWidget(dimensions: customDimensions));
    await tester.pumpAndSettle();

    expect(find.text('Productive Muslim 9 Qualities'), findsOneWidget);
    expect(find.text('80 / 100 • Al-Ihsan Tier'), findsOneWidget);
    expect(find.text('Top Strength: Ruh (Spiritual) • 95%'), findsOneWidget);
    expect(find.text('Growth Focus: Aql (Mindset) • 60%'), findsOneWidget);
    expect(find.text('Improve'), findsOneWidget);
  });

  testWidgets('renders dynamic Al-Muqarraboon tier when average >= 90', (
    tester,
  ) async {
    const eliteDimensions = [
      BarakahQualityDimension(
        key: 'ruh',
        nameEn: 'Ruh',
        nameAr: 'الروح',
        score: 95,
        color: Color(0xFFE9C349),
      ),
      BarakahQualityDimension(
        key: 'jism',
        nameEn: 'Jism',
        nameAr: 'الجسد',
        score: 92,
        color: Color(0xFF6FFBBE),
      ),
      BarakahQualityDimension(
        key: 'aql',
        nameEn: 'Aql',
        nameAr: 'العقل',
        score: 93,
        color: Color(0xFF4EDEA3),
      ),
    ];

    await tester.pumpWidget(createWidget(dimensions: eliteDimensions));
    await tester.pumpAndSettle();

    expect(find.text('93 / 100 • Al-Muqarraboon Tier'), findsOneWidget);
  });

  testWidgets(
    'renders properly in Arabic with Arabic digits and localized tier',
    (tester) async {
      await tester.pumpWidget(
        createWidget(dimensions: customDimensions, locale: const Locale('ar')),
      );
      await tester.pumpAndSettle();

      expect(find.text('أبعاد البركة التسعة'), findsOneWidget);
      expect(find.text('٨٠/١٠٠ • رتبة الإحسان'), findsOneWidget);
      expect(find.text('أعلى نقطة قوة: الروح • ٩٥٪'), findsOneWidget);
      expect(find.text('فرصة النمو: العقل • ٦٠٪'), findsOneWidget);
      expect(find.text('تحسين'), findsOneWidget);
    },
  );
}
