import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/timezone.dart' as tz;

class PrayerTimeService {
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
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
    try {
      final name = tz.local.name;
      if (name.contains('/')) {
        final city = name.split('/').last.replaceAll('_', ' ');
        if (city.isNotEmpty && city.toUpperCase() != 'UTC') {
          return city;
        }
      }
    } catch (_) {}

    if (position != null) {
      final lat = position.latitude.toStringAsFixed(2);
      final lon = position.longitude.toStringAsFixed(2);
      return '$lat°, $lon°';
    }

    return 'Local';
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
