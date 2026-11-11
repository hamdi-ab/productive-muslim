import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/barakah/presentation/widgets/barakah_muhasabah_audit_card.dart';
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
      body: SingleChildScrollView(child: BarakahMuhasabahAuditCard()),
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

  group('BarakahMuhasabahAuditCard Widget Tests', () {
    testWidgets('renders initial rating and toggles checkpoints', (
      tester,
    ) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text("Spiritual Focus & Khushu' Audit"), findsOneWidget);
      expect(find.text('4/5'), findsOneWidget);
      expect(find.text("Fajr in Jama'ah"), findsOneWidget);
      expect(find.text('Quran Tadabbur'), findsOneWidget);

      // Tap 5th star
      final stars = find.byIcon(Icons.star_border_rounded);
      expect(stars, findsOneWidget); // 5th star is border
      await tester.tap(stars);
      await tester.pumpAndSettle();

      expect(find.text('5/5'), findsOneWidget);

      // Tap Quran Tadabbur checkpoint
      await tester.tap(find.text('Quran Tadabbur'));
      await tester.pumpAndSettle();

      final settings = getIt<SettingsService>();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      expect(settings.getMuhasabahRating(today), 5);
      expect(
        settings.getMuhasabahCheckpoints(today),
        contains('quran_tadabbur'),
      );
    });

    testWidgets('renders Arabic locale with localized text and numerals', (
      tester,
    ) async {
      await tester.pumpWidget(_createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('محاسبة الخشوع والتركيز'), findsOneWidget);
      expect(find.text('٤/٥'), findsOneWidget);
      expect(find.text('صلاة الفجر في جماعة'), findsOneWidget);
      expect(find.text('ورد تدبر القرآن'), findsOneWidget);
    });
  });
}
