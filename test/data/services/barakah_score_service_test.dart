import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/barakah_score_service.dart';

void main() {
  group('BarakahScoreService', () {
    late BarakahScoreService service;

    setUp(() {
      service = BarakahScoreService();
    });

    test('calculateActivitySummary returns factual counts for fresh user', () {
      final summary = service.calculateActivitySummary(
        overallStreak: 0,
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

      expect(summary.completedHabitsToday, equals(0));
      expect(summary.totalHabitsToday, equals(0));
      expect(summary.focusMinutes, equals(0));
      expect(summary.barakahEntriesToday, equals(0));
      expect(summary.hasDailyResponse, isFalse);
      expect(summary.hasActivityToday, isFalse);
    });

    test(
      'calculateActivitySummary records factual activity metrics faithfully',
      () {
        final summary = service.calculateActivitySummary(
          overallStreak: 7,
          focusMinutes: 45,
          completedDhikrCount: 3,
          isSunnahFasting: true,
          completedHabitsToday: 3,
          totalHabitsToday: 4,
          barakahEntriesToday: 2,
          hasDailyResponse: true,
          completedTasksToday: 5,
          totalTasksToday: 6,
        );

        expect(summary.overallStreak, equals(7));
        expect(summary.focusMinutes, equals(45));
        expect(summary.completedDhikrCount, equals(3));
        expect(summary.isSunnahFasting, isTrue);
        expect(summary.completedHabitsToday, equals(3));
        expect(summary.totalHabitsToday, equals(4));
        expect(summary.barakahEntriesToday, equals(2));
        expect(summary.hasDailyResponse, isTrue);
        expect(summary.completedTasksToday, equals(5));
        expect(summary.totalTasksToday, equals(6));
        expect(summary.hasActivityToday, isTrue);
      },
    );
  });
}
