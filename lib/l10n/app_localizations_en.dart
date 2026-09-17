// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Productive Muslim';

  @override
  String homeGreeting(Object name) {
    return 'Good morning, $name';
  }

  @override
  String get prayerTimes => 'Prayer Times';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get lifeArea => 'Life Area';

  @override
  String tasksCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
      zero: 'No tasks',
    );
    return '$_temp0';
  }

  @override
  String get intentionSet => 'Your intention has been set';

  @override
  String get getStarted => 'Get Started';

  @override
  String get nextStep => 'Continue';

  @override
  String get setMyIntention => 'Set My Intention';

  @override
  String get startYourDay => 'Start Your Day';

  @override
  String get name => 'Name';

  @override
  String get yourName => 'Your Name';

  @override
  String get introduction => 'What brings you today?';

  @override
  String get seekingBarakah => 'Seeking barakah in my time';

  @override
  String get consistentWorship => 'Consistent worship & routine';

  @override
  String get mindfulProductivity => 'Mindful productivity';

  @override
  String get writeYourOwn => 'Or write your own';

  @override
  String get allowLocation =>
      'Allow location access for accurate prayer times?';

  @override
  String get calculationMethod => 'Calculation Method';

  @override
  String get tasks => 'Tasks';

  @override
  String get habits => 'Habits';

  @override
  String get barakah => 'Barakah';

  @override
  String get journal => 'Journal';

  @override
  String get home => 'Home';

  @override
  String get newTask => 'New Task';

  @override
  String get newHabit => 'New Habit';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get skip => 'Skip';

  @override
  String get remindMeLater => 'Remind me later';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get emptyTasks => 'No tasks today';

  @override
  String get emptyHabits => 'No habits yet';

  @override
  String get emptyIntentions => 'No intentions yet';

  @override
  String get emptyBarakah => 'No barakah entries yet';

  @override
  String get active => 'Active';

  @override
  String get reflected => 'Reflected';

  @override
  String get archived => 'Archived';

  @override
  String streak(Object count) {
    return '$count day streak';
  }

  @override
  String get nextPrayer => 'Next Prayer';

  @override
  String inTime(Object time) {
    return 'in $time';
  }

  @override
  String get today => 'Today';

  @override
  String get week => 'Week';

  @override
  String get all => 'All';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get barakahReminderLabel => 'Daily Barakah reminder';

  @override
  String get barakahReminderDescription =>
      'A gentle invitation to reflect each day. Reminders arrive around your chosen local time; delivery may be delayed by your device.';

  @override
  String get barakahReminderTime => 'Reminder time';

  @override
  String get barakahReminderUnsupported =>
      'Daily reminders are available only in the Android and iOS apps, not on web or desktop.';

  @override
  String get barakahReminderDenied =>
      'Notifications are not allowed. Allow them in your device settings, then turn on this reminder again.';

  @override
  String get barakahReminderError =>
      'The reminder could not be updated. Please try again.';

  @override
  String get barakahReminderPending => 'Updating reminder…';

  @override
  String get barakahReminderBody =>
      'Take a moment to reflect on the sources of barakah in your day.';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get fajr => 'Fajr';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get adhan => 'Adhan';

  @override
  String get islam => 'Islam';

  @override
  String get family => 'Family';

  @override
  String get work => 'Work';

  @override
  String get personalDev => 'Personal Development';

  @override
  String get todayIntentions => 'Today\'s Intentions';

  @override
  String get noIntentionsToday => 'No intentions for today';

  @override
  String get reflection => 'Reflection';

  @override
  String get completed => 'completed';

  @override
  String get saveReflection => 'Save Reflection';

  @override
  String get newIntention => 'New Intention';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get barakahDailyTitle => 'Daily Barakah reflection';

  @override
  String barakahDailyQuestion(String promptId) {
    String _temp0 = intl.Intl.selectLogic(promptId, {
      'good_intentions_v1': 'Did you renew your intention for Allah today?',
      'piety_v1': 'Did mindfulness of Allah guide your choices today?',
      'trust_in_allah_v1':
          'Did you put your trust in Allah while doing your part today?',
      'quran_v1': 'Did you make time for the Quran today?',
      'bismillah_v1': 'Did you begin your activities with Bismillah today?',
      'eating_together_v1': 'Did you share a meal with others today?',
      'honesty_in_trade_v1': 'Were you honest in your dealings today?',
      'dua_v1': 'Did you turn to Allah in dua today?',
      'halal_income_v1': 'Did you seek or use halal income today?',
      'sunnah_v1': 'Did you follow a Sunnah practice today?',
      'istikhara_v1': 'Did you seek Allah\'s guidance through istikhara for a decision today?',
      'gratitude_v1': 'Did you thank Allah for His blessings today?',
      'charity_v1': 'Did you give something in charity today?',
      'kinship_v1': 'Did you nurture your family ties today?',
      'early_rising_v1': 'Did you make use of the early morning today?',
      'marriage_v1': 'Did you nurture kindness in your marriage today?',
      'salah_v1': 'Did you make time for prayer today?',
      'forgiveness_v1': 'Did you seek Allah\'s forgiveness today?',
      'other': 'Did you notice a source of barakah today?',
    });
    return '$_temp0';
  }

  @override
  String barakahDailySource(String sourceId) {
    String _temp0 = intl.Intl.selectLogic(sourceId, {
      'good_intentions': 'Good intentions',
      'piety': 'Mindfulness of Allah',
      'trust_in_allah': 'Trust in Allah',
      'quran': 'Quran',
      'bismillah': 'Saying Bismillah',
      'eating_together': 'Eating together',
      'honesty_in_trade': 'Honest dealings',
      'dua': 'Dua',
      'halal_income': 'Halal income',
      'sunnah': 'Following the Sunnah',
      'istikhara': 'Istikhara',
      'gratitude': 'Gratitude to Allah',
      'charity': 'Giving charity',
      'kinship': 'Family ties',
      'early_rising': 'Early rising',
      'marriage': 'Kindness in marriage',
      'salah': 'Prayer',
      'forgiveness': 'Seeking forgiveness',
      'other': 'Source of barakah',
    });
    return '$_temp0';
  }

  @override
  String get barakahDailyYes => 'Yes';

  @override
  String get barakahDailySomewhat => 'Somewhat';

  @override
  String get barakahDailyNo => 'No';

  @override
  String get barakahDailySkip => 'Skip';

  @override
  String get barakahDailySources => 'Sources of barakah (optional)';

  @override
  String get barakahDailyNote => 'Reflection note (optional)';

  @override
  String get barakahDailySave => 'Save response';

  @override
  String get barakahDailyUpdate => 'Save changes';

  @override
  String get barakahDailySaving => 'Saving response…';

  @override
  String get barakahDailySaved => 'Response saved. You can edit it anytime.';

  @override
  String get barakahDailyFailure =>
      'Your response could not be loaded or saved. Please try again.';

  @override
  String get barakahDailyRetry => 'Try again';

  @override
  String get barakahHistoryTitle => 'Free-form Barakah history';
}
