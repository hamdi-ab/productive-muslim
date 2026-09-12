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
}
