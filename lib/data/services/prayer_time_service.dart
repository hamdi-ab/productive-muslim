import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/utils/platform_timezone.dart';
import 'package:productive_muslim/data/services/adhan_notification_service.dart';
import 'package:productive_muslim/data/services/prayer_notification_scheduler.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/prayer_times/models/prayer_calculation_options.dart';

class PrayerTimeService {
  PrayerTimeService({SettingsService? settingsService})
    : _settingsService = settingsService {
    try {
      tz_data.initializeTimeZones();
    } catch (_) {}
  }

  final SettingsService? _settingsService;

  Position? _cachedPosition;
  PrayerTimes? _cachedPrayerTimes;
  String? _cachedLocationName;
  Future<Position?>? _ongoingFetch;

  Position? get cachedPosition => _cachedPosition;
  PrayerTimes? get cachedPrayerTimes {
    final now = DateTime.now();
    if (_cachedPrayerTimes != null &&
        _cachedPosition != null &&
        _cachedPrayerTimes!.fajr.day != now.day) {
      _cachedPrayerTimes = getPrayerTimes(_cachedPosition!, date: now);
    }
    return _cachedPrayerTimes;
  }

  String? get cachedLocationName => _cachedLocationName;

  /// Returns the in-memory cached position or constructs a position from
  /// previously saved coordinates in [SettingsService] without requesting
  /// location permission or interacting with GPS.
  ///
  /// Returns null if neither in-memory cache nor saved coordinates are available.
  Position? getCachedOrSavedPosition() {
    if (_cachedPosition != null) return _cachedPosition;

    if (getIt.isRegistered<SettingsService>()) {
      final settings = getIt<SettingsService>();
      final coords = settings.lastCoordinates;
      if (coords != null) {
        final pos = Position(
          longitude: coords.longitude,
          latitude: coords.latitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        _cachedPosition = pos;
        return pos;
      }
    }
    return null;
  }

  @visibleForTesting
  void setCachedPositionForTesting(Position? position) {
    _cachedPosition = position;
  }

  Future<Position?> getCurrentPosition() async {
    if (_ongoingFetch != null) {
      return await _ongoingFetch;
    }

    _ongoingFetch = _fetchPositionInternal();
    try {
      final pos = await _ongoingFetch;
      return pos;
    } finally {
      _ongoingFetch = null;
    }
  }

  @visibleForTesting
  static bool disableBackgroundGeolocatorTimers = false;

  static bool get _isInTestEnvironment {
    if (disableBackgroundGeolocatorTimers) return true;
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    return bindingName.contains('TestWidgetsFlutterBinding') ||
        bindingName.contains('AutomatedTestWidgetsFlutterBinding');
  }

  Future<Position?> _fetchPositionInternal() async {
    if (_isInTestEnvironment) {
      return _fallbackFromCacheOrStorage();
    }
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 2), onTimeout: () => true);
      if (!serviceEnabled) {
        return _fallbackFromCacheOrStorage();
      }

      var permission = LocationPermission.unableToDetermine;
      try {
        permission = await Geolocator.checkPermission().timeout(
          const Duration(seconds: 2),
        );
      } catch (_) {}

      if (permission == LocationPermission.denied) {
        try {
          permission = await Geolocator.requestPermission().timeout(
            const Duration(seconds: 4),
          );
        } catch (_) {}
        if (permission == LocationPermission.denied) {
          return _fallbackFromCacheOrStorage();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _fallbackFromCacheOrStorage();
      }

      // Check last known position quickly (not supported on Web)
      Position? lastKnown;
      if (!kIsWeb) {
        try {
          lastKnown = await Geolocator.getLastKnownPosition().timeout(
            const Duration(seconds: 2),
          );
          if (lastKnown != null && _cachedPosition == null) {
            _updateCache(lastKnown);
          }
        } catch (_) {}
      }

      // Fetch fresh position with bounded Dart timeout so it never hangs indefinitely
      Position? fresh;
      try {
        fresh = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: kIsWeb ? LocationAccuracy.low : LocationAccuracy.medium,
            timeLimit: Duration(seconds: kIsWeb ? 6 : 4),
          ),
        ).timeout(Duration(seconds: kIsWeb ? 7 : 5));
      } catch (_) {
        fresh = lastKnown ?? _cachedPosition;
      }

      if (fresh != null) {
        await resolvePlacemarkCity(fresh.latitude, fresh.longitude);
        _updateCache(fresh);
        return fresh;
      }

      return _fallbackFromCacheOrStorage();
    } catch (_) {
      return _fallbackFromCacheOrStorage();
    }
  }

  Position _fallbackFromCacheOrStorage() {
    if (_cachedPosition != null) return _cachedPosition!;

    if (getIt.isRegistered<SettingsService>()) {
      final settings = getIt<SettingsService>();
      final coords = settings.lastCoordinates;
      if (coords != null) {
        final pos = Position(
          longitude: coords.longitude,
          latitude: coords.latitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        _updateCache(pos);
        resolvePlacemarkCity(coords.latitude, coords.longitude);
        return pos;
      }
    }

    // Timezone / UTC offset heuristic fallback (critical on Web / Desktop where GPS is absent)
    final tzFallback = _getPositionFromTimezone();
    _updateCache(tzFallback);
    return tzFallback;
  }

  Position _getPositionFromTimezone() {
    String? name;
    try {
      name = getPlatformTimeZone();
    } catch (_) {}

    if (name == null || name.isEmpty || name == 'UTC' || name == 'local') {
      try {
        name = tz.local.name;
      } catch (_) {}
    }

    if (name == null || name.isEmpty || name == 'UTC' || name == 'local') {
      try {
        final tzName = DateTime.now().timeZoneName;
        if (tzName.isNotEmpty && tzName != 'UTC' && tzName != 'local') {
          name = tzName;
        }
      } catch (_) {}
    }

    final (lat, lng, cityName) = _lookupTimezoneCoordinates(name ?? '');
    final pos = Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 1000,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    _cachedLocationName = cityName;
    if (getIt.isRegistered<SettingsService>()) {
      final settings = getIt<SettingsService>();
      settings.setLastCoordinates(lat, lng);
      settings.setLastLocationName(cityName);
    }
    return pos;
  }

  (double, double, String) _lookupTimezoneCoordinates(String tzName) {
    final key = tzName.trim().replaceAll(' ', '_');
    final lowerKey = key.toLowerCase();

    const tzMap = <String, (double, double, String)>{
      'Africa/Cairo': (30.0444, 31.2357, 'Cairo'),
      'Africa/Alexandria': (31.2001, 29.9187, 'Alexandria'),
      'Asia/Riyadh': (24.7136, 46.6753, 'Riyadh'),
      'Asia/Makkah': (21.4225, 39.8262, 'Makkah'),
      'Asia/Jeddah': (21.5433, 39.1728, 'Jeddah'),
      'Asia/Madinah': (24.5247, 39.5692, 'Madinah'),
      'Asia/Dubai': (25.2048, 55.2708, 'Dubai'),
      'Asia/Abu_Dhabi': (24.4539, 54.3773, 'Abu Dhabi'),
      'Asia/Muscat': (23.5880, 58.3829, 'Muscat'),
      'Asia/Kuwait': (29.3759, 47.9774, 'Kuwait City'),
      'Asia/Qatar': (25.2854, 51.5310, 'Doha'),
      'Asia/Bahrain': (26.2285, 50.5860, 'Manama'),
      'Asia/Amman': (31.9454, 35.9284, 'Amman'),
      'Asia/Baghdad': (33.3152, 44.3661, 'Baghdad'),
      'Asia/Beirut': (33.8938, 35.5018, 'Beirut'),
      'Asia/Jerusalem': (31.7683, 35.2137, 'Jerusalem'),
      'Asia/Gaza': (31.5017, 34.4668, 'Gaza'),
      'Asia/Hebron': (31.5326, 35.0998, 'Hebron'),
      'Asia/Damascus': (33.5138, 36.2765, 'Damascus'),
      'Africa/Casablanca': (33.5731, -7.5898, 'Casablanca'),
      'Africa/Rabat': (34.0209, -6.8416, 'Rabat'),
      'Africa/Algiers': (36.7538, 3.0588, 'Algiers'),
      'Africa/Tunis': (36.8065, 10.1815, 'Tunis'),
      'Africa/Tripoli': (32.8872, 13.1913, 'Tripoli'),
      'Africa/Khartoum': (15.5007, 32.5599, 'Khartoum'),
      'Asia/Karachi': (24.8607, 67.0011, 'Karachi'),
      'Asia/Lahore': (31.5204, 74.3587, 'Lahore'),
      'Asia/Islamabad': (33.6844, 73.0479, 'Islamabad'),
      'Asia/Dhaka': (23.8103, 90.4125, 'Dhaka'),
      'Asia/Jakarta': (-6.2088, 106.8456, 'Jakarta'),
      'Asia/Kuala_Lumpur': (3.1390, 101.6869, 'Kuala Lumpur'),
      'Asia/Singapore': (1.3521, 103.8198, 'Singapore'),
      'Asia/Kolkata': (28.6139, 77.2090, 'New Delhi'),
      'Asia/Colombo': (6.9271, 79.8612, 'Colombo'),
      'Asia/Tashkent': (41.2995, 69.2401, 'Tashkent'),
      'Asia/Baku': (40.4093, 49.8671, 'Baku'),
      'Asia/Kabul': (34.5553, 69.2075, 'Kabul'),
      'Asia/Tehran': (35.6892, 51.3890, 'Tehran'),
      'Europe/Istanbul': (41.0082, 28.9784, 'Istanbul'),
      'Europe/London': (51.5074, -0.1278, 'London'),
      'Europe/Paris': (48.8566, 2.3522, 'Paris'),
      'Europe/Berlin': (52.5200, 13.4050, 'Berlin'),
      'Europe/Madrid': (40.4168, -3.7038, 'Madrid'),
      'Europe/Rome': (41.9028, 12.4964, 'Rome'),
      'Europe/Amsterdam': (52.3676, 4.9041, 'Amsterdam'),
      'Europe/Brussels': (50.8503, 4.3517, 'Brussels'),
      'Europe/Stockholm': (59.3293, 18.0686, 'Stockholm'),
      'Europe/Oslo': (59.9139, 10.7522, 'Oslo'),
      'Europe/Moscow': (55.7558, 37.6173, 'Moscow'),
      'America/New_York': (40.7128, -74.0060, 'New York'),
      'America/Chicago': (41.8781, -87.6298, 'Chicago'),
      'America/Toronto': (43.6532, -79.3832, 'Toronto'),
      'America/Los_Angeles': (34.0522, -118.2437, 'Los Angeles'),
      'America/Denver': (39.7392, -104.9903, 'Denver'),
      'America/Phoenix': (33.4484, -112.0740, 'Phoenix'),
      'Australia/Sydney': (-33.8688, 151.2093, 'Sydney'),
      'Australia/Melbourne': (-37.8136, 144.9631, 'Melbourne'),
      'Asia/Tokyo': (35.6762, 139.6503, 'Tokyo'),
      'Asia/Seoul': (37.5665, 126.9780, 'Seoul'),
      'AST': (24.7136, 46.6753, 'Riyadh'),
      'Arabian_Standard_Time': (24.7136, 46.6753, 'Riyadh'),
      'Saudi_Arabia_Standard_Time': (24.7136, 46.6753, 'Riyadh'),
      'EEST': (30.0444, 31.2357, 'Cairo'),
      'EET': (30.0444, 31.2357, 'Cairo'),
      'Egypt_Standard_Time': (30.0444, 31.2357, 'Cairo'),
      'GST': (25.2048, 55.2708, 'Dubai'),
      'Gulf_Standard_Time': (25.2048, 55.2708, 'Dubai'),
      'PKT': (24.8607, 67.0011, 'Karachi'),
      'Pakistan_Standard_Time': (24.8607, 67.0011, 'Karachi'),
      'BST': (23.8103, 90.4125, 'Dhaka'),
      'Bangladesh_Standard_Time': (23.8103, 90.4125, 'Dhaka'),
      'WIB': (-6.2088, 106.8456, 'Jakarta'),
      'GMT': (51.5074, -0.1278, 'London'),
      'CET': (48.8566, 2.3522, 'Paris'),
      'CEST': (48.8566, 2.3522, 'Paris'),
      'EST': (40.7128, -74.0060, 'New York'),
      'EDT': (40.7128, -74.0060, 'New York'),
      'Eastern_Standard_Time': (40.7128, -74.0060, 'New York'),
      'PST': (34.0522, -118.2437, 'Los Angeles'),
      'PDT': (34.0522, -118.2437, 'Los Angeles'),
      'Pacific_Standard_Time': (34.0522, -118.2437, 'Los Angeles'),
    };

    if (key.isNotEmpty && tzMap.containsKey(key)) {
      return tzMap[key]!;
    }

    if (lowerKey.isNotEmpty) {
      for (final entry in tzMap.entries) {
        if (entry.key.toLowerCase() == lowerKey ||
            entry.key.split('/').last.toLowerCase() == lowerKey ||
            lowerKey.endsWith(entry.key.split('/').last.toLowerCase())) {
          return entry.value;
        }
      }
    }

    // Default UTC-offset heuristics
    final offsetHours = DateTime.now().timeZoneOffset.inHours;
    return switch (offsetHours) {
      3 => (21.4225, 39.8262, 'Makkah'),
      2 => (30.0444, 31.2357, 'Cairo'),
      4 => (25.2048, 55.2708, 'Dubai'),
      5 => (24.8607, 67.0011, 'Karachi'),
      6 => (23.8103, 90.4125, 'Dhaka'),
      7 || 8 => (-6.2088, 106.8456, 'Jakarta'),
      0 || 1 => (51.5074, -0.1278, 'London'),
      -4 || -5 => (40.7128, -74.0060, 'New York'),
      -7 || -8 => (34.0522, -118.2437, 'Los Angeles'),
      _ => (21.4225, 39.8262, 'Makkah'),
    };
  }

  void _updateCache(Position position) {
    _cachedPosition = position;
    _cachedPrayerTimes = getPrayerTimes(position);
    _cachedLocationName = getLocationName(position);

    if (getIt.isRegistered<SettingsService>()) {
      final settings = getIt<SettingsService>();
      settings.setLastCoordinates(position.latitude, position.longitude);
      if (_cachedLocationName != null && !_cachedLocationName!.contains('°')) {
        settings.setLastLocationName(_cachedLocationName!);
      }
    }
  }

  Future<String?> resolvePlacemarkCity(
    double latitude,
    double longitude,
  ) async {
    if (!kIsWeb) {
      try {
        final placemarks = await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final city = place.locality?.isNotEmpty == true
              ? place.locality
              : place.subAdministrativeArea?.isNotEmpty == true
              ? place.subAdministrativeArea
              : place.subLocality?.isNotEmpty == true
              ? place.subLocality
              : place.administrativeArea?.isNotEmpty == true
              ? place.administrativeArea
              : place.name?.isNotEmpty == true
              ? place.name
              : place.country;
          if (city != null && city.isNotEmpty) {
            _cachedLocationName = city;
            if (getIt.isRegistered<SettingsService>()) {
              getIt<SettingsService>().setLastLocationName(city);
            }
            return city;
          }
        }
      } catch (_) {}
    }

    if (getIt.isRegistered<SettingsService>()) {
      final storedName = getIt<SettingsService>().lastLocationName;
      if (storedName != null &&
          storedName.isNotEmpty &&
          storedName != 'Local' &&
          !storedName.contains('°')) {
        _cachedLocationName = storedName;
        return storedName;
      }
    }

    String? name;
    try {
      name = getPlatformTimeZone();
    } catch (_) {}

    if (name == null || name.isEmpty || name == 'UTC' || name == 'local') {
      try {
        name = tz.local.name;
      } catch (_) {}
    }

    if (name != null && name.contains('/')) {
      final city = name.split('/').last.replaceAll('_', ' ');
      if (city.isNotEmpty &&
          city.toUpperCase() != 'UTC' &&
          city.toUpperCase() != 'LOCAL') {
        _cachedLocationName = city;
        return city;
      }
    }

    _cachedLocationName ??= 'My Location';
    return _cachedLocationName;
  }

  SettingsService? get _effectiveSettings =>
      _settingsService ??
      (getIt.isRegistered<SettingsService>() ? getIt<SettingsService>() : null);

  PrayerTimes? getPrayerTimes(Position position, {DateTime? date}) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final settings = _effectiveSettings;
    final method =
        settings?.prayerCalculationMethod ??
        CalculationMethod.muslimWorldLeague;
    final madhab = settings?.prayerMadhab ?? Madhab.shafi;
    final params = PrayerCalculationOptions.buildParameters(
      method: method,
      madhab: madhab,
    );

    return PrayerTimes(
      date: date ?? DateTime.now(),
      coordinates: coordinates,
      calculationParameters: params,
    );
  }

  /// Recomputes in-memory prayer times cache using the current position and
  /// active calculation preferences.
  void refreshPrayerTimesCache() {
    final pos = getCachedOrSavedPosition();
    if (pos != null) {
      _cachedPrayerTimes = getPrayerTimes(pos);
    } else {
      _cachedPrayerTimes = null;
    }
  }

  /// Refreshes in-memory caches and reschedules all active prayer notifications
  /// and solar-anchored reminders to reflect updated calculation or madhab settings.
  Future<void> onPrayerCalculationSettingsChanged() async {
    refreshPrayerTimesCache();

    // 1. Reschedule Adhan notifications if active
    final settings = _effectiveSettings;
    if (settings != null &&
        settings.adhanNotificationsEnabled &&
        getIt.isRegistered<AdhanNotificationService>()) {
      final adhanService = getIt<AdhanNotificationService>();
      final pos = getCachedOrSavedPosition();
      if (pos != null) {
        final times = getPrayerTimes(pos);
        if (times != null) {
          await adhanService.cancelAll();
          await adhanService.schedulePrayerNotifications(
            fajr: times.fajr,
            dhuhr: times.dhuhr,
            asr: times.asr,
            maghrib: times.maghrib,
            isha: times.isha,
          );
        }
      }
    }

    // 2. Reschedule Smart Reminders / Sunnah (Qaylulah depends on Dhuhr)
    if (getIt.isRegistered<PrayerNotificationScheduler>()) {
      final scheduler = getIt<PrayerNotificationScheduler>();
      final pos = getCachedOrSavedPosition();
      if (pos != null) {
        final now = DateTime.now();
        final times = getPrayerTimes(pos, date: now);
        final tomorrowTimes = getPrayerTimes(
          pos,
          date: now.add(const Duration(days: 1)),
        );
        await scheduler.rescheduleAll(
          prayerTimes: times,
          tomorrowPrayerTimes: tomorrowTimes,
        );
      } else {
        await scheduler.rescheduleLocationIndependentReminders();
      }
    }
  }

  String? getNextPrayerName(PrayerTimes prayerTimes) {
    final now = DateTime.now();

    if (prayerTimes.fajr.isAfter(now)) return 'Fajr';
    if (prayerTimes.sunrise.isAfter(now)) return 'Sunrise';
    if (prayerTimes.dhuhr.isAfter(now)) return 'Dhuhr';
    if (prayerTimes.asr.isAfter(now)) return 'Asr';
    if (prayerTimes.maghrib.isAfter(now)) return 'Maghrib';
    if (prayerTimes.isha.isAfter(now)) return 'Isha';

    return 'Fajr'; // next day
  }

  DateTime? getNextPrayerTime(PrayerTimes prayerTimes) {
    final now = DateTime.now();

    if (prayerTimes.fajr.isAfter(now)) return prayerTimes.fajr;
    if (prayerTimes.sunrise.isAfter(now)) return prayerTimes.sunrise;
    if (prayerTimes.dhuhr.isAfter(now)) return prayerTimes.dhuhr;
    if (prayerTimes.asr.isAfter(now)) return prayerTimes.asr;
    if (prayerTimes.maghrib.isAfter(now)) return prayerTimes.maghrib;
    if (prayerTimes.isha.isAfter(now)) return prayerTimes.isha;

    return prayerTimes.fajr.add(const Duration(days: 1));
  }

  Duration? getTimeUntilNextPrayer(PrayerTimes prayerTimes) {
    final now = DateTime.now();

    if (prayerTimes.fajr.isAfter(now)) return prayerTimes.fajr.difference(now);
    if (prayerTimes.sunrise.isAfter(now)) {
      return prayerTimes.sunrise.difference(now);
    }
    if (prayerTimes.dhuhr.isAfter(now)) {
      return prayerTimes.dhuhr.difference(now);
    }
    if (prayerTimes.asr.isAfter(now)) return prayerTimes.asr.difference(now);
    if (prayerTimes.maghrib.isAfter(now)) {
      return prayerTimes.maghrib.difference(now);
    }
    if (prayerTimes.isha.isAfter(now)) {
      return prayerTimes.isha.difference(now);
    }

    final tomorrowFajr = prayerTimes.fajr.add(const Duration(days: 1));
    return tomorrowFajr.difference(now);
  }

  String getLocationName(Position? position) {
    if (_cachedLocationName != null &&
        _cachedLocationName!.isNotEmpty &&
        !_cachedLocationName!.contains('°')) {
      return _cachedLocationName!;
    }

    if (getIt.isRegistered<SettingsService>()) {
      final storedName = getIt<SettingsService>().lastLocationName;
      if (storedName != null &&
          storedName.isNotEmpty &&
          storedName != 'Local' &&
          !storedName.contains('°')) {
        return storedName;
      }
    }

    String? name;
    try {
      name = getPlatformTimeZone();
    } catch (_) {}

    if (name == null || name.isEmpty || name == 'UTC' || name == 'local') {
      try {
        name = tz.local.name;
      } catch (_) {}
    }

    if (name != null && name.contains('/')) {
      final city = name.split('/').last.replaceAll('_', ' ');
      if (city.isNotEmpty &&
          city.toUpperCase() != 'UTC' &&
          city.toUpperCase() != 'LOCAL') {
        return city;
      }
    }

    return 'My Location';
  }

  ({int startMinutes, int endMinutes}) getSlotMinutes(
    String slotId,
    PrayerTimes? prayerTimes,
  ) {
    if (prayerTimes != null) {
      int toMins(DateTime dt) {
        final local = dt.toLocal();
        return local.hour * 60 + local.minute;
      }

      switch (slotId) {
        case 'early_morning':
          return (
            startMinutes: toMins(prayerTimes.fajr),
            endMinutes: toMins(prayerTimes.sunrise),
          );
        case 'duha':
          return (
            startMinutes: toMins(
              prayerTimes.sunrise.add(const Duration(minutes: 20)),
            ),
            endMinutes: toMins(prayerTimes.dhuhr),
          );
        case 'dhuhr':
          return (
            startMinutes: toMins(prayerTimes.dhuhr),
            endMinutes: toMins(prayerTimes.asr),
          );
        case 'asr':
          return (
            startMinutes: toMins(prayerTimes.asr),
            endMinutes: toMins(prayerTimes.maghrib),
          );
        case 'maghrib':
          return (
            startMinutes: toMins(prayerTimes.maghrib),
            endMinutes: toMins(prayerTimes.isha),
          );
        case 'isha':
          return (
            startMinutes: toMins(prayerTimes.isha),
            endMinutes: toMins(
              prayerTimes.isha.add(const Duration(minutes: 90)),
            ),
          );
      }
    }

    // Default fallback approximations
    switch (slotId) {
      case 'early_morning':
        return (startMinutes: 330, endMinutes: 420); // 5:30 - 7:00
      case 'duha':
        return (startMinutes: 540, endMinutes: 690); // 9:00 - 11:30
      case 'dhuhr':
        return (startMinutes: 780, endMinutes: 900); // 13:00 - 15:00
      case 'asr':
        return (startMinutes: 990, endMinutes: 1080); // 16:30 - 18:00
      case 'maghrib':
        return (startMinutes: 1110, endMinutes: 1185); // 18:30 - 19:45
      case 'isha':
        return (startMinutes: 1230, endMinutes: 1320); // 20:30 - 22:00
      default:
        return (startMinutes: 540, endMinutes: 600);
    }
  }
}
