import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Productive Muslim'**
  String get appTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String homeGreeting(Object name);

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// No description provided for @lifeArea.
  ///
  /// In en, this message translates to:
  /// **'Life Area'**
  String get lifeArea;

  /// No description provided for @tasksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tasks} =1{1 task} other{{count} tasks}}'**
  String tasksCount(num count);

  /// No description provided for @intentionSet.
  ///
  /// In en, this message translates to:
  /// **'Your intention has been set'**
  String get intentionSet;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get nextStep;

  /// No description provided for @setMyIntention.
  ///
  /// In en, this message translates to:
  /// **'Set My Intention'**
  String get setMyIntention;

  /// No description provided for @startYourDay.
  ///
  /// In en, this message translates to:
  /// **'Start Your Day'**
  String get startYourDay;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @introduction.
  ///
  /// In en, this message translates to:
  /// **'What brings you today?'**
  String get introduction;

  /// No description provided for @seekingBarakah.
  ///
  /// In en, this message translates to:
  /// **'Seeking barakah in my time'**
  String get seekingBarakah;

  /// No description provided for @consistentWorship.
  ///
  /// In en, this message translates to:
  /// **'Consistent worship & routine'**
  String get consistentWorship;

  /// No description provided for @mindfulProductivity.
  ///
  /// In en, this message translates to:
  /// **'Mindful productivity'**
  String get mindfulProductivity;

  /// No description provided for @writeYourOwn.
  ///
  /// In en, this message translates to:
  /// **'Or write your own'**
  String get writeYourOwn;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your day around what matters'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer, tasks, habits, and intentions — together in one space'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your name?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We use it to personalize your experience'**
  String get onboardingNameSubtitle;

  /// No description provided for @onboardingIntentionTitle.
  ///
  /// In en, this message translates to:
  /// **'What brings you today?'**
  String get onboardingIntentionTitle;

  /// No description provided for @onboardingIntentionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose or write your own intention'**
  String get onboardingIntentionSubtitle;

  /// No description provided for @onboardingPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up prayer times'**
  String get onboardingPermissionTitle;

  /// No description provided for @onboardingPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get accurate adhan notifications for your location'**
  String get onboardingPermissionSubtitle;

  /// No description provided for @onboardingPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow location access for accurate prayer times?'**
  String get onboardingPermissionBody;

  /// No description provided for @onboardingPermissionGrant.
  ///
  /// In en, this message translates to:
  /// **'Allow Access'**
  String get onboardingPermissionGrant;

  /// No description provided for @onboardingPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Location access granted'**
  String get onboardingPermissionGranted;

  /// No description provided for @onboardingPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access denied'**
  String get onboardingPermissionDenied;

  /// No description provided for @onboardingPermissionDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'We need your location for accurate prayer times. You can enable it in your device settings.'**
  String get onboardingPermissionDeniedBody;

  /// No description provided for @onboardingPermissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get onboardingPermissionOpenSettings;

  /// No description provided for @onboardingPermissionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get onboardingPermissionRetry;

  /// No description provided for @onboardingPermissionServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are off'**
  String get onboardingPermissionServiceOff;

  /// No description provided for @onboardingPermissionServiceOffBody.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services on your device to get accurate prayer times.'**
  String get onboardingPermissionServiceOffBody;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location access for accurate prayer times?'**
  String get allowLocation;

  /// No description provided for @onboardingQualitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'What qualities do you want to build?'**
  String get onboardingQualitiesTitle;

  /// No description provided for @onboardingQualitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose up to 3 to focus on'**
  String get onboardingQualitiesSubtitle;

  /// No description provided for @qualityTaqwa.
  ///
  /// In en, this message translates to:
  /// **'God-Consciousness'**
  String get qualityTaqwa;

  /// No description provided for @qualityTaqwaDesc.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness of Allah in every action'**
  String get qualityTaqwaDesc;

  /// No description provided for @qualityIkhlas.
  ///
  /// In en, this message translates to:
  /// **'Sincerity'**
  String get qualityIkhlas;

  /// No description provided for @qualityIkhlasDesc.
  ///
  /// In en, this message translates to:
  /// **'Purity of intention for Allah alone'**
  String get qualityIkhlasDesc;

  /// No description provided for @qualitySabr.
  ///
  /// In en, this message translates to:
  /// **'Patience'**
  String get qualitySabr;

  /// No description provided for @qualitySabrDesc.
  ///
  /// In en, this message translates to:
  /// **'Steadfastness through trials and delay'**
  String get qualitySabrDesc;

  /// No description provided for @qualityShukr.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get qualityShukr;

  /// No description provided for @qualityShukrDesc.
  ///
  /// In en, this message translates to:
  /// **'Recognizing and appreciating Allah\'s blessings'**
  String get qualityShukrDesc;

  /// No description provided for @qualityTawakkul.
  ///
  /// In en, this message translates to:
  /// **'Trust in Allah'**
  String get qualityTawakkul;

  /// No description provided for @qualityTawakkulDesc.
  ///
  /// In en, this message translates to:
  /// **'Reliance on Allah after doing your part'**
  String get qualityTawakkulDesc;

  /// No description provided for @qualityIhsan.
  ///
  /// In en, this message translates to:
  /// **'Excellence'**
  String get qualityIhsan;

  /// No description provided for @qualityIhsanDesc.
  ///
  /// In en, this message translates to:
  /// **'Doing everything as if Allah is watching'**
  String get qualityIhsanDesc;

  /// No description provided for @qualityIlm.
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get qualityIlm;

  /// No description provided for @qualityIlmDesc.
  ///
  /// In en, this message translates to:
  /// **'Seeking beneficial knowledge continuously'**
  String get qualityIlmDesc;

  /// No description provided for @qualityDawah.
  ///
  /// In en, this message translates to:
  /// **'Invitation'**
  String get qualityDawah;

  /// No description provided for @qualityDawahDesc.
  ///
  /// In en, this message translates to:
  /// **'Calling others to Islam through character'**
  String get qualityDawahDesc;

  /// No description provided for @qualityUmmah.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get qualityUmmah;

  /// No description provided for @qualityUmmahDesc.
  ///
  /// In en, this message translates to:
  /// **'Strength through brotherhood and sisterhood'**
  String get qualityUmmahDesc;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethod;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// No description provided for @barakah.
  ///
  /// In en, this message translates to:
  /// **'Barakah'**
  String get barakah;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// No description provided for @newHabit.
  ///
  /// In en, this message translates to:
  /// **'New Habit'**
  String get newHabit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @remindMeLater.
  ///
  /// In en, this message translates to:
  /// **'Remind me later'**
  String get remindMeLater;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @emptyTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks today'**
  String get emptyTasks;

  /// No description provided for @taskStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get taskStartTime;

  /// No description provided for @taskEndTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get taskEndTime;

  /// No description provided for @taskNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get taskNotes;

  /// No description provided for @taskRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get taskRepeat;

  /// No description provided for @taskRepeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get taskRepeatDaily;

  /// No description provided for @taskRepeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get taskRepeatWeekly;

  /// No description provided for @taskOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get taskOverdue;

  /// No description provided for @taskScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get taskScheduled;

  /// No description provided for @taskNoTime.
  ///
  /// In en, this message translates to:
  /// **'No time set'**
  String get taskNoTime;

  /// No description provided for @taskSwipeComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get taskSwipeComplete;

  /// No description provided for @taskSwipeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get taskSwipeDelete;

  /// No description provided for @emptyHabits.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get emptyHabits;

  /// No description provided for @emptyIntentions.
  ///
  /// In en, this message translates to:
  /// **'No intentions yet'**
  String get emptyIntentions;

  /// No description provided for @emptyBarakah.
  ///
  /// In en, this message translates to:
  /// **'No barakah entries yet'**
  String get emptyBarakah;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @reflected.
  ///
  /// In en, this message translates to:
  /// **'Reflected'**
  String get reflected;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String streak(Object count);

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayer;

  /// No description provided for @inTime.
  ///
  /// In en, this message translates to:
  /// **'in {time}'**
  String inTime(Object time);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @barakahReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Barakah reminder'**
  String get barakahReminderLabel;

  /// No description provided for @barakahReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'A gentle invitation to reflect each day. Reminders arrive around your chosen local time; delivery may be delayed by your device.'**
  String get barakahReminderDescription;

  /// No description provided for @barakahReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get barakahReminderTime;

  /// No description provided for @barakahReminderUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders are available only in the Android and iOS apps, not on web or desktop.'**
  String get barakahReminderUnsupported;

  /// No description provided for @barakahReminderDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not allowed. Allow them in your device settings, then turn on this reminder again.'**
  String get barakahReminderDenied;

  /// No description provided for @barakahReminderError.
  ///
  /// In en, this message translates to:
  /// **'The reminder could not be updated. Please try again.'**
  String get barakahReminderError;

  /// No description provided for @barakahReminderPending.
  ///
  /// In en, this message translates to:
  /// **'Updating reminder…'**
  String get barakahReminderPending;

  /// No description provided for @barakahReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to reflect on the sources of barakah in your day.'**
  String get barakahReminderBody;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @adhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get adhan;

  /// No description provided for @islam.
  ///
  /// In en, this message translates to:
  /// **'Islam'**
  String get islam;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @personalDev.
  ///
  /// In en, this message translates to:
  /// **'Personal Development'**
  String get personalDev;

  /// No description provided for @todayIntentions.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Intentions'**
  String get todayIntentions;

  /// No description provided for @noIntentionsToday.
  ///
  /// In en, this message translates to:
  /// **'No intentions for today'**
  String get noIntentionsToday;

  /// No description provided for @reflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get reflection;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get completed;

  /// No description provided for @saveReflection.
  ///
  /// In en, this message translates to:
  /// **'Save Reflection'**
  String get saveReflection;

  /// No description provided for @newIntention.
  ///
  /// In en, this message translates to:
  /// **'New Intention'**
  String get newIntention;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// Heading for the daily Barakah prompt
  ///
  /// In en, this message translates to:
  /// **'Daily Barakah reflection'**
  String get barakahDailyTitle;

  /// Daily reflection question selected by stable prompt ID
  ///
  /// In en, this message translates to:
  /// **'{promptId, select, good_intentions_v1{Did you renew your intention for Allah today?} piety_v1{Did mindfulness of Allah guide your choices today?} trust_in_allah_v1{Did you put your trust in Allah while doing your part today?} quran_v1{Did you make time for the Quran today?} bismillah_v1{Did you begin your activities with Bismillah today?} eating_together_v1{Did you share a meal with others today?} honesty_in_trade_v1{Were you honest in your dealings today?} dua_v1{Did you turn to Allah in dua today?} halal_income_v1{Did you seek or use halal income today?} sunnah_v1{Did you follow a Sunnah practice today?} istikhara_v1{Did you seek Allah\'s guidance through istikhara for a decision today?} gratitude_v1{Did you thank Allah for His blessings today?} charity_v1{Did you give something in charity today?} kinship_v1{Did you nurture your family ties today?} early_rising_v1{Did you make use of the early morning today?} marriage_v1{Did you nurture kindness in your marriage today?} salah_v1{Did you make time for prayer today?} forgiveness_v1{Did you seek Allah\'s forgiveness today?} other{Did you notice a source of barakah today?}}'**
  String barakahDailyQuestion(String promptId);

  /// Source label for the daily prompt, not legacy logging
  ///
  /// In en, this message translates to:
  /// **'{sourceId, select, good_intentions{Good intentions} piety{Mindfulness of Allah} trust_in_allah{Trust in Allah} quran{Quran} bismillah{Saying Bismillah} eating_together{Eating together} honesty_in_trade{Honest dealings} dua{Dua} halal_income{Halal income} sunnah{Following the Sunnah} istikhara{Istikhara} gratitude{Gratitude to Allah} charity{Giving charity} kinship{Family ties} early_rising{Early rising} marriage{Kindness in marriage} salah{Prayer} forgiveness{Seeking forgiveness} other{Source of barakah}}'**
  String barakahDailySource(String sourceId);

  /// Affirmative daily answer
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get barakahDailyYes;

  /// Partial affirmative daily answer
  ///
  /// In en, this message translates to:
  /// **'Somewhat'**
  String get barakahDailySomewhat;

  /// Negative daily answer
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get barakahDailyNo;

  /// Skip this daily reflection
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get barakahDailySkip;

  /// Source selection label, shown only for yes or somewhat
  ///
  /// In en, this message translates to:
  /// **'Sources of barakah (optional)'**
  String get barakahDailySources;

  /// Daily note field label with a 280 character limit
  ///
  /// In en, this message translates to:
  /// **'Reflection note (optional)'**
  String get barakahDailyNote;

  /// Save a new daily response
  ///
  /// In en, this message translates to:
  /// **'Save response'**
  String get barakahDailySave;

  /// Save edits to the existing daily response
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get barakahDailyUpdate;

  /// Daily save in progress
  ///
  /// In en, this message translates to:
  /// **'Saving response…'**
  String get barakahDailySaving;

  /// Confirmation that today's response is saved and editable
  ///
  /// In en, this message translates to:
  /// **'Response saved. You can edit it anytime.'**
  String get barakahDailySaved;

  /// Recoverable daily response error
  ///
  /// In en, this message translates to:
  /// **'Your response could not be loaded or saved. Please try again.'**
  String get barakahDailyFailure;

  /// Reload the daily response after an error
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get barakahDailyRetry;

  /// No description provided for @barakahWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly reflection review'**
  String get barakahWeeklyTitle;

  /// No description provided for @barakahWeeklyPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get barakahWeeklyPrevious;

  /// No description provided for @barakahWeeklyNext.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get barakahWeeklyNext;

  /// No description provided for @barakahWeeklyRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String barakahWeeklyRange(String start, String end);

  /// No description provided for @barakahWeeklyDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse your saved daily reflections. These counts describe your self-reported answers and selections, not a measure of divine blessing.'**
  String get barakahWeeklyDescription;

  /// No description provided for @barakahWeeklyAnswers.
  ///
  /// In en, this message translates to:
  /// **'Saved answers'**
  String get barakahWeeklyAnswers;

  /// No description provided for @barakahWeeklyCount.
  ///
  /// In en, this message translates to:
  /// **'{label}: {count}'**
  String barakahWeeklyCount(String label, String count);

  /// No description provided for @barakahWeeklySources.
  ///
  /// In en, this message translates to:
  /// **'Selected sources'**
  String get barakahWeeklySources;

  /// No description provided for @barakahWeeklySourcesDescription.
  ///
  /// In en, this message translates to:
  /// **'Days you selected each source with Yes or Somewhat, counted once per day. Selections do not establish a cause of blessing.'**
  String get barakahWeeklySourcesDescription;

  /// No description provided for @barakahWeeklyNoSources.
  ///
  /// In en, this message translates to:
  /// **'No sources selected with Yes or Somewhat this week.'**
  String get barakahWeeklyNoSources;

  /// No description provided for @barakahWeeklyDays.
  ///
  /// In en, this message translates to:
  /// **'Daily reflections · Monday to Sunday'**
  String get barakahWeeklyDays;

  /// No description provided for @barakahWeeklyMissing.
  ///
  /// In en, this message translates to:
  /// **'No saved response'**
  String get barakahWeeklyMissing;

  /// No description provided for @barakahWeeklyFuture.
  ///
  /// In en, this message translates to:
  /// **'Upcoming day'**
  String get barakahWeeklyFuture;

  /// No description provided for @barakahWeeklySkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get barakahWeeklySkipped;

  /// No description provided for @barakahWeeklyNote.
  ///
  /// In en, this message translates to:
  /// **'Saved note'**
  String get barakahWeeklyNote;

  /// No description provided for @barakahWeeklyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No daily responses saved for this week. Daily reflections you save on the Barakah screen will appear here; free-form history is separate.'**
  String get barakahWeeklyEmpty;

  /// No description provided for @barakahWeeklyFailure.
  ///
  /// In en, this message translates to:
  /// **'This week\'s reflections could not be loaded. Please try again.'**
  String get barakahWeeklyFailure;

  /// Heading above the existing free-form logging and history UI
  ///
  /// In en, this message translates to:
  /// **'Free-form Barakah history'**
  String get barakahHistoryTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
