import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/adhan_notification_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/home/presentation/widgets/home_prayer_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAdhanNotificationService extends AdhanNotificationService {
  bool scheduled = false;
  bool cancelled = false;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> schedulePrayerNotifications({
    required DateTime fajr,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
  }) async {
    scheduled = true;
    cancelled = false;
  }

  @override
  Future<void> cancelAll() async {
    cancelled = true;
    scheduled = false;
  }
}

class FakePrayerTimeService extends PrayerTimeService {
  final Position _pos = Position(
    longitude: 39.8262,
    latitude: 21.4225,
    timestamp: DateTime.now(),
    accuracy: 1.0,
    altitude: 0.0,
    altitudeAccuracy: 1.0,
    heading: 0.0,
    headingAccuracy: 1.0,
    speed: 0.0,
    speedAccuracy: 1.0,
  );

  @override
  Future<Position?> getCurrentPosition() async => _pos;

  @override
  Position? get cachedPosition => _pos;

  @override
  String? get cachedLocationName => 'Makkah';

  @override
  PrayerTimes? get cachedPrayerTimes => getPrayerTimes(_pos);
}

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
    home: const Scaffold(body: SingleChildScrollView(child: HomePrayerCard())),
  );
}

void main() {
  late SettingsService settings;
  late FakeAdhanNotificationService fakeAdhan;
  late FakePrayerTimeService fakePrayer;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settings = SettingsService(prefs: prefs);
    fakeAdhan = FakeAdhanNotificationService();
    fakePrayer = FakePrayerTimeService();

    if (getIt.isRegistered<SettingsService>()) {
      getIt.unregister<SettingsService>();
    }
    if (getIt.isRegistered<AdhanNotificationService>()) {
      getIt.unregister<AdhanNotificationService>();
    }
    if (getIt.isRegistered<PrayerTimeService>()) {
      getIt.unregister<PrayerTimeService>();
    }

    getIt.registerSingleton<SettingsService>(settings);
    getIt.registerSingleton<AdhanNotificationService>(fakeAdhan);
    getIt.registerSingleton<PrayerTimeService>(fakePrayer);
  });

  tearDown(() {
    if (getIt.isRegistered<SettingsService>()) {
      getIt.unregister<SettingsService>();
    }
    if (getIt.isRegistered<AdhanNotificationService>()) {
      getIt.unregister<AdhanNotificationService>();
    }
    if (getIt.isRegistered<PrayerTimeService>()) {
      getIt.unregister<PrayerTimeService>();
    }
  });

  group('HomePrayerCard Adhan Toggle Tests', () {
    testWidgets(
      'renders Adhan: Muted initially and toggles to Adhan: On on tap',
      (tester) async {
        await tester.pumpWidget(_createTestWidget());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('home_hero_adhan_toggle_badge')),
          findsOneWidget,
        );
        expect(find.text('Adhan: Muted'), findsOneWidget);
        expect(settings.adhanNotificationsEnabled, isFalse);

        // Tap to enable
        await tester.tap(find.byKey(const Key('home_hero_adhan_toggle_badge')));
        await tester.pumpAndSettle();

        expect(find.text('Adhan: On'), findsOneWidget);
        expect(settings.adhanNotificationsEnabled, isTrue);
        expect(fakeAdhan.scheduled, isTrue);

        // Tap to mute
        await tester.tap(find.byKey(const Key('home_hero_adhan_toggle_badge')));
        await tester.pumpAndSettle();

        expect(find.text('Adhan: Muted'), findsOneWidget);
        expect(settings.adhanNotificationsEnabled, isFalse);
        expect(fakeAdhan.cancelled, isTrue);
      },
    );

    testWidgets('renders properly in Arabic locale with localized text', (
      tester,
    ) async {
      await tester.pumpWidget(_createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('هدي السنة النبوية'), findsOneWidget);
      expect(find.text('الأذان: صامت'), findsOneWidget);
      expect(find.textContaining('مجدول مع الإقامة'), findsOneWidget);

      // Tap to toggle
      await tester.tap(find.byKey(const Key('home_hero_adhan_toggle_badge')));
      await tester.pumpAndSettle();

      expect(find.text('الأذان: مفعّل'), findsOneWidget);
    });
  });
}
