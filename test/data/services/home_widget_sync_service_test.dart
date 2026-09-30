import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/core/router/app_router.dart';
import 'package:productive_muslim/data/services/home_widget_sync_service.dart';

class MockHomeWidgetStorage implements HomeWidgetStorage {
  final Map<String, dynamic> data = {};
  String? updatedWidgetName;
  Uri? initialUri;
  final StreamController<Uri?> _clickController =
      StreamController<Uri?>.broadcast();

  @override
  Future<bool?> saveWidgetData<T>(String id, T? value) async {
    data[id] = value;
    return true;
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
    test('syncWidgetData stores all widget payload fields including countdown and action labels', () async {
      final success = await service.syncWidgetData(
        nextPrayerName: 'Asr',
        nextPrayerTime: '3:45 PM',
        nextPrayerCountdown: 'in 45m',
        activeSlot: 'Post-Dhuhr Barakah',
        dhikrCount: 33,
        appTitle: 'Productive Muslim',
        nextPrayerLabel: 'Next Prayer',
        btnPrayers: 'Prayers',
        btnAdhkar: 'Adhkar',
        btnFocus: 'Focus',
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
      expect(mockStorage.data[HomeWidgetSyncService.keyBtnPrayers], 'Prayers');
      expect(mockStorage.data[HomeWidgetSyncService.keyBtnAdhkar], 'Adhkar');
      expect(mockStorage.data[HomeWidgetSyncService.keyBtnFocus], 'Focus');
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
          appTitle: 'المسلم المنتج',
          nextPrayerLabel: 'الصلاة القادمة',
          btnPrayers: 'الصلاة',
          btnAdhkar: 'الأذكار',
          btnFocus: 'التركيز',
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
        expect(
          mockStorage.data[HomeWidgetSyncService.keyDhikrCount],
          'الأذكار: ٩٩ منجزة',
        );
      },
    );

    test('syncDhikrCount updates only dhikr count key and widget', () async {
      final success = await service.syncDhikrCount(33);
      expect(success, isTrue);
      expect(
        mockStorage.data[HomeWidgetSyncService.keyDhikrCount],
        'Dhikr: 33 completed',
      );
      expect(
        mockStorage.updatedWidgetName,
        HomeWidgetSyncService.androidWidgetProvider,
      );
    });

    test('getInitiallyLaunchedUri retrieves initial deep link', () async {
      mockStorage.initialUri = Uri.parse('productivemuslim://prayer_times');

      final uri = await service.getInitiallyLaunchedUri();
      expect(uri, equals(Uri.parse('productivemuslim://prayer_times')));
    });

    test('widgetClickedStream emits deep links on widget click', () async {
      final expectedUri = Uri.parse('productivemuslim://adhkar');

      expectLater(service.widgetClickedStream, emits(expectedUri));

      mockStorage.emitClick(expectedUri);
    });

    test('AppRouter.handleDeepLinkUri handles supported routes', () {
      // Validates deep link routing parser without throwing exceptions
      AppRouter.handleDeepLinkUri(Uri.parse('productivemuslim://prayer_times'));
      AppRouter.handleDeepLinkUri(Uri.parse('productivemuslim://adhkar'));
      AppRouter.handleDeepLinkUri(Uri.parse('productivemuslim://focus'));
      AppRouter.handleDeepLinkUri(Uri.parse('productivemuslim://home'));
      AppRouter.handleDeepLinkUri(Uri.parse('productivemuslim://barakah'));
      AppRouter.handleDeepLinkUri(Uri.parse('productivemuslim://tasks'));
      AppRouter.handleDeepLinkUri(Uri.parse('productivemuslim://habits'));
      AppRouter.handleDeepLinkUri(Uri.parse('productivemuslim://journal'));
      AppRouter.handleDeepLinkUri(Uri.parse('productivemuslim://settings'));
    });
  });
}
