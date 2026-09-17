import 'package:productive_muslim/domain/models/barakah_daily_response.dart';

class BarakahReviewWeek {
  BarakahReviewWeek.forDate(DateTime date, {required DateTime now})
    : start = DateTime(date.year, date.month, date.day - date.weekday + 1),
      today = DateTime(now.year, now.month, now.day);

  final DateTime start;
  final DateTime today;

  DateTime day(int offset) =>
      DateTime(start.year, start.month, start.day + offset);
  DateTime get end => day(6);
  String get startDate => dateKey(start);
  String get endDate => dateKey(end);
  bool get canGoNext => !day(7).isAfter(today);

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class BarakahReviewDay {
  const BarakahReviewDay({
    required this.date,
    required this.future,
    this.response,
  });

  final DateTime date;
  final bool future;
  final BarakahDailyResponse? response;

  Set<String> get selectedSources => switch (response?.answer) {
    BarakahAnswer.yes || BarakahAnswer.somewhat => response!.sourceIds.toSet(),
    _ => const {},
  };
}

class BarakahWeeklyReview {
  BarakahWeeklyReview(
    BarakahReviewWeek week,
    List<BarakahDailyResponse> responses,
  ) : days = List.unmodifiable([
        for (var offset = 0; offset < 7; offset++)
          BarakahReviewDay(
            date: week.day(offset),
            future: week.day(offset).isAfter(week.today),
            response: week.day(offset).isAfter(week.today)
                ? null
                : _responseFor(
                    BarakahReviewWeek.dateKey(week.day(offset)),
                    responses,
                  ),
          ),
      ]);

  final List<BarakahReviewDay> days;

  static BarakahDailyResponse? _responseFor(
    String date,
    List<BarakahDailyResponse> responses,
  ) {
    for (final response in responses) {
      if (response.date == date) return response;
    }
    return null;
  }

  int get savedCount => days.where((day) => day.response != null).length;

  Map<BarakahAnswer, int> get answerCounts => Map.unmodifiable({
    for (final answer in BarakahAnswer.values)
      answer: days.where((day) => day.response?.answer == answer).length,
  });

  Map<String, int> get sourceCounts {
    final counts = <String, int>{};
    for (final day in days) {
      for (final source in day.selectedSources) {
        counts.update(source, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    final sources = counts.keys.toList()..sort();
    return Map.unmodifiable({
      for (final source in sources) source: counts[source]!,
    });
  }
}
