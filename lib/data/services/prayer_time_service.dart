import 'package:adhan_dart/adhan_dart.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/data/services/settings_service.dart';

class PrayerTimeService {
  Position? _cachedPosition;
  PrayerTimes? _cachedPrayerTimes;
  String? _cachedLocationName;
  Future<Position?>? _ongoingFetch;

  Position? get cachedPosition => _cachedPosition;
  PrayerTimes? get cachedPrayerTimes => _cachedPrayerTimes;
  String? get cachedLocationName => _cachedLocationName;

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

  Future<Position?> _fetchPositionInternal() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _fallbackFromCacheOrStorage();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _fallbackFromCacheOrStorage();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _fallbackFromCacheOrStorage();
      }

      // First check last known position quickly
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && _cachedPosition == null) {
        _updateCache(lastKnown);
      }

      // Fetch fresh position with 4-second timeout to avoid hardware GPS hang
      Position? fresh;
      try {
        fresh = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 4),
          ),
        );
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

  Position? _fallbackFromCacheOrStorage() {
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
        _updateCache(pos);
        resolvePlacemarkCity(coords.latitude, coords.longitude);
        return pos;
      }
    }

    return null;
  }

  void _updateCache(Position position) {
    _cachedPosition = position;
    _cachedPrayerTimes = getPrayerTimes(position);
    _cachedLocationName = getLocationName(position);

    if (getIt.isRegistered<SettingsService>()) {
      final settings = getIt<SettingsService>();
      settings.setLastCoordinates(position.latitude, position.longitude);
      if (_cachedLocationName != null &&
          !_cachedLocationName!.contains('°')) {
        settings.setLastLocationName(_cachedLocationName!);
      }
    }
  }

  Future<String?> resolvePlacemarkCity(
    double latitude,
    double longitude,
  ) async {
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

    try {
      final name = tz.local.name;
      if (name.contains('/')) {
        final city = name.split('/').last.replaceAll('_', ' ');
        if (city.isNotEmpty &&
            city.toUpperCase() != 'UTC' &&
            city.toUpperCase() != 'LOCAL') {
          _cachedLocationName = city;
          return city;
        }
      }
    } catch (_) {}

    _cachedLocationName ??= 'My Location';
    return _cachedLocationName;
  }

  PrayerTimes? getPrayerTimes(Position position, {DateTime? date}) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationMethodParameters.muslimWorldLeague();

    return PrayerTimes(
      date: date ?? DateTime.now(),
      coordinates: coordinates,
      calculationParameters: params,
    );
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

    try {
      final name = tz.local.name;
      if (name.contains('/')) {
        final city = name.split('/').last.replaceAll('_', ' ');
        if (city.isNotEmpty &&
            city.toUpperCase() != 'UTC' &&
            city.toUpperCase() != 'LOCAL') {
          return city;
        }
      }
    } catch (_) {}

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
