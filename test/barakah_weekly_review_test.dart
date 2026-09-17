import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_weekly_review.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

BarakahDailyResponse response(
  String date,
  BarakahAnswer answer,
  List<String> sources,
) => BarakahDailyResponse(
  date: date,
  promptId: 'unknown_v0',
  answer: answer,
  sourceIds: sources,
  note: 'Saved note',
  createdAt: 1,
  updatedAt: 2,
);

void main() {
  test('Monday through Sunday across year and leap-day boundaries', () {
    for (final (date, start, end) in [
      (DateTime(2026, 9, 14), '2026-09-14', '2026-09-20'),
      (DateTime(2026, 9, 20, 23, 59), '2026-09-14', '2026-09-20'),
      (DateTime(2026, 9, 21), '2026-09-21', '2026-09-27'),
      (DateTime(2026, 1, 1), '2025-12-29', '2026-01-04'),
      (DateTime(2024, 2, 29), '2024-02-26', '2024-03-03'),
    ]) {
      final week = BarakahReviewWeek.forDate(date, now: date);
      expect(week.startDate, start);
      expect(week.endDate, end);
      expect(week.canGoNext, isFalse);
      expect(week.start.weekday, DateTime.monday);
      expect(week.end.weekday, DateTime.sunday);
    }
  });

  test('civil dates stay consecutive through DST in multiple zones', () {
    tzdata.initializeTimeZones();
    for (final (zone, month, day) in [
      ('America/New_York', 3, 8),
      ('America/New_York', 11, 1),
      ('Europe/Berlin', 3, 29),
      ('Europe/Berlin', 10, 25),
      ('Australia/Sydney', 4, 5),
      ('Australia/Sydney', 10, 4),
    ]) {
      final location = tz.getLocation(zone);
      final sunday = tz.TZDateTime(location, 2026, month, day, 23, 30);
      final week = BarakahReviewWeek.forDate(sunday, now: sunday);
      expect(week.endDate, BarakahReviewWeek.dateKey(sunday), reason: zone);
      for (var offset = 0; offset < 7; offset++) {
        final expected = tz.TZDateTime(location, 2026, month, day - 6 + offset);
        expect(
          BarakahReviewWeek.dateKey(week.day(offset)),
          BarakahReviewWeek.dateKey(expected),
        );
        expect(week.day(offset).weekday, offset + 1);
      }
      final nextMonday = tz.TZDateTime(location, 2026, month, day + 1);
      expect(
        BarakahReviewWeek.dateKey(week.day(7)),
        BarakahReviewWeek.dateKey(nextMonday),
      );
    }
  });

  test('counts self-reports, deduplicates per day and excludes non-affirmed sources', () {
    final now = DateTime(2026, 9, 20);
    final week = BarakahReviewWeek.forDate(now, now: now);
    final review = BarakahWeeklyReview(week, [
      response('2026-09-15', BarakahAnswer.somewhat, [
        'quran',
        'unknown',
        'unknown',
      ]),
      response('2026-09-14', BarakahAnswer.yes, ['quran', 'quran']),
      response('2026-09-16', BarakahAnswer.no, ['quran', 'ignored']),
      response('2026-09-17', BarakahAnswer.skip, ['ignored']),
      response('2026-09-13', BarakahAnswer.yes, ['outside']),
      response('2026-09-21', BarakahAnswer.yes, ['outside']),
    ]);
    expect(review.savedCount, 4);
    expect(review.answerCounts, {
      for (final answer in BarakahAnswer.values) answer: 1,
    });
    expect(review.sourceCounts, {'quran': 2, 'unknown': 1});
    expect(review.days.first.response!.note, 'Saved note');
    expect(review.days[3].response!.answer, BarakahAnswer.skip);
    expect(review.days[4].response, isNull);
    expect(review.days[4].future, isFalse);
    expect(review.days.map((day) => day.date.weekday), [1, 2, 3, 4, 5, 6, 7]);
    expect(() => review.days.clear(), throwsUnsupportedError);
  });

  test('partial week distinguishes unanswered from upcoming and ignores future rows', () {
    final now = DateTime(2026, 9, 16, 12);
    final week = BarakahReviewWeek.forDate(now, now: now);
    final review = BarakahWeeklyReview(week, [
      response('2026-09-14', BarakahAnswer.skip, []),
      response('2026-09-17', BarakahAnswer.yes, ['quran']),
    ]);
    expect(review.days.map((day) => day.future), [
      false,
      false,
      false,
      true,
      true,
      true,
      true,
    ]);
    expect(review.days[1].response, isNull);
    expect(review.days[2].response, isNull);
    expect(review.days[3].response, isNull);
    expect(review.savedCount, 1);
    expect(review.sourceCounts, isEmpty);
    expect(BarakahReviewWeek.forDate(week.day(-7), now: now).canGoNext, isTrue);
  });

  test('empty review retains all seven days with zero descriptive counts', () {
    final now = DateTime(2026, 9, 14);
    final review = BarakahWeeklyReview(
      BarakahReviewWeek.forDate(now, now: now),
      [],
    );
    expect(review.savedCount, 0);
    expect(review.answerCounts.values, everyElement(0));
    expect(review.sourceCounts, isEmpty);
    expect(review.days, hasLength(7));
  });
}
