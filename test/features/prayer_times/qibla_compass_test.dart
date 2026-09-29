import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/qibla_service.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/qibla_compass_view.dart';
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

  group('QiblaCompassView', () {
    testWidgets('renders bearing, distance and calibration advice', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          child: const QiblaCompassView(
            latitude: 30.0444,
            longitude: 31.2357,
            initialHeading: 0.0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('from North'), findsOneWidget);
      expect(find.textContaining('km to Kaaba'), findsOneWidget);
      expect(find.byIcon(Icons.mosque_rounded), findsOneWidget);
      expect(find.byIcon(Icons.navigation_rounded), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets(
      'shows facing Kaaba indicator when heading is aligned with bearing',
      (tester) async {
        final service = QiblaService();
        final bearing = service.getQiblaBearing(30.0444, 31.2357);

        await tester.pumpWidget(
          buildWidget(
            child: QiblaCompassView(
              latitude: 30.0444,
              longitude: 31.2357,
              initialHeading: bearing, // Exactly facing Kaaba
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('You are facing the Kaaba'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      },
    );

    testWidgets('renders in Arabic locale properly', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          language: 'ar',
          child: const QiblaCompassView(
            latitude: 21.4225,
            longitude: 39.8262,
            initialHeading: 0.0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('عن الشمال'), findsOneWidget);
      expect(find.textContaining('كم إلى الكعبة المشرفة'), findsOneWidget);
    });
  });
}
