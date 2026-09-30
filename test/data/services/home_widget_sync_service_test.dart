import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
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
    test(
      'syncWidgetData stores all widget payload fields and triggers update',
      () async {
        final success = await service.syncWidgetData(
          nextPrayerName: 'Asr',
          nextPrayerTime: '3:45 PM',
          activeSlot: 'Post-Dhuhr Barakah',
          dhikrCount: 33,
          appTitle: 'Productive Muslim',
          nextPrayerLabel: 'Next Prayer',
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
        expect(
          mockStorage.data[HomeWidgetSyncService.keyNextPrayerName],
          'Asr',
        );
        expect(
          mockStorage.data[HomeWidgetSyncService.keyNextPrayerTime],
          '3:45 PM',
        );
        expect(
          mockStorage.data[HomeWidgetSyncService.keyDhikrCount],
          'Dhikr: 33',
        );
        expect(
          mockStorage.updatedWidgetName,
          HomeWidgetSyncService.androidWidgetProvider,
        );
      },
    );

    test(
      'syncWidgetData supports custom dhikr text for Arabic localization',
      () async {
        final success = await service.syncWidgetData(
          nextPrayerName: 'العصر',
          nextPrayerTime: '٣:٤٥ م',
          activeSlot: 'ساعة البركة',
          dhikrCount: 99,
          appTitle: 'المسلم المنتج',
          nextPrayerLabel: 'الصلاة القادمة',
          customDhikrText: 'الأذكار: ٩٩ منجزة',
        );

        expect(success, isTrue);
        expect(
          mockStorage.data[HomeWidgetSyncService.keyAppTitle],
          'المسلم المنتج',
        );
        expect(
          mockStorage.data[HomeWidgetSyncService.keyDhikrCount],
          'الأذكار: ٩٩ منجزة',
        );
      },
    );

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
  });
}
