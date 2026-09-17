import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_prompt.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  const sources = [
    'good_intentions',
    'piety',
    'trust_in_allah',
    'quran',
    'bismillah',
    'eating_together',
    'honesty_in_trade',
    'dua',
    'halal_income',
    'sunnah',
    'istikhara',
    'gratitude',
    'charity',
    'kinship',
    'early_rising',
    'marriage',
    'salah',
    'forgiveness',
  ];

  test('catalog has the fixed eighteen versioned canonical mappings', () {
    expect(BarakahPrompt.all.length, 18);
    for (var i = 0; i < sources.length; i++) {
      expect(BarakahPrompt.all[i].id, '${sources[i]}_v1');
      expect(BarakahPrompt.all[i].sourceIds, [sources[i]]);
    }
    expect(BarakahPrompt.all.map((p) => p.id).toSet().length, 18);
    expect(() => BarakahPrompt.all.clear(), throwsUnsupportedError);
    expect(
      () => BarakahPrompt.all.first.sourceIds.clear(),
      throwsUnsupportedError,
    );
  });

  test('rotation is pinned to UTC days since the Unix epoch', () {
    expect(BarakahPrompt.forDate('1970-01-01').id, 'good_intentions_v1');
    expect(BarakahPrompt.forDate('1970-01-02').id, 'piety_v1');
    expect(BarakahPrompt.forDate('1969-12-31').id, 'forgiveness_v1');
    expect(BarakahPrompt.forDate('1970-01-19').id, 'good_intentions_v1');
    expect(
      BarakahPrompt.forDate('2026-09-17'),
      same(BarakahPrompt.forDate('2026-09-17')),
    );
  });

  test('every ten-day window has no repeat across years and leap days', () {
    final start = DateTime.utc(2023, 12, 20);
    for (var offset = 0; offset < 400; offset++) {
      final ids = {
        for (var day = 0; day < 10; day++)
          BarakahPrompt.forDate(
            start
                .add(Duration(days: offset + day))
                .toIso8601String()
                .substring(0, 10),
          ).id,
      };
      expect(ids.length, 10);
    }
  });

  test('calendar dates advance once over DST in multiple time zones', () {
    tz_data.initializeTimeZones();
    for (final location in [
      'America/New_York',
      'Europe/London',
      'Asia/Riyadh',
    ]) {
      tz.setLocalLocation(tz.getLocation(location));
      for (final dates in [
        ['2026-03-07', '2026-03-08', '2026-03-09'],
        ['2026-10-31', '2026-11-01', '2026-11-02'],
        ['2026-03-28', '2026-03-29', '2026-03-30'],
        ['2026-10-24', '2026-10-25', '2026-10-26'],
        ['2024-02-28', '2024-02-29', '2024-03-01'],
        ['2026-12-31', '2027-01-01', '2027-01-02'],
      ]) {
        final first = BarakahPrompt.all.indexOf(
          BarakahPrompt.forDate(dates.first),
        );
        for (var i = 0; i < dates.length; i++) {
          expect(
            BarakahPrompt.forDate(dates[i]),
            same(BarakahPrompt.all[(first + i) % 18]),
          );
        }
      }
    }
    tz.setLocalLocation(tz.UTC);
  });

  test('rejects invalid dates, timestamps and timezone offsets', () {
    for (final date in [
      '',
      '2026-9-17',
      '2026-09-17\n',
      ' 2026-09-17',
      '2026-02-29',
      '2026-02-30',
      '2026-00-01',
      '2026-13-01',
      '2026-01-00',
      '2026-04-31',
      '2026-09-17T00:00:00Z',
      '2026-09-17T23:00:00-05:00',
    ]) {
      expect(
        () => BarakahPrompt.forDate(date),
        throwsArgumentError,
        reason: date,
      );
    }
    expect(BarakahPrompt.forDate('2024-02-29'), isA<BarakahPrompt>());
  });

  test('daily responses defensively copy sources', () {
    final sourceIds = ['good_intentions'];
    final response = BarakahDailyResponse(
      date: '1970-01-01',
      promptId: 'good_intentions_v1',
      answer: BarakahAnswer.yes,
      sourceIds: sourceIds,
      createdAt: 1,
      updatedAt: 1,
    );
    sourceIds.clear();
    expect(response.sourceIds, ['good_intentions']);
    expect(() => response.sourceIds.clear(), throwsUnsupportedError);
  });
}
