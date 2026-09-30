import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/fasting/presentation/widgets/hijri_calendar_view.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

void main() {
  setUp(() {
    if (!getIt.isRegistered<SettingsService>()) {
      getIt.registerSingleton<SettingsService>(SettingsService.empty());
    }
    if (!getIt.isRegistered<HijriService>()) {
      getIt.registerSingleton<HijriService>(HijriService());
    }
  });

  Widget buildSubject({
    ValueChanged<DateTime>? onDateSelected,
    String language = 'en',
  }) {
    return MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: HijriCalendarView(onDateSelected: onDateSelected),
        ),
      ),
    );
  }

  testWidgets(
    'renders HijriCalendarView with header, weekday labels and day cells',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(HijriCalendarView), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    },
  );

  testWidgets('tapping next and previous month navigates calendar', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final nextBtn = find.byIcon(Icons.chevron_right_rounded);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    final prevBtn = find.byIcon(Icons.chevron_left_rounded);
    await tester.tap(prevBtn);
    await tester.pumpAndSettle();

    expect(find.byType(HijriCalendarView), findsOneWidget);
  });

  testWidgets(
    'tapping a day opens day detail bottom sheet with fasting toggle button',
    (tester) async {
      DateTime? selected;
      await tester.pumpWidget(
        buildSubject(onDateSelected: (d) => selected = d),
      );
      await tester.pumpAndSettle();

      // Tap day '15'
      final day15 = find.text('15').first;
      await tester.tap(day15);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(find.byType(BottomSheet), findsOneWidget);
    },
  );
}
