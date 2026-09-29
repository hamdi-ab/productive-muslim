import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/solar_prayer_dial.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  Widget buildWidget({required Widget child, String language = 'en'}) {
    return MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  PrayerTimes createPrayerTimes() {
    final params = CalculationMethodParameters.muslimWorldLeague();
    return PrayerTimes(
      date: DateTime.now(),
      coordinates: Coordinates(30.0444, 31.2357),
      calculationParameters: params,
    );
  }

  group('SolarPrayerDial', () {
    testWidgets('renders solar dial title and next prayer countdown', (
      tester,
    ) async {
      final prayerTimes = createPrayerTimes();

      await tester.pumpWidget(
        buildWidget(
          child: SolarPrayerDial(prayerTimes: prayerTimes, nextPrayer: 'Dhuhr'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Solar Prayer Arc'), findsOneWidget);
      expect(find.textContaining('Next: Dhuhr'), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders in Arabic locale', (tester) async {
      final prayerTimes = createPrayerTimes();

      await tester.pumpWidget(
        buildWidget(
          language: 'ar',
          child: SolarPrayerDial(prayerTimes: prayerTimes, nextPrayer: 'Dhuhr'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مسار الشمس ومواقيت الصلاة'), findsOneWidget);
    });
  });
}
