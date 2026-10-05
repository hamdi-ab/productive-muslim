import 'dart:async';
import 'package:flutter/foundation.dart';

abstract class HomeWidgetStorage {
  Future<bool?> saveWidgetData<T>(String id, T? data);
  Future<T?> getWidgetData<T>(String id, {T? defaultValue});
  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  });
  Future<Uri?> initiallyLaunchedFromHomeWidget();
  Stream<Uri?> get widgetClicked;
  Future<bool?> registerInteractivityCallback(
    FutureOr<void> Function(Uri?) callback,
  );
}

class DefaultHomeWidgetStorage implements HomeWidgetStorage {
  final Map<String, dynamic> _inMemory = {};

  DefaultHomeWidgetStorage();

  @override
  Future<bool?> saveWidgetData<T>(String id, T? data) async {
    _inMemory[id] = data;
    return true;
  }

  @override
  Future<T?> getWidgetData<T>(String id, {T? defaultValue}) async {
    return (_inMemory[id] as T?) ?? defaultValue;
  }

  @override
  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) async {
    return true;
  }

  @override
  Future<Uri?> initiallyLaunchedFromHomeWidget() async {
    return null;
  }

  @override
  Stream<Uri?> get widgetClicked => const Stream.empty();

  @override
  Future<bool?> registerInteractivityCallback(
    FutureOr<void> Function(Uri?) callback,
  ) async {
    return true;
  }
}


@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  if (uri != null &&
      (uri.host == 'increment_tasbih' ||
          uri.path == '/increment_tasbih' ||
          (uri.scheme == 'productivemuslim' &&
              uri.host == 'increment_tasbih'))) {
    final service = HomeWidgetSyncService();
    await service.incrementDhikrCountDirectly();
  }
}

class HomeWidgetSyncService {
  final HomeWidgetStorage _storage;

  static const String androidWidgetProvider = 'PrayerBarakahWidgetProvider';

  static const String keyAppTitle = 'widget_app_title';
  static const String keyActiveSlot = 'widget_active_slot';
  static const String keyHijriDate = 'widget_hijri_date';
  static const String keyFastingBadge = 'widget_fasting_badge';
  static const String keyNextPrayerLabel = 'widget_next_prayer_label';
  static const String keyNextPrayerName = 'widget_next_prayer_name';
  static const String keyNextPrayerTime = 'widget_next_prayer_time';
  static const String keyNextPrayerCountdown = 'widget_next_prayer_countdown';
  static const String keyDhikrCount = 'widget_dhikr_count';
  static const String keyDhikrRawCount = 'widget_dhikr_raw_count';
  static const String keyBtnPrayers = 'widget_btn_prayers';
  static const String keyBtnAdhkar = 'widget_btn_adhkar';
  static const String keyBtnFocus = 'widget_btn_focus';
  static const String keyBtnPlusOne = 'widget_btn_plus_one';

  HomeWidgetSyncService({HomeWidgetStorage? storage})
    : _storage = storage ?? DefaultHomeWidgetStorage();

  Future<bool> registerBackgroundCallback([
    FutureOr<void> Function(Uri?) callback = homeWidgetBackgroundCallback,
  ]) async {
    try {
      final res = await _storage.registerInteractivityCallback(callback);
      return res ?? true;
    } catch (e) {
      debugPrint('Failed to register HomeWidget interactivity callback: $e');
      return false;
    }
  }

  Future<bool> syncWidgetData({
    required String nextPrayerName,
    required String nextPrayerTime,
    required String activeSlot,
    required int dhikrCount,
    String hijriDate = '',
    String fastingBadge = '',
    String nextPrayerCountdown = '',
    String appTitle = 'Productive Muslim',
    String nextPrayerLabel = 'Next Prayer',
    String btnPrayers = 'Prayers',
    String btnAdhkar = 'Adhkar',
    String btnFocus = 'Focus',
    String btnPlusOne = '+1',
    String? customDhikrText,
  }) async {
    try {
      final dhikrDisplay = customDhikrText ?? 'Dhikr: $dhikrCount';

      await _storage.saveWidgetData<String>(keyAppTitle, appTitle);
      await _storage.saveWidgetData<String>(keyActiveSlot, activeSlot);
      await _storage.saveWidgetData<String>(keyHijriDate, hijriDate);
      await _storage.saveWidgetData<String>(keyFastingBadge, fastingBadge);
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
      await _storage.saveWidgetData<int>(keyDhikrRawCount, dhikrCount);
      await _storage.saveWidgetData<String>(keyBtnPrayers, btnPrayers);
      await _storage.saveWidgetData<String>(keyBtnAdhkar, btnAdhkar);
      await _storage.saveWidgetData<String>(keyBtnFocus, btnFocus);
      await _storage.saveWidgetData<String>(keyBtnPlusOne, btnPlusOne);

      final updated = await _storage.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
      );

      return updated ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<int?> getStoredDhikrRawCount() async {
    try {
      return await _storage.getWidgetData<int>(keyDhikrRawCount);
    } catch (_) {
      return null;
    }
  }

  Future<bool> syncDhikrCount(int count, {String? customDhikrText}) async {
    try {
      final dhikrDisplay = customDhikrText ?? 'Dhikr: $count';
      await _storage.saveWidgetData<String>(keyDhikrCount, dhikrDisplay);
      await _storage.saveWidgetData<int>(keyDhikrRawCount, count);
      final updated = await _storage.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
      );
      return updated ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<int> incrementDhikrCountDirectly({
    int delta = 1,
    String? customPrefix,
  }) async {
    try {
      final current = await _storage.getWidgetData<int>(
        keyDhikrRawCount,
        defaultValue: 0,
      );
      final newCount = (current ?? 0) + delta;
      final prefix = customPrefix ?? 'Dhikr: ';
      final display = '$prefix$newCount';

      await _storage.saveWidgetData<int>(keyDhikrRawCount, newCount);
      await _storage.saveWidgetData<String>(keyDhikrCount, display);

      await _storage.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
      );

      return newCount;
    } catch (_) {
      return 0;
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
