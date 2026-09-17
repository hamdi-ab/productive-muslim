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
  String get lifeArea => 'مجال الحياة';

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

  @override
  String get todayIntentions => 'نيات اليوم';

  @override
  String get noIntentionsToday => 'لا توجد نيات لليوم';

  @override
  String get reflection => 'تأمل';

  @override
  String get completed => 'مكتمل';

  @override
  String get saveReflection => 'حفظ التأمل';

  @override
  String get newIntention => 'نية جديدة';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get barakahDailyTitle => 'تأمل يومي في البركة';

  @override
  String barakahDailyQuestion(String promptId) {
    String _temp0 = intl.Intl.selectLogic(promptId, {
      'good_intentions_v1': 'هل جددت نيتك لله اليوم؟',
      'piety_v1': 'هل راعيت تقوى الله في اختياراتك اليوم؟',
      'trust_in_allah_v1': 'هل توكلت على الله مع الأخذ بالأسباب اليوم؟',
      'quran_v1': 'هل خصصت وقتًا للقرآن اليوم؟',
      'bismillah_v1': 'هل بدأت أعمالك بقول بسم الله اليوم؟',
      'eating_together_v1': 'هل شاركت الآخرين وجبة طعام اليوم؟',
      'honesty_in_trade_v1': 'هل تحريت الصدق في معاملاتك اليوم؟',
      'dua_v1': 'هل توجهت إلى الله بالدعاء اليوم؟',
      'halal_income_v1': 'هل سعيت إلى الرزق الحلال أو أنفقت منه اليوم؟',
      'sunnah_v1': 'هل عملت بشيء من السنة اليوم؟',
      'istikhara_v1': 'هل استخرت الله في قرار اليوم؟',
      'gratitude_v1': 'هل شكرت الله على نعمه اليوم؟',
      'charity_v1': 'هل تصدقت بشيء اليوم؟',
      'kinship_v1': 'هل وصلت رحمك اليوم؟',
      'early_rising_v1': 'هل اغتنمت وقت الصباح الباكر اليوم؟',
      'marriage_v1': 'هل عززت المودة في حياتك الزوجية اليوم؟',
      'salah_v1': 'هل خصصت وقتًا للصلاة اليوم؟',
      'forgiveness_v1': 'هل استغفرت الله اليوم؟',
      'other': 'هل لاحظت مصدرًا للبركة اليوم؟',
    });
    return '$_temp0';
  }

  @override
  String barakahDailySource(String sourceId) {
    String _temp0 = intl.Intl.selectLogic(sourceId, {
      'good_intentions': 'النية الصالحة',
      'piety': 'تقوى الله',
      'trust_in_allah': 'التوكل على الله',
      'quran': 'القرآن',
      'bismillah': 'قول بسم الله',
      'eating_together': 'الاجتماع على الطعام',
      'honesty_in_trade': 'الصدق في المعاملات',
      'dua': 'الدعاء',
      'halal_income': 'الرزق الحلال',
      'sunnah': 'اتباع السنة',
      'istikhara': 'الاستخارة',
      'gratitude': 'شكر الله',
      'charity': 'الصدقة',
      'kinship': 'صلة الرحم',
      'early_rising': 'التبكير',
      'marriage': 'المودة في الزواج',
      'salah': 'الصلاة',
      'forgiveness': 'الاستغفار',
      'other': 'مصدر البركة',
    });
    return '$_temp0';
  }

  @override
  String get barakahDailyYes => 'نعم';

  @override
  String get barakahDailySomewhat => 'إلى حد ما';

  @override
  String get barakahDailyNo => 'لا';

  @override
  String get barakahDailySkip => 'تخطي';

  @override
  String get barakahDailySources => 'مصادر البركة (اختياري)';

  @override
  String get barakahDailyNote => 'ملاحظة للتأمل (اختياري)';

  @override
  String get barakahDailySave => 'حفظ الإجابة';

  @override
  String get barakahDailyUpdate => 'حفظ التعديلات';

  @override
  String get barakahDailySaving => 'جارٍ حفظ الإجابة…';

  @override
  String get barakahDailySaved => 'تم حفظ إجابتك. يمكنك تعديلها في أي وقت.';

  @override
  String get barakahDailyFailure =>
      'تعذر تحميل إجابتك أو حفظها. يرجى المحاولة مرة أخرى.';

  @override
  String get barakahDailyRetry => 'المحاولة مرة أخرى';

  @override
  String get barakahHistoryTitle => 'سجل تأملات البركة الحرة';
}
