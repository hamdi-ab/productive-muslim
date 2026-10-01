import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_heatmap_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  Widget buildTestWidget({
    Locale locale = const Locale('en'),
    Map<String, int> activity = const {},
    DateTime? referenceDate,
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      home: Scaffold(
        body: SingleChildScrollView(
          child: BarakahHeatmapCard(
            activityByDate: activity,
            referenceDate: referenceDate ?? DateTime(2026, 9, 30),
          ),
        ),
      ),
    );
  }

  group('BarakahHeatmapCard Widget Tests', () {
    testWidgets(
      'renders heatmap title, subtitle, legend and active days count in English',
      (tester) async {
        final sampleActivity = {
          '2026-09-30': 4,
          '2026-09-29': 2,
          '2026-09-28': 1,
        };

        await tester.pumpWidget(
          buildTestWidget(
            activity: sampleActivity,
            referenceDate: DateTime(2026, 9, 30),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('12-Week Consistency Heatmap'), findsOneWidget);
        expect(find.text('Daily Barakah & habit momentum'), findsOneWidget);
        expect(find.text('Less'), findsOneWidget);
        expect(find.text('More'), findsOneWidget);
        expect(find.text('3 of 84 active days'), findsOneWidget);
        expect(find.byType(Tooltip), findsWidgets);
      },
    );

    testWidgets('renders heatmap accurately in Arabic locale', (tester) async {
      final sampleActivity = {'2026-09-30': 5};

      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('ar'),
          activity: sampleActivity,
          referenceDate: DateTime(2026, 9, 30),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مصفوفة الاستمرارية (١٢ أسبوعاً)'), findsOneWidget);
      expect(find.text('زخم البركة والعادات اليومية'), findsOneWidget);
      expect(find.text('أقل'), findsOneWidget);
      expect(find.text('أكثر'), findsOneWidget);
    });
  });
}
