import 'package:adhan_dart/adhan_dart.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/data/services/home_widget_sync_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';

class AdhkarService {
  final SettingsService _settingsService;
  final HomeWidgetSyncService? _homeWidgetSyncService;

  AdhkarService({
    PrayerTimeService? prayerTimeService,
    required SettingsService settingsService,
    HomeWidgetSyncService? homeWidgetSyncService,
  }) : _settingsService = settingsService,
       _homeWidgetSyncService = homeWidgetSyncService;

  DhikrCategory getCurrentContextCategory({
    DateTime? now,
    PrayerTimes? prayerTimes,
  }) {
    final currentTime = (now ?? DateTime.now()).toLocal();
    final pt = prayerTimes;

    if (pt != null) {
      final fajr = pt.fajr.toLocal();
      final sunrise = pt.sunrise.toLocal();
      final asr = pt.asr.toLocal();
      final maghrib = pt.maghrib.toLocal();
      final isha = pt.isha.toLocal();

      // Morning: from Fajr until 2 hours after Sunrise
      final morningEnd = sunrise.add(const Duration(minutes: 120));
      if (currentTime.isAfter(fajr) && currentTime.isBefore(morningEnd)) {
        return DhikrCategory.morning;
      }

      // Evening: from Asr until Maghrib
      if (currentTime.isAfter(asr) && currentTime.isBefore(maghrib)) {
        return DhikrCategory.evening;
      }

      // Sleeping: post-Isha or night
      if (currentTime.isAfter(isha) ||
          currentTime.hour >= 21 ||
          currentTime.hour < 4) {
        return DhikrCategory.sleeping;
      }
    }

    // Fallback clock heuristics if prayer times not available
    final hour = currentTime.hour;
    if (hour >= 4 && hour < 11) {
      return DhikrCategory.morning;
    } else if (hour >= 15 && hour < 19) {
      return DhikrCategory.evening;
    } else if (hour >= 21 || hour < 4) {
      return DhikrCategory.sleeping;
    }

    return DhikrCategory.morning;
  }

  Future<void> recordDhikrCompletion({
    required String dhikrId,
    String? date,
  }) async {
    final targetDate =
        date ?? DateTime.now().toIso8601String().substring(0, 10);
    await _settingsService.addCompletedDhikr(targetDate, dhikrId);
    final count = getCompletedDhikrIdsForDate(targetDate).length;
    await _homeWidgetSyncService?.syncDhikrCount(count);
  }

  List<String> getCompletedDhikrIdsForDate(String? date) {
    final targetDate =
        date ?? DateTime.now().toIso8601String().substring(0, 10);
    return _settingsService.getCompletedDhikrIds(targetDate);
  }

  Future<void> recordDhikrCount({
    required String dhikrId,
    required int count,
    String? date,
  }) async {
    final targetDate =
        date ?? DateTime.now().toIso8601String().substring(0, 10);
    await _settingsService.setDhikrCount(targetDate, dhikrId, count);
  }

  int getDhikrCount(String dhikrId, {String? date}) {
    final targetDate =
        date ?? DateTime.now().toIso8601String().substring(0, 10);
    return _settingsService.getDhikrCount(targetDate, dhikrId);
  }

  Future<void> resetDhikr({required String dhikrId, String? date}) async {
    final targetDate =
        date ?? DateTime.now().toIso8601String().substring(0, 10);
    await _settingsService.removeCompletedDhikr(targetDate, dhikrId);
    final count = getCompletedDhikrIdsForDate(targetDate).length;
    await _homeWidgetSyncService?.syncDhikrCount(count);
  }

  Future<void> resetCategory(DhikrCategory category, {String? date}) async {
    final targetDate =
        date ?? DateTime.now().toIso8601String().substring(0, 10);
    final items = AdhkarCatalog.getByCategory(category);
    await _settingsService.resetCategoryDhikrs(
      targetDate,
      items.map((i) => i.id).toList(),
    );
    final count = getCompletedDhikrIdsForDate(targetDate).length;
    await _homeWidgetSyncService?.syncDhikrCount(count);
  }

  bool isDhikrCompleted(String dhikrId, {String? date}) {
    final completed = getCompletedDhikrIdsForDate(date);
    return completed.contains(dhikrId);
  }

  int getCompletedCountForCategory(DhikrCategory category, {String? date}) {
    final items = AdhkarCatalog.getByCategory(category);
    final completed = getCompletedDhikrIdsForDate(date);
    return items.where((i) => completed.contains(i.id)).length;
  }
}
