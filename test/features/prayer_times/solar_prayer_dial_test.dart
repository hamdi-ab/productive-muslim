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

      final hasDayTitle = find.text('Solar Prayer Arc').evaluate().isNotEmpty;
      final hasNightTitle = find
          .text('Night & Tahajjud Arc')
          .evaluate()
          .isNotEmpty;
      expect(hasDayTitle || hasNightTitle, isTrue);
      expect(find.textContaining('Next: Dhuhr'), findsOneWidget);
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

      final hasArDay = find
          .text('مسار الشمس ومواقيت الصلاة')
          .evaluate()
          .isNotEmpty;
      final hasArNight = find.text('مسار الليل والتهجد').evaluate().isNotEmpty;
      expect(hasArDay || hasArNight, isTrue);
    });

    testWidgets('renders post-Isha tomorrow Fajr within arc constraints', (
      tester,
    ) async {
      // Create prayer times in the past to simulate after Isha
      final params = CalculationMethodParameters.muslimWorldLeague();
      final pastPrayerTimes = PrayerTimes(
        date: DateTime.now().subtract(const Duration(days: 1)),
        coordinates: Coordinates(30.0444, 31.2357),
        calculationParameters: params,
      );

      await tester.pumpWidget(
        buildWidget(
          child: SolarPrayerDial(
            prayerTimes: pastPrayerTimes,
            nextPrayer: 'Fajr',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Next: Fajr (Tomorrow)'), findsOneWidget);
    });

    testWidgets(
      'renders post-Isha tomorrow Fajr in Arabic within arc constraints',
      (tester) async {
        final params = CalculationMethodParameters.muslimWorldLeague();
        final pastPrayerTimes = PrayerTimes(
          date: DateTime.now().subtract(const Duration(days: 1)),
          coordinates: Coordinates(30.0444, 31.2357),
          calculationParameters: params,
        );

        await tester.pumpWidget(
          buildWidget(
            language: 'ar',
            child: SolarPrayerDial(
              prayerTimes: pastPrayerTimes,
              nextPrayer: 'Fajr',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('التالي: الفجر (غداً)'), findsOneWidget);
      },
    );
  });
}
