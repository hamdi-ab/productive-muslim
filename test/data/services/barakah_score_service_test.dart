import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/barakah_score_service.dart';

void main() {
  group('BarakahScoreService', () {
    late BarakahScoreService service;

    setUp(() {
      service = BarakahScoreService();
    });

    test('calculateScores returns balanced baseline scores for fresh user', () {
      final scores = service.calculateScores(
        overallStreak: 0,
        energy: (physical: 3, spiritual: 3, mental: 3),
        focusMinutes: 0,
        completedDhikrCount: 0,
        isSunnahFasting: false,
        completedHabitsToday: 0,
        totalHabitsToday: 0,
        barakahEntriesToday: 0,
        hasDailyResponse: false,
        completedTasksToday: 0,
        totalTasksToday: 0,
      );

      expect(scores.dimensions.length, equals(9));
      expect(scores.scorePercent, greaterThan(0.5));
      expect(scores.scorePoints, greaterThan(50));
      expect(scores.topStrength, isNotNull);
      expect(scores.growthFocus, isNotNull);
      expect(
        scores.topStrength.score,
        greaterThanOrEqualTo(scores.growthFocus.score),
      );
    });

    test('calculateScores reflects high engagement and streak boost', () {
      final baseScores = service.calculateScores(
        overallStreak: 0,
        energy: (physical: 2, spiritual: 2, mental: 2),
        focusMinutes: 0,
        completedDhikrCount: 0,
        isSunnahFasting: false,
        completedHabitsToday: 0,
        totalHabitsToday: 3,
        barakahEntriesToday: 0,
        hasDailyResponse: false,
        completedTasksToday: 0,
        totalTasksToday: 3,
      );

      final activeScores = service.calculateScores(
        overallStreak: 7,
        energy: (physical: 5, spiritual: 5, mental: 5),
        focusMinutes: 45,
        completedDhikrCount: 3,
        isSunnahFasting: true,
        completedHabitsToday: 3,
        totalHabitsToday: 3,
        barakahEntriesToday: 2,
        hasDailyResponse: true,
        completedTasksToday: 3,
        totalTasksToday: 3,
      );

      expect(activeScores.scorePoints, greaterThan(baseScores.scorePoints));
      expect(activeScores.scorePercent, greaterThan(baseScores.scorePercent));

      final istiqamah = activeScores.dimensions.firstWhere(
        (d) => d.key == 'istiqamah',
      );
      expect(istiqamah.score, greaterThan(80.0));

      final khushu = activeScores.dimensions.firstWhere(
        (d) => d.key == 'khushu',
      );
      expect(khushu.score, greaterThan(75.0));

      final ruh = activeScores.dimensions.firstWhere((d) => d.key == 'ruh');
      expect(ruh.score, greaterThan(85.0));
    });
  });
}
