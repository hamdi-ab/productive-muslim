import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/features/energy/presentation/widgets/qaylulah_nap_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

Widget _createTestWidget({Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('ar')],
    home: const Scaffold(body: SingleChildScrollView(child: QaylulahNapCard())),
  );
}

void main() {
  group('QaylulahNapCard Widget Tests', () {
    testWidgets('renders presets and starts/pauses nap timer', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sunnah Power Nap'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);
      expect(find.text('20 min'), findsOneWidget);
      expect(find.text('Start Qaylulah Nap'), findsOneWidget);

      // Select 15 min preset
      await tester.tap(find.text('15 min'));
      await tester.pumpAndSettle();

      expect(find.text('15:00'), findsOneWidget);

      // Start Nap
      await tester.tap(find.text('Start Qaylulah Nap'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('14:59'), findsOneWidget);

      // Pause Nap
      await tester.tap(find.text('Pause'));
      await tester.pump();

      expect(find.text('Start Qaylulah Nap'), findsOneWidget);
    });

    testWidgets('renders Arabic locale with localized text and numerals', (
      tester,
    ) async {
      await tester.pumpWidget(_createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('قيلولة السنة النبوية'), findsOneWidget);
      expect(find.text('٢٠:٠٠'), findsOneWidget);
      expect(find.text('٢٠ د'), findsOneWidget);
      expect(find.text('بدء قيلولة السنة'), findsOneWidget);
      expect(
        find.text('«قِيلُوا فَإِنَّ الشَّيَاطِينَ لَا تَقِيلُ»'),
        findsOneWidget,
      );
    });
  });
}
