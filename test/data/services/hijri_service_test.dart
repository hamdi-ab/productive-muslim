import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';
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
        if (!info.isProhibited) {
          expect(info.isWhiteDay, isTrue);
          expect(info.isSunnahFastingDay, isTrue);
          foundWhiteDay = true;
        }
      } else {
        expect(info.isWhiteDay, isFalse);
      }
    }
    expect(foundWhiteDay, isTrue);
  });

  test('prohibits fasting on Eid al-Fitr, Eid al-Adha and Tashriq days', () {
    // 1st Shawwal
    final eidFitrHijri = HijriCalendar()
      ..hYear = 1448
      ..hMonth = 10
      ..hDay = 1;
    final eidFitrGreg = eidFitrHijri.hijriToGregorian(1448, 10, 1);
    final fitrInfo = service.getHijriDate(eidFitrGreg);
    expect(fitrInfo.isProhibited, isTrue);
    expect(fitrInfo.isSunnahFastingDay, isFalse);
    expect(service.getSunnahFastingStatus(eidFitrGreg).isSunnah, isFalse);

    // 10th Dhu al-Hijjah (Eid al-Adha)
    final eidAdhaGreg = HijriCalendar().hijriToGregorian(1448, 12, 10);
    final adhaInfo = service.getHijriDate(eidAdhaGreg);
    expect(adhaInfo.isProhibited, isTrue);
    expect(adhaInfo.isSunnahFastingDay, isFalse);

    // 11th Dhu al-Hijjah (Tashriq)
    final tashriqGreg = HijriCalendar().hijriToGregorian(1448, 12, 11);
    final tashriqInfo = service.getHijriDate(tashriqGreg);
    expect(tashriqInfo.isProhibited, isTrue);
    expect(tashriqInfo.isSunnahFastingDay, isFalse);
  });

  test(
    'identifies Day of Arafah and Day of Ashura with special localized reasons',
    () {
      // 9th Dhu al-Hijjah (Arafah)
      final arafahGreg = HijriCalendar().hijriToGregorian(1448, 12, 9);
      final arafahInfo = service.getHijriDate(arafahGreg);
      expect(arafahInfo.isArafah, isTrue);
      expect(arafahInfo.isSunnahFastingDay, isTrue);
      final arafahStatus = service.getSunnahFastingStatus(arafahGreg);
      expect(arafahStatus.isSunnah, isTrue);
      expect(arafahStatus.reasonEn, contains('Arafah'));
      expect(arafahStatus.reasonAr, contains('عرفة'));

      // 10th Muharram (Ashura)
      final ashuraGreg = HijriCalendar().hijriToGregorian(1448, 1, 10);
      final ashuraInfo = service.getHijriDate(ashuraGreg);
      expect(ashuraInfo.isAshura, isTrue);
      expect(ashuraInfo.isSunnahFastingDay, isTrue);
      final ashuraStatus = service.getSunnahFastingStatus(ashuraGreg);
      expect(ashuraStatus.isSunnah, isTrue);
      expect(ashuraStatus.reasonEn, contains('Ashura'));
      expect(ashuraStatus.reasonAr, contains('عاشوراء'));
    },
  );

  test('correctly identifies Monday and Thursday Sunnah fasts', () {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final d = now.add(Duration(days: i));
      final info = service.getHijriDate(d);
      if ((d.weekday == DateTime.monday || d.weekday == DateTime.thursday) &&
          !info.isProhibited) {
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
}
