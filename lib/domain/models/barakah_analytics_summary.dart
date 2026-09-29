import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_weekly_review.dart';

class DayBarakahSnapshot {
  const DayBarakahSnapshot({
    required this.date,
    required this.isFuture,
    this.barakahAnswer,
    this.physicalEnergy = 3,
    this.spiritualEnergy = 3,
    this.mentalEnergy = 3,
    this.completedDhikrCount = 0,
    this.fastedSunnah = false,
  });

  final DateTime date;
  final bool isFuture;
  final BarakahAnswer? barakahAnswer;
  final int physicalEnergy;
  final int spiritualEnergy;
  final int mentalEnergy;
  final int completedDhikrCount;
  final bool fastedSunnah;

  bool get hasActiveRecord =>
      barakahAnswer != null || completedDhikrCount > 0 || fastedSunnah;
}

class BarakahWeeklyAnalytics {
  const BarakahWeeklyAnalytics({
    required this.week,
    required this.dailySnapshots,
    required this.avgPhysical,
    required this.avgSpiritual,
    required this.avgMental,
    required this.totalDhikrCompleted,
    required this.totalFastingDays,
    required this.activeDaysCount,
    required this.insights,
  });

  final BarakahReviewWeek week;
  final List<DayBarakahSnapshot> dailySnapshots;
  final double avgPhysical;
  final double avgSpiritual;
  final double avgMental;
  final int totalDhikrCompleted;
  final int totalFastingDays;
  final int activeDaysCount;
  final List<String> insights;

  factory BarakahWeeklyAnalytics.calculate({
    required BarakahWeeklyReview review,
    required BarakahReviewWeek week,
    required ({int physical, int spiritual, int mental}) Function(String date)
    getEnergy,
    required List<String> Function(String date) getDhikr,
    required bool Function(String date) isFasting,
    String languageCode = 'en',
  }) {
    final snapshots = <DayBarakahSnapshot>[];
    double sumP = 0;
    double sumS = 0;
    double sumM = 0;
    int ratedDays = 0;
    int totalDhikr = 0;
    int totalFasts = 0;
    int activeDays = 0;

    for (final day in review.days) {
      final key = BarakahReviewWeek.dateKey(day.date);
      if (day.future) {
        snapshots.add(DayBarakahSnapshot(date: day.date, isFuture: true));
        continue;
      }

      final energy = getEnergy(key);
      final dhikrs = getDhikr(key);
      final fasting = isFasting(key);

      sumP += energy.physical;
      sumS += energy.spiritual;
      sumM += energy.mental;
      ratedDays++;

      totalDhikr += dhikrs.length;
      if (fasting) totalFasts++;

      final snapshot = DayBarakahSnapshot(
        date: day.date,
        isFuture: false,
        barakahAnswer: day.response?.answer,
        physicalEnergy: energy.physical,
        spiritualEnergy: energy.spiritual,
        mentalEnergy: energy.mental,
        completedDhikrCount: dhikrs.length,
        fastedSunnah: fasting,
      );

      if (snapshot.hasActiveRecord) activeDays++;
      snapshots.add(snapshot);
    }

    final avgP = ratedDays > 0 ? (sumP / ratedDays) : 3.0;
    final avgS = ratedDays > 0 ? (sumS / ratedDays) : 3.0;
    final avgM = ratedDays > 0 ? (sumM / ratedDays) : 3.0;

    final isAr = languageCode.startsWith('ar');
    final insightsList = <String>[];

    if (totalDhikr > 5) {
      insightsList.add(
        isAr
            ? 'المحافظة على أذكار الصباح والمساء عززت صفاء ذهنك وطاقتك الروحية هذا الأسبوع.'
            : 'Consistent morning & evening remembrance elevated your spiritual presence and mental clarity.',
      );
    }

    if (totalFasts > 0) {
      insightsList.add(
        isAr ? 'صيام السنة جلب بركة ملحوظة في إدارة الوقت وضبط التركيز.' : 'Observing Sunnah fasts brought noticeable barakah and heightened intentionality to your week.',
      );
    }

    if (avgS >= 4.0 && avgM >= 4.0) {
      insightsList.add(
        isAr
            ? 'توازن ممتاز بين الطاقتين الروحية والذهنية يمثل التطبيق المثالي لنمط المسلم الإنتاجي.'
            : 'Strong harmony between spiritual and mental energy reflects the optimal Productive Muslim state.',
      );
    } else if (insightsList.isEmpty) {
      insightsList.add(
        isAr
            ? 'تثبيت نياتك اليومية والمداومة على الأذكار يحول روتينك اليومي إلى عبادة وإنتاجية مثمرة.'
            : 'Anchoring daily intentions and maintaining steady dhikr transforms routine into continuous barakah.',
      );
    }

    return BarakahWeeklyAnalytics(
      week: week,
      dailySnapshots: snapshots,
      avgPhysical: avgP,
      avgSpiritual: avgS,
      avgMental: avgM,
      totalDhikrCompleted: totalDhikr,
      totalFastingDays: totalFasts,
      activeDaysCount: activeDays,
      insights: insightsList,
    );
  }
}
