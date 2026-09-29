import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/qibla_service.dart';

void main() {
  late QiblaService qiblaService;

  setUp(() {
    qiblaService = QiblaService();
  });

  group('QiblaService', () {
    test('calculates bearing and distance for Mecca (Kaaba coords)', () {
      final bearing = qiblaService.getQiblaBearing(
        QiblaService.kaabaLat,
        QiblaService.kaabaLng,
      );
      final distance = qiblaService.getDistanceToKaabaKm(
        QiblaService.kaabaLat,
        QiblaService.kaabaLng,
      );

      expect(distance, closeTo(0.0, 1.0));
      expect(bearing, isNotNull);
    });

    test('calculates accurate bearing and distance from Cairo', () {
      // Cairo coords: 30.0444° N, 31.2357° E
      final bearing = qiblaService.getQiblaBearing(30.0444, 31.2357);
      final distance = qiblaService.getDistanceToKaabaKm(30.0444, 31.2357);

      // Cairo Qibla is Southeast (~136°)
      expect(bearing, closeTo(136.0, 5.0));
      // Distance Cairo -> Mecca is approx 1285 km
      expect(distance, closeTo(1285.0, 50.0));
    });

    test('calculates accurate bearing and distance from London', () {
      // London coords: 51.5074° N, -0.1278° W
      final bearing = qiblaService.getQiblaBearing(51.5074, -0.1278);
      final distance = qiblaService.getDistanceToKaabaKm(51.5074, -0.1278);

      // London Qibla is East-Southeast (~118°)
      expect(bearing, closeTo(118.0, 5.0));
      // Distance London -> Mecca is approx 4790 km
      expect(distance, closeTo(4790.0, 100.0));
    });

    test('calculates accurate bearing and distance from New York', () {
      // New York coords: 40.7128° N, -74.0060° W
      final bearing = qiblaService.getQiblaBearing(40.7128, -74.0060);
      final distance = qiblaService.getDistanceToKaabaKm(40.7128, -74.0060);

      // New York Qibla via Great Circle is East-Northeast (~58°)
      expect(bearing, closeTo(58.0, 5.0));
      // Distance NYC -> Mecca is approx 10250 km
      expect(distance, closeTo(10250.0, 200.0));
    });
  });
}
