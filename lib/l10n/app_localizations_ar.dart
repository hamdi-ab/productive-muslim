// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'المسلم المنتج';

  @override
  String homeGreeting(Object name) {
    return 'صباح الخير، $name';
  }

  @override
  String get prayerTimes => 'مواقيت الصلاة';

  @override
  String get taskTitle => 'عنوان المهمة';

  @override
  String tasksCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهام',
      one: 'مهمة واحدة',
      zero: 'لا توجد مهام',
    );
    return '$_temp0';
  }

  @override
  String get intentionSet => 'تم تحديد نيتك';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get nextStep => 'استمر';

  @override
  String get setMyIntention => 'حدد نيتك';

  @override
  String get startYourDay => 'ابدأ يومك';

  @override
  String get name => 'الاسم';

  @override
  String get yourName => 'اسمك';

  @override
  String get introduction => 'ما الذي ي bringingك اليوم؟';

  @override
  String get seekingBarakah => 'أبحث عن بارة في وقتي';

  @override
  String get consistentWorship => 'عبادة مستمرة وروتين';

  @override
  String get mindfulProductivity => 'كفاءة واعية';

  @override
  String get writeYourOwn => 'أو اكتب半个تك';

  @override
  String get allowLocation =>
      'سمح بالوصول للموقع للحصول على مواقيت صلاة دقيقة؟';

  @override
  String get calculationMethod => 'طريقة الحساب';

  @override
  String get tasks => 'المهام';

  @override
  String get habits => 'العادات';

  @override
  String get barakah => 'بركة';

  @override
  String get journal => 'يومية';

  @override
  String get home => 'الصفحة الرئيسية';

  @override
  String get newTask => 'مهمة جديدة';

  @override
  String get newHabit => 'عادت جديدة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get done => 'تم';

  @override
  String get skip => ' Amber';

  @override
  String get remindMeLater => 'ذكرني لاحقاً';

  @override
  String get error => 'حدث خطأ';

  @override
  String get retry => 'أعد المحاولة';

  @override
  String get loading => 'Loading...';

  @override
  String get emptyTasks => 'لا توجد مهام اليوم';

  @override
  String get emptyHabits => 'لا توجد عادات بعد';

  @override
  String get emptyIntentions => 'لا توجد نيات بعد';

  @override
  String get emptyBarakah => 'لا توجد إدخلات برة بعد';

  @override
  String get active => 'نشيط';

  @override
  String get reflected => 'تم التفكير';

  @override
  String get archived => 'أرشيف';

  @override
  String streak(Object count) {
    return '$count يوم متتالي';
  }

  @override
  String get nextPrayer => 'الصلوة القادمة';

  @override
  String inTime(Object time) {
    return 'خلال $time';
  }

  @override
  String get today => 'اليوم';

  @override
  String get week => 'أسبوع';

  @override
  String get all => 'الكل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get notifications => 'الإخطارات';

  @override
  String get theme => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get light => 'الفاتح';

  @override
  String get dark => 'الغامق';

  @override
  String get system => 'النظام';

  @override
  String get fajr => 'الفجر';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String get adhan => 'الأذان';

  @override
  String get islam => 'إسلام';

  @override
  String get family => 'أسماء';

  @override
  String get work => 'عمل';

  @override
  String get personalDev => 'تطور شخصي';
}
