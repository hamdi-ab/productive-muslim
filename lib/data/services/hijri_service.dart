import 'package:hijri/hijri_calendar.dart';

class HijriDateInfo {
  final int hYear;
  final int hMonth;
  final int hDay;
  final String monthNameEn;
  final String monthNameAr;
  final bool isWhiteDay;
  final bool isMondayOrThursday;
  final bool isArafah;
  final bool isAshura;
  final bool isTasua;
  final bool isProhibited;
  final DateTime gregorianDate;

  const HijriDateInfo({
    required this.hYear,
    required this.hMonth,
    required this.hDay,
    required this.monthNameEn,
    required this.monthNameAr,
    required this.isWhiteDay,
    required this.isMondayOrThursday,
    this.isArafah = false,
    this.isAshura = false,
    this.isTasua = false,
    this.isProhibited = false,
    required this.gregorianDate,
  });

  bool get isSunnahFastingDay {
    if (isProhibited) return false;
    return isArafah || isAshura || isTasua || isMondayOrThursday || isWhiteDay;
  }

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

    // Prohibited days:
    // 1. Eid al-Fitr: 1st Shawwal (10:1)
    // 2. Eid al-Adha: 10th Dhu al-Hijjah (12:10)
    // 3. Days of Tashriq: 11th, 12th, 13th Dhu al-Hijjah (12:11, 12:12, 12:13)
    final isEidAlFitr = hijri.hMonth == 10 && hijri.hDay == 1;
    final isEidAlAdha = hijri.hMonth == 12 && hijri.hDay == 10;
    final isTashriq =
        hijri.hMonth == 12 && (hijri.hDay >= 11 && hijri.hDay <= 13);
    final isProhibited = isEidAlFitr || isEidAlAdha || isTashriq;

    // Special Sunnah fasts
    final isArafah = hijri.hMonth == 12 && hijri.hDay == 9;
    final isAshura = hijri.hMonth == 1 && hijri.hDay == 10;
    final isTasua = hijri.hMonth == 1 && hijri.hDay == 9;

    // White Days (13th, 14th, 15th) - Note: 13th Dhu al-Hijjah is Tashriq so prohibited
    final isWhiteDay =
        (hijri.hDay == 13 && hijri.hMonth != 12) ||
        hijri.hDay == 14 ||
        hijri.hDay == 15;

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
      isArafah: isArafah,
      isAshura: isAshura,
      isTasua: isTasua,
      isProhibited: isProhibited,
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
    if (info.isProhibited) {
      return (isSunnah: false, reasonEn: null, reasonAr: null);
    }

    if (info.isArafah) {
      return (
        isSunnah: true,
        reasonEn: 'Day of Arafah Sunnah (9th Dhu al-Hijjah)',
        reasonAr: 'صيام يوم عرفة (٩ ذو الحجة)',
      );
    } else if (info.isAshura) {
      return (
        isSunnah: true,
        reasonEn: 'Day of Ashura Sunnah (10th Muharram)',
        reasonAr: 'صيام يوم عاشوراء (١٠ محرم)',
      );
    } else if (info.isTasua) {
      return (
        isSunnah: true,
        reasonEn: 'Day of Tasu\'a Sunnah (9th Muharram)',
        reasonAr: 'صيام يوم تاسوعاء (٩ محرم)',
      );
    } else if (info.isWhiteDay && info.isMondayOrThursday) {
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
