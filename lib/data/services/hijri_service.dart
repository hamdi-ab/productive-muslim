import 'package:hijri/hijri_calendar.dart';

class HijriDateInfo {
  final int hYear;
  final int hMonth;
  final int hDay;
  final String monthNameEn;
  final String monthNameAr;
  final bool isWhiteDay;
  final bool isMondayOrThursday;
  final DateTime gregorianDate;

  const HijriDateInfo({
    required this.hYear,
    required this.hMonth,
    required this.hDay,
    required this.monthNameEn,
    required this.monthNameAr,
    required this.isWhiteDay,
    required this.isMondayOrThursday,
    required this.gregorianDate,
  });

  bool get isSunnahFastingDay => isMondayOrThursday || isWhiteDay;

  String formatEn() => '$hDay $monthNameEn $hYear AH';
  String formatAr() => '$hDay $monthNameAr $hYear هـ';
}

class HijriService {
  static const List<String> monthNamesEn = [
    'Muharram',
    'Safar',
    "Rabi' al-Awwal",
    "Rabi' al-Thani",
    'Jumada al-Ula',
    'Jumada al-Akhirah',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    "Dhu al-Qi'dah",
    'Dhu al-Hijjah',
  ];

  static const List<String> monthNamesAr = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  HijriDateInfo getHijriDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final monthIndex = (hijri.hMonth - 1).clamp(0, 11);
    final isWhiteDay =
        (hijri.hDay == 13 || hijri.hDay == 14 || hijri.hDay == 15);
    final isMonOrThu =
        (date.weekday == DateTime.monday || date.weekday == DateTime.thursday);

    return HijriDateInfo(
      hYear: hijri.hYear,
      hMonth: hijri.hMonth,
      hDay: hijri.hDay,
      monthNameEn: monthNamesEn[monthIndex],
      monthNameAr: monthNamesAr[monthIndex],
      isWhiteDay: isWhiteDay,
      isMondayOrThursday: isMonOrThu,
      gregorianDate: date,
    );
  }

  List<HijriDateInfo> getMonthDays(DateTime referenceMonth) {
    final daysInMonth = DateTime(
      referenceMonth.year,
      referenceMonth.month + 1,
      0,
    ).day;

    return List.generate(daysInMonth, (index) {
      final dayDate = DateTime(
        referenceMonth.year,
        referenceMonth.month,
        index + 1,
      );
      return getHijriDate(dayDate);
    });
  }

  ({bool isSunnah, String? reasonEn, String? reasonAr}) getSunnahFastingStatus(
    DateTime date,
  ) {
    final info = getHijriDate(date);
    if (info.isWhiteDay && info.isMondayOrThursday) {
      return (
        isSunnah: true,
        reasonEn:
            'White Day (${info.hDay}th) & ${date.weekday == DateTime.monday ? "Monday" : "Thursday"} Sunnah',
        reasonAr:
            'من الأيام البيض (${info.hDay}) وسنة ${date.weekday == DateTime.monday ? "الإثنين" : "الخميس"}',
      );
    } else if (info.isWhiteDay) {
      return (
        isSunnah: true,
        reasonEn: 'White Day (${info.hDay}th of ${info.monthNameEn})',
        reasonAr: 'اليوم الأبيض (${info.hDay} من ${info.monthNameAr})',
      );
    } else if (info.isMondayOrThursday) {
      return (
        isSunnah: true,
        reasonEn:
            '${date.weekday == DateTime.monday ? "Monday" : "Thursday"} Sunnah Fast',
        reasonAr:
            'صيام سنة يوم ${date.weekday == DateTime.monday ? "الإثنين" : "الخميس"}',
      );
    }
    return (isSunnah: false, reasonEn: null, reasonAr: null);
  }
}
