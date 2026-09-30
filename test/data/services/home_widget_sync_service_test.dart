import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/router/app_router.dart';
import 'package:productive_muslim/data/services/home_widget_sync_service.dart';

class MockHomeWidgetStorage implements HomeWidgetStorage {
  final Map<String, dynamic> data = {};
  String? updatedWidgetName;
  Uri? initialUri;
  FutureOr<void> Function(Uri?)? registeredCallback;
  final StreamController<Uri?> _clickController =
      StreamController<Uri?>.broadcast();

  @override
  Future<bool?> saveWidgetData<T>(String id, T? value) async {
    data[id] = value;
    return true;
  }

  @override
  Future<T?> getWidgetData<T>(String id, {T? defaultValue}) async {
    return (data[id] as T?) ?? defaultValue;
  }

  @override
  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) async {
    updatedWidgetName = androidName ?? name;
    return true;
  }

  @override
  Future<Uri?> initiallyLaunchedFromHomeWidget() async {
    return initialUri;
  }

  @override
  Stream<Uri?> get widgetClicked => _clickController.stream;

  @override
  Future<bool?> registerInteractivityCallback(
    FutureOr<void> Function(Uri?) callback,
  ) async {
    registeredCallback = callback;
    return true;
  }

  void emitClick(Uri uri) {
    _clickController.add(uri);
  }

  void dispose() {
    _clickController.close();
  }
}

void main() {
  late MockHomeWidgetStorage mockStorage;
  late HomeWidgetSyncService service;

  setUp(() {
    mockStorage = MockHomeWidgetStorage();
    service = HomeWidgetSyncService(storage: mockStorage);
  });

  tearDown(() {
    mockStorage.dispose();
  });

  group('HomeWidgetSyncService', () {
    test('syncWidgetData stores all widget payload fields including hijri, fasting, countdown and actions', () async {
      final success = await service.syncWidgetData(
        nextPrayerName: 'Asr',
        nextPrayerTime: '3:45 PM',
        nextPrayerCountdown: 'in 45m',
        activeSlot: 'Post-Dhuhr Barakah',
        dhikrCount: 33,
        hijriDate: "14 Sha'ban 1447",
        fastingBadge: 'White Day Sunnah',
        appTitle: 'Productive Muslim',
        nextPrayerLabel: 'Next Prayer',
        btnPrayers: 'Prayers',
        btnAdhkar: 'Adhkar',
        btnFocus: 'Focus',
        btnPlusOne: '+1',
      );

      expect(success, isTrue);
      expect(
        mockStorage.data[HomeWidgetSyncService.keyAppTitle],
        'Productive Muslim',
      );
      expect(
        mockStorage.data[HomeWidgetSyncService.keyActiveSlot],
        'Post-Dhuhr Barakah',
      );
      expect(
        mockStorage.data[HomeWidgetSyncService.keyHijriDate],
        "14 Sha'ban 1447",
      );
      expect(
        mockStorage.data[HomeWidgetSyncService.keyFastingBadge],
        'White Day Sunnah',
      );
      expect(
        mockStorage.data[HomeWidgetSyncService.keyNextPrayerLabel],
        'Next Prayer',
      );
      expect(mockStorage.data[HomeWidgetSyncService.keyNextPrayerName], 'Asr');
      expect(
        mockStorage.data[HomeWidgetSyncService.keyNextPrayerTime],
        '3:45 PM',
      );
      expect(
        mockStorage.data[HomeWidgetSyncService.keyNextPrayerCountdown],
        'in 45m',
      );
      expect(
        mockStorage.data[HomeWidgetSyncService.keyDhikrCount],
        'Dhikr: 33',
      );
      expect(mockStorage.data[HomeWidgetSyncService.keyDhikrRawCount], 33);
      expect(mockStorage.data[HomeWidgetSyncService.keyBtnPrayers], 'Prayers');
      expect(mockStorage.data[HomeWidgetSyncService.keyBtnAdhkar], 'Adhkar');
      expect(mockStorage.data[HomeWidgetSyncService.keyBtnFocus], 'Focus');
      expect(mockStorage.data[HomeWidgetSyncService.keyBtnPlusOne], '+1');
      expect(
        mockStorage.updatedWidgetName,
        HomeWidgetSyncService.androidWidgetProvider,
      );
    });

    test(
      'syncWidgetData supports custom dhikr text for Arabic localization',
      () async {
        final success = await service.syncWidgetData(
          nextPrayerName: 'العصر',
          nextPrayerTime: '٣:٤٥ م',
          nextPrayerCountdown: 'بعد ٤٥ د',
          activeSlot: 'ساعة البركة',
          dhikrCount: 99,
          hijriDate: '١٤ شعبان ١٤٤٧',
          fastingBadge: 'يوم أبيض',
          appTitle: 'المسلم المنتج',
          nextPrayerLabel: 'الصلاة القادمة',
          btnPrayers: 'الصلاة',
          btnAdhkar: 'الأذكار',
          btnFocus: 'التركيز',
          btnPlusOne: '+١',
          customDhikrText: 'الأذكار: ٩٩ منجزة',
        );

        expect(success, isTrue);
        expect(
          mockStorage.data[HomeWidgetSyncService.keyAppTitle],
          'المسلم المنتج',
        );
        expect(mockStorage.data[HomeWidgetSyncService.keyBtnPrayers], 'الصلاة');
        expect(mockStorage.data[HomeWidgetSyncService.keyBtnAdhkar], 'الأذكار');
        expect(mockStorage.data[HomeWidgetSyncService.keyBtnFocus], 'التركيز');
        expect(mockStorage.data[HomeWidgetSyncService.keyBtnPlusOne], '+١');
        expect(
          mockStorage.data[HomeWidgetSyncService.keyDhikrCount],
          'الأذكار: ٩٩ منجزة',
        );
      },
    );

    test('syncDhikrCount updates dhikr raw count and display text', () async {
      final success = await service.syncDhikrCount(33);
      expect(success, isTrue);
      expect(
        mockStorage.data[HomeWidgetSyncService.keyDhikrCount],
        'Dhikr: 33',
      );
      expect(mockStorage.data[HomeWidgetSyncService.keyDhikrRawCount], 33);
      expect(
        mockStorage.updatedWidgetName,
        HomeWidgetSyncService.androidWidgetProvider,
      );
    });

    test('incrementDhikrCountDirectly atomically increments count and updates widget', () async {
      mockStorage.data[HomeWidgetSyncService.keyDhikrRawCount] = 10;

      final newCount = await service.incrementDhikrCountDirectly();
      expect(newCount, equals(11));
      expect(mockStorage.data[HomeWidgetSyncService.keyDhikrRawCount], 11);
      expect(
        mockStorage.data[HomeWidgetSyncService.keyDhikrCount],
        'Dhikr: 11',
      );
      expect(
        mockStorage.updatedWidgetName,
        HomeWidgetSyncService.androidWidgetProvider,
      );

      // Increment again by delta 5
      final afterFive = await service.incrementDhikrCountDirectly(delta: 5);
      expect(afterFive, equals(16));
      expect(mockStorage.data[HomeWidgetSyncService.keyDhikrRawCount], 16);
      expect(
        mockStorage.data[HomeWidgetSyncService.keyDhikrCount],
        'Dhikr: 16',
      );
    });

    test('getStoredDhikrRawCount retrieves stored raw integer', () async {
      mockStorage.data[HomeWidgetSyncService.keyDhikrRawCount] = 77;
      final count = await service.getStoredDhikrRawCount();
      expect(count, equals(77));
    });

    test('registerBackgroundCallback stores interactivity handler', () async {
      final success = await service.registerBackgroundCallback();
      expect(success, isTrue);
      expect(mockStorage.registeredCallback, isNotNull);
    });

    test('getInitiallyLaunchedUri retrieves initial deep link', () async {
      mockStorage.initialUri = Uri.parse('productivemuslim://prayer_times');

      final uri = await service.getInitiallyLaunchedUri();
      expect(uri, equals(Uri.parse('productivemuslim://prayer_times')));
    });

    test('widgetClickedStream emits received deep links', () async {
      final emittedUris = <Uri?>[];
      final subscription = service.widgetClickedStream.listen(emittedUris.add);

      final testUri1 = Uri.parse('productivemuslim://adhkar');
      final testUri2 = Uri.parse('productivemuslim://focus');
      final testUri3 = Uri.parse('productivemuslim://fasting');

      mockStorage.emitClick(testUri1);
      mockStorage.emitClick(testUri2);
      mockStorage.emitClick(testUri3);

      await pumpEventQueue();

      expect(emittedUris, equals([testUri1, testUri2, testUri3]));
      await subscription.cancel();
    });
  });

  group('AppRouter Deep Link Parser', () {
    test('handles valid deep link URIs without throwing', () {
      final uris = [
        Uri.parse('productivemuslim://home'),
        Uri.parse('productivemuslim://prayer_times'),
        Uri.parse('productivemuslim://prayer-times'),
        Uri.parse('productivemuslim://adhkar'),
        Uri.parse('productivemuslim://focus'),
        Uri.parse('productivemuslim://fasting'),
        Uri.parse('productivemuslim://barakah'),
        Uri.parse('productivemuslim://tasks'),
        Uri.parse('productivemuslim://habits'),
        Uri.parse('productivemuslim://journal'),
        Uri.parse('productivemuslim://settings'),
      ];

      for (final uri in uris) {
        expect(() => AppRouter.handleDeepLinkUri(uri), returnsNormally);
      }
    });
  });
}
