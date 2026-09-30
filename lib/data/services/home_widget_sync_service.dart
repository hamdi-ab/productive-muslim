import 'dart:async';

import 'package:home_widget/home_widget.dart';

abstract class HomeWidgetStorage {
  Future<bool?> saveWidgetData<T>(String id, T? data);
  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  });
  Future<Uri?> initiallyLaunchedFromHomeWidget();
  Stream<Uri?> get widgetClicked;
}

class DefaultHomeWidgetStorage implements HomeWidgetStorage {
  const DefaultHomeWidgetStorage();

  @override
  Future<bool?> saveWidgetData<T>(String id, T? data) =>
      HomeWidget.saveWidgetData<T>(id, data);

  @override
  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) => HomeWidget.updateWidget(
    name: name,
    androidName: androidName,
    iOSName: iOSName,
    qualifiedAndroidName: qualifiedAndroidName,
  );

  @override
  Future<Uri?> initiallyLaunchedFromHomeWidget() =>
      HomeWidget.initiallyLaunchedFromHomeWidget();

  @override
  Stream<Uri?> get widgetClicked => HomeWidget.widgetClicked;
}

class HomeWidgetSyncService {
  final HomeWidgetStorage _storage;

  static const String androidWidgetProvider = 'PrayerBarakahWidgetProvider';

  static const String keyAppTitle = 'widget_app_title';
  static const String keyActiveSlot = 'widget_active_slot';
  static const String keyNextPrayerLabel = 'widget_next_prayer_label';
  static const String keyNextPrayerName = 'widget_next_prayer_name';
  static const String keyNextPrayerTime = 'widget_next_prayer_time';
  static const String keyNextPrayerCountdown = 'widget_next_prayer_countdown';
  static const String keyDhikrCount = 'widget_dhikr_count';
  static const String keyBtnPrayers = 'widget_btn_prayers';
  static const String keyBtnAdhkar = 'widget_btn_adhkar';
  static const String keyBtnFocus = 'widget_btn_focus';

  HomeWidgetSyncService({HomeWidgetStorage? storage})
    : _storage = storage ?? const DefaultHomeWidgetStorage();

  Future<bool> syncWidgetData({
    required String nextPrayerName,
    required String nextPrayerTime,
    required String activeSlot,
    required int dhikrCount,
    String nextPrayerCountdown = '',
    String appTitle = 'Productive Muslim',
    String nextPrayerLabel = 'Next Prayer',
    String btnPrayers = 'Prayers',
    String btnAdhkar = 'Adhkar',
    String btnFocus = 'Focus',
    String? customDhikrText,
  }) async {
    try {
      final dhikrDisplay = customDhikrText ?? 'Dhikr: $dhikrCount';

      await _storage.saveWidgetData<String>(keyAppTitle, appTitle);
      await _storage.saveWidgetData<String>(keyActiveSlot, activeSlot);
      await _storage.saveWidgetData<String>(
        keyNextPrayerLabel,
        nextPrayerLabel,
      );
      await _storage.saveWidgetData<String>(keyNextPrayerName, nextPrayerName);
      await _storage.saveWidgetData<String>(keyNextPrayerTime, nextPrayerTime);
      await _storage.saveWidgetData<String>(
        keyNextPrayerCountdown,
        nextPrayerCountdown,
      );
      await _storage.saveWidgetData<String>(keyDhikrCount, dhikrDisplay);
      await _storage.saveWidgetData<String>(keyBtnPrayers, btnPrayers);
      await _storage.saveWidgetData<String>(keyBtnAdhkar, btnAdhkar);
      await _storage.saveWidgetData<String>(keyBtnFocus, btnFocus);

      final updated = await _storage.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
      );

      return updated ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> syncDhikrCount(int count, {String? customDhikrText}) async {
    try {
      final dhikrDisplay = customDhikrText ?? 'Dhikr: $count completed';
      await _storage.saveWidgetData<String>(keyDhikrCount, dhikrDisplay);
      final updated = await _storage.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
      );
      return updated ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<Uri?> getInitiallyLaunchedUri() async {
    try {
      return await _storage.initiallyLaunchedFromHomeWidget();
    } catch (_) {
      return null;
    }
  }

  Stream<Uri?> get widgetClickedStream => _storage.widgetClicked;
}
