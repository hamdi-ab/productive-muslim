import 'package:flutter_test/flutter_test.dart';
import 'package:productive_muslim/data/services/hijri_service.dart';

void main() {
  late HijriService service;

  setUp(() {
    service = HijriService();
  });

  test('getHijriDate returns valid HijriDateInfo for a known date', () {
    final testDate = DateTime(2026, 9, 30);
    final info = service.getHijriDate(testDate);

    expect(info.hYear, greaterThan(1440));
    expect(info.hMonth, inInclusiveRange(1, 12));
    expect(info.hDay, inInclusiveRange(1, 30));
    expect(info.monthNameEn, isNotEmpty);
    expect(info.monthNameAr, isNotEmpty);
    expect(info.gregorianDate, testDate);
  });

  test('correctly identifies White Days (13th, 14th, 15th)', () {
    // Check multiple days to find a White Day
    bool foundWhiteDay = false;
    final now = DateTime.now();
    for (int i = 0; i < 35; i++) {
      final d = now.add(Duration(days: i));
      final info = service.getHijriDate(d);
      if (info.hDay == 13 || info.hDay == 14 || info.hDay == 15) {
        expect(info.isWhiteDay, isTrue);
        expect(info.isSunnahFastingDay, isTrue);
        foundWhiteDay = true;
      } else {
        expect(info.isWhiteDay, isFalse);
      }
    }
    expect(foundWhiteDay, isTrue);
  });

  test('correctly identifies Monday and Thursday Sunnah fasts', () {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final d = now.add(Duration(days: i));
      final info = service.getHijriDate(d);
      if (d.weekday == DateTime.monday || d.weekday == DateTime.thursday) {
        expect(info.isMondayOrThursday, isTrue);
        expect(info.isSunnahFastingDay, isTrue);
      } else {
        expect(info.isMondayOrThursday, isFalse);
      }
    }
  });

  test('getMonthDays returns correct number of days for given month', () {
    final reference = DateTime(2026, 2, 1);
    final days = service.getMonthDays(reference);
    expect(days.length, 28); // 2026 is not a leap year
  });

  test(
    'getSunnahFastingStatus returns valid reasons in Arabic and English',
    () {
      final now = DateTime.now();
      for (int i = 0; i < 14; i++) {
        final d = now.add(Duration(days: i));
        final status = service.getSunnahFastingStatus(d);
        if (status.isSunnah) {
          expect(status.reasonEn, isNotNull);
          expect(status.reasonAr, isNotNull);
        }
      }
    },
  );
}
