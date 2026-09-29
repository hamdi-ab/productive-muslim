import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart';

class QiblaService {
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  double getQiblaBearing(double latitude, double longitude) {
    return Qibla.qibla(Coordinates(latitude, longitude));
  }

  double getDistanceToKaabaKm(double latitude, double longitude) {
    const double earthRadiusKm = 6371.0;
    final dLat = _toRadians(kaabaLat - latitude);
    final dLng = _toRadians(kaabaLng - longitude);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(kaabaLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180.0;
}
