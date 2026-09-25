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

  PrayerTimes? getPrayerTimes(Position position) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationMethodParameters.muslimWorldLeague();

    return PrayerTimes(
      date: DateTime.now(),
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
}
