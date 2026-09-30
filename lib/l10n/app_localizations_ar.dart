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
  String get onboardingWelcomeTitle => 'ابنِ يومك حول ما يهم';

  @override
  String get onboardingWelcomeSubtitle =>
      'الصلاة، المهام، العادات، والنيات — كلها في مكان واحد';

  @override
  String get onboardingNameTitle => 'ما اسمك؟';

  @override
  String get onboardingNameSubtitle => 'نستخدمه لتخصيص تجربتك';

  @override
  String get onboardingIntentionTitle => 'ما الذي ي bringsك اليوم؟';

  @override
  String get onboardingIntentionSubtitle => 'اختر نيتك أو اكتبها بنفسك';

  @override
  String get onboardingPermissionTitle => 'إعداد مواقيت الصلاة';

  @override
  String get onboardingPermissionSubtitle =>
      'احصل على إشعارات أذان دقيقة لموقعك';

  @override
  String get onboardingPermissionBody =>
      'سمح بالوصول للموقع للحصول على مواقيت صلاة دقيقة؟';

  @override
  String get onboardingPermissionGrant => 'السماح بالوصول';

  @override
  String get onboardingPermissionGranted => 'تم السماح بالوصول للموقع';

  @override
  String get onboardingPermissionDenied => 'تم رفض الوصول للموقع';

  @override
  String get onboardingPermissionDeniedBody =>
      'نحتاج موقعك للحصول على مواقيت صلاة دقيقة. يمكنك تفعيله في إعدادات جهازك.';

  @override
  String get onboardingPermissionOpenSettings => 'فتح الإعدادات';

  @override
  String get onboardingPermissionRetry => 'إعادة المحاولة';

  @override
  String get onboardingPermissionServiceOff => 'خدمات الموقع معطلة';

  @override
  String get onboardingPermissionServiceOffBody =>
      'يرجى تفعيل خدمات الموقع على جهازك للحصول على مواقيت صلاة دقيقة.';

  @override
  String get allowLocation =>
      'سمح بالوصول للموقع للحصول على مواقيت صلاة دقيقة؟';

  @override
  String get onboardingQualitiesTitle => 'ما هي الصفات التي تريد أن تبنيها؟';

  @override
  String get onboardingQualitiesSubtitle => 'اختر حتى3 للتركيز عليها';

  @override
  String get qualityTaqwa => 'تقوى الله';

  @override
  String get qualityTaqwaDesc => 'الوعي بالله في كل فعل';

  @override
  String get qualityIkhlas => 'الإخلاص';

  @override
  String get qualityIkhlasDesc => 'صفاء النية لله وحده';

  @override
  String get qualitySabr => 'الصبر';

  @override
  String get qualitySabrDesc => 'الثبات في المحن وتأخر النتائج';

  @override
  String get qualityShukr => 'الشكر';

  @override
  String get qualityShukrDesc => 'تمييز نعم الله والامتنان لها';

  @override
  String get qualityTawakkul => 'التوكل على الله';

  @override
  String get qualityTawakkulDesc => 'الاعتماد على الله بعد اخذ الاسباب';

  @override
  String get qualityIhsan => 'الإحسان';

  @override
  String get qualityIhsanDesc => 'فعل كل شيء كأن الله يراقبك';

  @override
  String get qualityIlm => 'العلم';

  @override
  String get qualityIlmDesc => 'طلب العلم النافع باستمرار';

  @override
  String get qualityDawah => 'الدعوة';

  @override
  String get qualityDawahDesc => 'دعوة الآخرين إلى الإسلام بالأخلاق';

  @override
  String get qualityUmmah => 'الأمة';

  @override
  String get qualityUmmahDesc => 'القوة من خلال الأخوة والأختية';

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
  String get taskStartTime => 'وقت البدء';

  @override
  String get taskEndTime => 'وقت الانتهاء';

  @override
  String get taskNotes => 'ملاحظات (اختياري)';

  @override
  String get taskRepeat => 'تكرار';

  @override
  String get taskRepeatDaily => 'يومي';

  @override
  String get taskRepeatWeekly => 'أسبوعي';

  @override
  String get taskOverdue => 'متأخرة';

  @override
  String get taskScheduled => 'مجدولة';

  @override
  String get taskNoTime => 'لم يتم تحديد الوقت';

  @override
  String get taskSwipeComplete => 'إكمال';

  @override
  String get taskSwipeDelete => 'حذف';

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
  String get barakahReminderLabel => 'تذكير يومي بالبركة';

  @override
  String get barakahReminderDescription =>
      'دعوة لطيفة للتأمل كل يوم. يصلك التذكير قرب الوقت المحلي الذي تختاره، وقد يتأخر وصوله حسب إعدادات جهازك.';

  @override
  String get barakahReminderTime => 'وقت التذكير';

  @override
  String get barakahReminderUnsupported =>
      'التذكيرات اليومية متاحة فقط في تطبيقي أندرويد وiOS، وليست متاحة على الويب أو سطح المكتب.';

  @override
  String get barakahReminderDenied =>
      'الإشعارات غير مسموح بها. اسمح بها في إعدادات جهازك، ثم فعّل هذا التذكير مجددًا.';

  @override
  String get barakahReminderError =>
      'تعذر تحديث التذكير. يرجى المحاولة مرة أخرى.';

  @override
  String get barakahReminderPending => 'جارٍ تحديث التذكير…';

  @override
  String get barakahReminderBody => 'خذ لحظة للتأمل في مصادر البركة في يومك.';

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
  String get sunrise => 'الشروق';

  @override
  String get adhan => 'الأذان';

  @override
  String get adhanNotificationsDescription =>
      'احصل على إشعارات في أوقات الصلاة';

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
  String get barakahWeeklyTitle => 'مراجعة التأملات الأسبوعية';

  @override
  String get barakahWeeklyPrevious => 'الأسبوع السابق';

  @override
  String get barakahWeeklyNext => 'الأسبوع التالي';

  @override
  String barakahWeeklyRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get barakahWeeklyDescription =>
      'تصفح تأملاتك اليومية المحفوظة. تصف هذه الأعداد إجاباتك واختياراتك الشخصية، وليست مقياسًا للبركة من الله.';

  @override
  String get barakahWeeklyAnswers => 'الإجابات المحفوظة';

  @override
  String barakahWeeklyCount(String label, String count) {
    return '$label: $count';
  }

  @override
  String get barakahWeeklySources => 'المصادر المختارة';

  @override
  String get barakahWeeklySourcesDescription =>
      'عدد الأيام التي اخترت فيها كل مصدر مع إجابة نعم أو إلى حد ما، مرة واحدة لكل يوم. لا تثبت هذه الاختيارات سببًا للبركة.';

  @override
  String get barakahWeeklyNoSources =>
      'لم تُختر مصادر مع إجابة نعم أو إلى حد ما هذا الأسبوع.';

  @override
  String get barakahWeeklyDays => 'التأملات اليومية · من الاثنين إلى الأحد';

  @override
  String get barakahWeeklyMissing => 'لا توجد إجابة محفوظة';

  @override
  String get barakahWeeklyFuture => 'يوم قادم';

  @override
  String get barakahWeeklySkipped => 'تم التخطي';

  @override
  String get barakahWeeklyNote => 'الملاحظة المحفوظة';

  @override
  String get barakahWeeklyEmpty =>
      'لا توجد إجابات يومية محفوظة لهذا الأسبوع. ستظهر هنا التأملات اليومية التي تحفظها في شاشة البركة؛ سجل التأملات الحرة منفصل.';

  @override
  String get barakahWeeklyFailure =>
      'تعذر تحميل تأملات هذا الأسبوع. يرجى المحاولة مرة أخرى.';

  @override
  String get barakahHistoryTitle => 'سجل تأملات البركة الحرة';

  @override
  String get habitMarkComplete => 'تحديد كمكتمل';

  @override
  String get habitUnmark => 'إلغاء التحديد';

  @override
  String get habitAddName => 'اسم العادة';

  @override
  String get habitAddCategory => 'الفئة';

  @override
  String get habitNoCompletions => 'لا توجد إكمالات بعد';

  @override
  String get habitToday => 'اليوم';

  @override
  String get habitSwipeDelete => 'حذف';

  @override
  String get enterYourName => 'أدخل اسمك...';

  @override
  String get weeklyTrack => 'المتابعة الأسبوعية';

  @override
  String get reflectionHint => 'تأملك...';

  @override
  String get intentionTitle => 'عنوان النية';

  @override
  String get sphereSpiritual => 'المجال الروحي';

  @override
  String get spherePhysical => 'المجال الجسدي';

  @override
  String get sphereSocial => 'المجال الاجتماعي';

  @override
  String get sphereSpiritualDesc =>
      'الصلاة، القرآن، الأذكار، الصيام، والعلم الشرعي';

  @override
  String get spherePhysicalDesc => 'النوم، القيلولة، التغذية، اللياقة، والنشاط';

  @override
  String get sphereSocialDesc => 'الأسرة، الزواج، الإتقان المهني، وخدمة الأمة';

  @override
  String get prayerSlot => 'نافذة الصلاة';

  @override
  String get prayerSlotNone => 'وقت محدد فقط';

  @override
  String get slotEarlyMorning => 'ساعة البركة (بعد الفجر)';

  @override
  String get slotEarlyMorningDesc =>
      'ساعات الصباح الأولى الذهبية للتركيز العالي';

  @override
  String get slotDuha => 'الضحى (وسط الصباح)';

  @override
  String get slotDuhaDesc => 'فترة العمل والدراسة الرئيسية قبل الظهر';

  @override
  String get slotDhuhr => 'بعد الظهر';

  @override
  String get slotDhuhrDesc => 'فترة بداية الظهيرة بعد صلاة الظهر';

  @override
  String get slotAsr => 'بعد العصر';

  @override
  String get slotAsrDesc => 'فترة أواخر المساء للتأمل أو النشاط البدني';

  @override
  String get slotMaghrib => 'بين المغرب والعشاء';

  @override
  String get slotMaghribDesc => 'وقت العائلة وقراءة القرآن والمهام الخفيفة';

  @override
  String get slotIsha => 'بعد العشاء / المساء';

  @override
  String get slotIshaDesc => 'روتين الليل، المحاسبة، والنوم المبكر';

  @override
  String get focus => 'جلسة التركيز';

  @override
  String get focusTitle => 'جلسة تركيز وخشوع';

  @override
  String get focusSubtitle => 'اعمل بحضور قلب ونيّة خالصة وبركة إلهية';

  @override
  String get focusNiyyahPrompt => 'بسم الله — جدد نيتك لله تعالى قبل البدء';

  @override
  String get focusDua => 'رَّبِّ زِدْنِي عِلْمًا';

  @override
  String get focusStart => 'ابدأ التركيز';

  @override
  String get focusPause => 'إيقاف مؤقت';

  @override
  String get focusResume => 'استئناف';

  @override
  String get focusReset => 'إعادة ضبط';

  @override
  String get focusComplete => 'تمت جلسة التركيز! الحمد لله';

  @override
  String get focusCompleteMessage => 'بارك الله في جهدك وتقبل عملك ونفع بك.';

  @override
  String focusTotalMinutes(int minutes) {
    return 'إجمالي التركيز: $minutes دقيقة';
  }

  @override
  String get focusSelectTask => 'اختر مهمة للتركيز عليها (اختياري)';

  @override
  String get focusPrayerWarningTitle => 'اقتراب وقت الصلاة';

  @override
  String focusPrayerOverlap(String prayerName, int minutes) {
    return 'الصلاة القادمة ($prayerName) بعد $minutes دقيقة. ستتداخل جلستك مع وقت الصلاة.';
  }

  @override
  String focusPrayerSuggestion(int minutes, String prayerName) {
    return 'اضبط $minutes دقيقة للانتهاء قبل صلاة $prayerName';
  }

  @override
  String get focusMarkTaskComplete => 'تحديد المهمة المرتبطة كمكتملة';

  @override
  String get focusTaskCompletedSuccess => 'تم إنجاز المهمة بنجاح! 🎉';

  @override
  String focusWindDownWarning(int minutes) {
    return 'الصلاة بعد $minutes د • ابدأ بإنهاء جلستك';
  }

  @override
  String get focusPreset15 => '15 دقيقة (سريعة)';

  @override
  String get focusPreset25 => '25 دقيقة (كتلة بركة)';

  @override
  String get focusPreset45 => '45 دقيقة (عمل عميق)';

  @override
  String get focusPreset60 => '60 دقيقة (إتقان)';

  @override
  String get energyTitle => 'طاقة اليوم وروتين السنة';

  @override
  String get energySubtitle => 'وازن بين طاقتك الروحية والجسدية والذهنية';

  @override
  String get qaylulah => 'القيلولة النبوية';

  @override
  String get qaylulahDesc =>
      'قيلولة الظهيرة النبوية (20 دقيقة) لتجديد نشاط المساء';

  @override
  String get qaylulahStart => 'ابدأ القيلولة';

  @override
  String get qaylulahWakingDua =>
      'الحمد لله الذي أحيانا بعد ما أماتنا وإليه النشور';

  @override
  String get sunnahFasting => 'صيام التطوع';

  @override
  String get sunnahFastingDesc => 'الإثنين والخميس والأيام البيض (13، 14، 15)';

  @override
  String get sunnahFastingIntention => 'أصوم اليوم تقرباً لله';

  @override
  String get energyPhysical => 'الطاقة الجسدية';

  @override
  String get energySpiritual => 'الحالة الروحية';

  @override
  String get energyMental => 'التركيز الذهني';

  @override
  String get energySaved => 'تم تحديث تقييم الطاقة';

  @override
  String get qualityDetailsAction => 'التطبيق العملي';

  @override
  String get qualityDetailsContext => 'الأصل والأساس الشرعي';

  @override
  String get adhkarTitle => 'الأذكار والأدعية اليومية';

  @override
  String get adhkarMorning => 'أذكار الصباح';

  @override
  String get adhkarEvening => 'أذكار المساء';

  @override
  String get adhkarWaking => 'أذكار الاستيقاظ';

  @override
  String get adhkarSleeping => 'أذكار النوم';

  @override
  String get adhkarPostPrayer => 'أذكار بعد الصلاة';

  @override
  String get adhkarDailySunnah => 'أدعية وأذكار السنة اليومية';

  @override
  String get adhkarTapToCount => 'المس أي مكان للشاشة للتسبيح';

  @override
  String get adhkarCompleted => 'تم بحمد الله!';

  @override
  String get adhkarCompletedMsg =>
      'تقبل الله ذكرك وطاعتك وجعل يومك عامراً بالبركة.';

  @override
  String get adhkarVirtue => 'الفضل والحديث النبوي';

  @override
  String get adhkarNext => 'الذكر التالي';

  @override
  String get adhkarPrev => 'السابق';

  @override
  String get adhkarReset => 'إعادة العد';

  @override
  String get adhkarTransliteration => 'النطق بالحروف اللاتينية';

  @override
  String get adhkarPillMorning => 'أذكار الصباح • نور وحفظ';

  @override
  String get adhkarPillEvening => 'أذكار المساء • حصن المسلم';

  @override
  String get adhkarPillSleeping => 'أذكار النوم • حرز ليلتك';

  @override
  String get adhkarPillPostPrayer => 'أذكار ما بعد الصلاة • تسبيح';

  @override
  String adhkarProgress(int completed, int total) {
    return 'تم $completed من أصل $total';
  }

  @override
  String get adhkarEmptyState => 'لا توجد أذكار في هذا القسم حالياً.';

  @override
  String get adhkarActionRecite => 'تسبيح';

  @override
  String get adhkarActionReview => 'مراجعة';

  @override
  String get adhkarPillTapPrompt => 'المس للبدء • عدّاد لمسي ذكي';

  @override
  String get adhkarTabMorning => 'الصباح';

  @override
  String get adhkarTabEvening => 'المساء';

  @override
  String get adhkarTabWaking => 'الاستيقاظ';

  @override
  String get adhkarTabBedtime => 'النوم';

  @override
  String get adhkarTabPostSalah => 'بعد الصلاة';

  @override
  String get adhkarTabSunnah => 'السنة';

  @override
  String get smartNotificationsTitle => 'تذكيرات الأذكار والسنن الذكية';

  @override
  String get smartNotificationsDesc =>
      'تنبيهات تلقائية تتغير بدقة بحسب مواقيت الصلاة وأوقات السنة النبوية.';

  @override
  String get settingMorningAdhkar => 'أذكار الصباح (بعد الفجر)';

  @override
  String get settingMorningAdhkarDesc =>
      'تنبيه لطيف بعد الفجر بـ 15 دقيقة في ساعة البركة الصباحية.';

  @override
  String get settingEveningAdhkar => 'أذكار المساء (بعد العصر)';

  @override
  String get settingEveningAdhkarDesc =>
      'حصن نفسك بأذكار المساء المأثورة قبل غروب الشمس.';

  @override
  String get settingBedtimeAdhkar => 'أذكار النوم والورد الليلي';

  @override
  String get settingBedtimeAdhkarDesc =>
      'تذكير بقراءة المعوذات والإخلاص ودعاء النوم قبل النوم.';

  @override
  String get settingBedtimeTime => 'موعد النوم المعتاد';

  @override
  String get settingSunnahFasting => 'تذكير صيام الاثنين والخميس';

  @override
  String get settingSunnahFastingDesc =>
      'تنبيه مساء الأحد والأربعاء لعقد النية لصيام السنة.';

  @override
  String get settingQaylulah => 'تذكير قيلولة السنة';

  @override
  String get settingQaylulahDesc =>
      'تنبيه اختياري قبل صلاة الظهر بـ 30 دقيقة لاستعادة النشاط.';

  @override
  String get barakahAnalyticsTitle => 'تحليلات ونمو البركة الأسبوعي';

  @override
  String get barakahAnalyticsConsistency => 'مصفوفة البركة للأسبوع';

  @override
  String get barakahAnalyticsEnergyTriad => 'ثلاثية الطاقة المتكاملة';

  @override
  String get barakahAnalyticsSpiritual => 'الروحية';

  @override
  String get barakahAnalyticsPhysical => 'البدنية';

  @override
  String get barakahAnalyticsMental => 'الذهنية';

  @override
  String barakahAnalyticsActiveDays(int count) {
    return '$count / 7 أيام نشطة';
  }

  @override
  String barakahAnalyticsTotalDhikr(int count) {
    return 'تم إنجاز $count ذكراً';
  }

  @override
  String barakahAnalyticsFastingDays(int count) {
    return '$count أيام صيام سنة';
  }

  @override
  String get barakahAnalyticsCoachingTitle => 'إرشادات النمو الروحي والإنتاجي';

  @override
  String get qiblaTitle => 'بوصلة القبلة';

  @override
  String get qiblaTabTimes => 'مواقيت الصلاة';

  @override
  String get qiblaTabCompass => 'اتجاه القبلة';

  @override
  String qiblaBearing(String degrees) {
    return '$degrees° عن الشمال';
  }

  @override
  String qiblaDistance(String distance) {
    return '$distance كم إلى الكعبة المشرفة';
  }

  @override
  String get qiblaFacingKaaba => 'أنت باتجاه القبلة تماماً';

  @override
  String get qiblaCalibrate =>
      'معايرة البوصلة: حرك الجهاز بشكل رقم 8 بعيداً عن المعادن والمجالات المغناطيسية.';

  @override
  String get solarDialTitle => 'مسار الشمس ومواقيت الصلاة';

  @override
  String solarCurrentWindow(String slot) {
    return 'النافذة الحالية: $slot';
  }

  @override
  String solarNext(String prayer) {
    return 'التالي: $prayer';
  }

  @override
  String get slotTahajjud => 'التهجد / السحر';

  @override
  String get slotNight => 'الليل / قيام الليل';

  @override
  String get widgetAppTitle => 'المسلم المنتج';

  @override
  String get widgetNextPrayerLabel => 'الصلاة القادمة';

  @override
  String widgetDhikrCount(int count) {
    return 'الأذكار: $count منجزة';
  }

  @override
  String get widgetBtnPrayers => 'الصلاة';

  @override
  String get widgetBtnAdhkar => 'الأذكار';

  @override
  String get widgetBtnFocus => 'التركيز';

  @override
  String get hijriCalendarTitle => 'التقويم الهجري وصيام السنة';

  @override
  String hijriToday(String date) {
    return 'اليوم: $date';
  }

  @override
  String get whiteDaysLabel => 'الأيام البيض';

  @override
  String get whiteDaysDesc => '13 و 14 و 15 من كل شهر قمري';

  @override
  String get mondayThursdaySunnah => 'سنة صيام الإثنين والخميس';

  @override
  String fastingCountdownSuhoor(String time) {
    return 'ينتهي السحور خلال $time';
  }

  @override
  String fastingCountdownIftar(String time) {
    return 'موعد الإفطار خلال $time';
  }

  @override
  String get fastingTodayActive => 'صائم اليوم';

  @override
  String get fastingTodayInactive => 'غير صائم اليوم';

  @override
  String get fastingIntendAction => 'انوي الصيام';

  @override
  String get fastingLoggedSuccess => 'تم تحديث سجل الصيام';

  @override
  String get iftarDuaTitle => 'دعاء الإفطار المأثور';

  @override
  String get iftarDuaArabic =>
      'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ';

  @override
  String get iftarDuaTransliteration =>
      'ذهب الظمأ وابتلت العروق وثبت الأجر إن شاء الله';

  @override
  String get iftarDuaTranslation =>
      'ذهب الظمأ وابتلت العروق وثبت الأجر إن شاء الله (رواه أبو داود)';

  @override
  String fastingStreak(int count) {
    return '$count أيام صيام';
  }

  @override
  String get fastingVirtueTitle => 'فضل صيام التطوع';

  @override
  String get fastingVirtueDesc =>
      'صيام ثلاثة أيام من كل شهر صيام الدهر كله (متفق عليه).';

  @override
  String get fastingGuidelinesTitle => 'إرشادات صيام السنة';

  @override
  String get suhoorSunnahTitle => 'بركة السحور';

  @override
  String get suhoorSunnahDesc =>
      'قال النبي ﷺ: «تسحروا فإن في السحور بركة» (رواه البخاري)';

  @override
  String get hydrationTitle => 'الترطيب المنتظم';

  @override
  String get hydrationDesc =>
      'احرص على شرب كميات كافية من الماء بين الإفطار والسحور لتجديد النشاط والتركيز.';

  @override
  String get breakPromptTitle => 'تعجيل الفطر';

  @override
  String get breakPromptDesc =>
      'عجّل بالإفطار عند أذان المغرب على رطبات أو تمر وماء اقتداءً بالسنة النبوية.';

  @override
  String get whiteDayBadge => 'يوم أبيض';

  @override
  String get prevMonthTooltip => 'الشهر السابق';

  @override
  String get nextMonthTooltip => 'الشهر القادم';

  @override
  String get todayTooltip => 'اليوم';

  @override
  String get suhoorWindow => 'نافذة السحور';

  @override
  String get fastInProgress => 'أنت صائم الآن';

  @override
  String get iftarCompleted => 'تم الإفطار بفضل الله';

  @override
  String get sunnahBadge => 'سنة';

  @override
  String get copyDuaTooltip => 'نسخ الدعاء';

  @override
  String get duaCopiedMessage => 'تم نسخ الدعاء إلى الحافظة';

  @override
  String get iftarHadithRef => 'سنن أبي داود (٢٣٥٧) — صحيح';
}
