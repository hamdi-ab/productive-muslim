import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/energy/presentation/widgets/energy_physical_anchors_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    home: const Scaffold(
      body: SingleChildScrollView(child: EnergyPhysicalAnchorsCard()),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs: prefs);
    if (getIt.isRegistered<SettingsService>()) {
      getIt.unregister<SettingsService>();
    }
    getIt.registerSingleton<SettingsService>(settings);
  });

  tearDown(() {
    if (getIt.isRegistered<SettingsService>()) {
      getIt.unregister<SettingsService>();
    }
  });

  group('EnergyPhysicalAnchorsCard Widget Tests', () {
    testWidgets('renders initial anchors and toggles on tap', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sunnah Physical Anchors'), findsOneWidget);
      expect(find.text('Sleep on the Sunnah'), findsOneWidget);
      expect(find.text('The 1/3 Rule for Nutrition'), findsOneWidget);
      expect(find.text('Daily Movement to the Mosque'), findsOneWidget);

      // Initially 0 / 3
      expect(find.text('0 / 3 Completed'), findsOneWidget);

      // Tap on Sleep anchor
      await tester.tap(find.text('Sleep on the Sunnah'));
      await tester.pumpAndSettle();

      expect(find.text('1 / 3 Completed'), findsOneWidget);
      expect(find.text('Sunnah Sleep Ritual Done'), findsOneWidget);

      // Tap on Nutrition anchor
      await tester.tap(find.text('The 1/3 Rule for Nutrition'));
      await tester.pumpAndSettle();

      expect(find.text('2 / 3 Completed'), findsOneWidget);
      expect(find.text('1/3 Nutrition Rule Observed'), findsOneWidget);

      // Untap Sleep anchor
      await tester.tap(find.text('Sleep on the Sunnah'));
      await tester.pumpAndSettle();

      expect(find.text('1 / 3 Completed'), findsOneWidget);
      expect(find.text('Tonight Checklist Ready'), findsOneWidget);
    });

    testWidgets('renders properly in Arabic locale', (tester) async {
      await tester.pumpWidget(_createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('مرتكزات الجسد النبوية'), findsOneWidget);
      expect(find.text('النوم على السنة النبوية'), findsOneWidget);
      expect(find.text('قاعدة الثلث في التغذية'), findsOneWidget);
      expect(find.text('المشي لصلاة الجماعة والحركة'), findsWidgets);
      expect(find.text('٠ / ٣ منجز اليوم'), findsOneWidget);
    });
  });
}
