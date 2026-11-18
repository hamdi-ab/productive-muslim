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

  /// No description provided for @myDay.
  ///
  /// In en, this message translates to:
  /// **'My Day'**
  String get myDay;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @adhkar.
  ///
  /// In en, this message translates to:
  /// **'Adhkar Studio'**
  String get adhkar;

  /// No description provided for @reflect.
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get reflect;

  /// No description provided for @muhasabah.
  ///
  /// In en, this message translates to:
  /// **'Muhasabah'**
  String get muhasabah;

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

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @adhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get adhan;

  /// No description provided for @adhanNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get notified at prayer times'**
  String get adhanNotificationsDescription;

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

  /// No description provided for @habitMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get habitMarkComplete;

  /// No description provided for @habitUnmark.
  ///
  /// In en, this message translates to:
  /// **'Unmark'**
  String get habitUnmark;

  /// No description provided for @habitAddName.
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get habitAddName;

  /// No description provided for @habitAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get habitAddCategory;

  /// No description provided for @habitNoCompletions.
  ///
  /// In en, this message translates to:
  /// **'No completions yet'**
  String get habitNoCompletions;

  /// No description provided for @habitToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get habitToday;

  /// No description provided for @habitSwipeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get habitSwipeDelete;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name...'**
  String get enterYourName;

  /// No description provided for @weeklyTrack.
  ///
  /// In en, this message translates to:
  /// **'Weekly Track'**
  String get weeklyTrack;

  /// No description provided for @reflectionHint.
  ///
  /// In en, this message translates to:
  /// **'Your reflection...'**
  String get reflectionHint;

  /// No description provided for @intentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Intention title'**
  String get intentionTitle;

  /// No description provided for @sphereSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Sphere'**
  String get sphereSpiritual;

  /// No description provided for @spherePhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical Sphere'**
  String get spherePhysical;

  /// No description provided for @sphereSocial.
  ///
  /// In en, this message translates to:
  /// **'Social Sphere'**
  String get sphereSocial;

  /// No description provided for @sphereSpiritualDesc.
  ///
  /// In en, this message translates to:
  /// **'Salah, Quran, Dhikr, Fasting, and Islamic learning'**
  String get sphereSpiritualDesc;

  /// No description provided for @spherePhysicalDesc.
  ///
  /// In en, this message translates to:
  /// **'Sleep, Qaylulah, nutrition, fitness, and vitality'**
  String get spherePhysicalDesc;

  /// No description provided for @sphereSocialDesc.
  ///
  /// In en, this message translates to:
  /// **'Family, marriage, work excellence, and Ummah'**
  String get sphereSocialDesc;

  /// No description provided for @prayerSlot.
  ///
  /// In en, this message translates to:
  /// **'Prayer Window'**
  String get prayerSlot;

  /// No description provided for @prayerSlotNone.
  ///
  /// In en, this message translates to:
  /// **'Specific time only'**
  String get prayerSlotNone;

  /// No description provided for @slotEarlyMorning.
  ///
  /// In en, this message translates to:
  /// **'Post-Fajr Barakah Hour'**
  String get slotEarlyMorning;

  /// No description provided for @slotEarlyMorningDesc.
  ///
  /// In en, this message translates to:
  /// **'Early morning golden hours for high focus'**
  String get slotEarlyMorningDesc;

  /// No description provided for @slotDuha.
  ///
  /// In en, this message translates to:
  /// **'Mid-Morning (Duha)'**
  String get slotDuha;

  /// No description provided for @slotDuhaDesc.
  ///
  /// In en, this message translates to:
  /// **'Forenoon prime work and study block'**
  String get slotDuhaDesc;

  /// No description provided for @slotDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Post-Dhuhr'**
  String get slotDhuhr;

  /// No description provided for @slotDhuhrDesc.
  ///
  /// In en, this message translates to:
  /// **'Early afternoon block following Dhuhr prayer'**
  String get slotDhuhrDesc;

  /// No description provided for @slotAsr.
  ///
  /// In en, this message translates to:
  /// **'Post-Asr'**
  String get slotAsr;

  /// No description provided for @slotAsrDesc.
  ///
  /// In en, this message translates to:
  /// **'Late afternoon reflection or physical activity block'**
  String get slotAsrDesc;

  /// No description provided for @slotMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Between Maghrib & Isha'**
  String get slotMaghrib;

  /// No description provided for @slotMaghribDesc.
  ///
  /// In en, this message translates to:
  /// **'Family time, Quran reading, and light tasks'**
  String get slotMaghribDesc;

  /// No description provided for @slotIsha.
  ///
  /// In en, this message translates to:
  /// **'Post-Isha / Evening'**
  String get slotIsha;

  /// No description provided for @slotIshaDesc.
  ///
  /// In en, this message translates to:
  /// **'Night routine, reflection, and early sleep'**
  String get slotIshaDesc;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get focus;

  /// No description provided for @focusTitle.
  ///
  /// In en, this message translates to:
  /// **'Khushu\' Focus Session'**
  String get focusTitle;

  /// No description provided for @focusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Khushu\' Timer'**
  String get focusSubtitle;

  /// No description provided for @focusNiyyahPrompt.
  ///
  /// In en, this message translates to:
  /// **'Bismillah — Renew your intention for Allah before starting'**
  String get focusNiyyahPrompt;

  /// No description provided for @focusDua.
  ///
  /// In en, this message translates to:
  /// **'Rabbi zidni \'ilman (My Lord, increase me in knowledge)'**
  String get focusDua;

  /// No description provided for @focusStart.
  ///
  /// In en, this message translates to:
  /// **'Start Focus'**
  String get focusStart;

  /// No description provided for @focusPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get focusPause;

  /// No description provided for @focusResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get focusResume;

  /// No description provided for @focusReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get focusReset;

  /// No description provided for @focusComplete.
  ///
  /// In en, this message translates to:
  /// **'Focus Session Complete! Alhamdulillah'**
  String get focusComplete;

  /// No description provided for @focusCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'May Allah put Barakah in your efforts and accept your work.'**
  String get focusCompleteMessage;

  /// No description provided for @focusTotalMinutes.
  ///
  /// In en, this message translates to:
  /// **'Total Focus: {minutes} mins'**
  String focusTotalMinutes(int minutes);

  /// No description provided for @focusSelectTask.
  ///
  /// In en, this message translates to:
  /// **'Select a task to focus on (optional)'**
  String get focusSelectTask;

  /// No description provided for @focusPrayerWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Approaching'**
  String get focusPrayerWarningTitle;

  /// No description provided for @focusPrayerOverlap.
  ///
  /// In en, this message translates to:
  /// **'Next prayer ({prayerName}) is in {minutes}m. Your session will overlap with Salah.'**
  String focusPrayerOverlap(String prayerName, int minutes);

  /// No description provided for @focusPrayerSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Set {minutes} min session to finish before {prayerName}'**
  String focusPrayerSuggestion(int minutes, String prayerName);

  /// No description provided for @focusMarkTaskComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark linked task as completed'**
  String get focusMarkTaskComplete;

  /// No description provided for @focusTaskCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Task completed! 🎉'**
  String get focusTaskCompletedSuccess;

  /// No description provided for @focusWindDownWarning.
  ///
  /// In en, this message translates to:
  /// **'Salah in {minutes}m • Wind down your session'**
  String focusWindDownWarning(int minutes);

  /// No description provided for @focusPreset15.
  ///
  /// In en, this message translates to:
  /// **'15 min (Sprint)'**
  String get focusPreset15;

  /// No description provided for @focusPreset25.
  ///
  /// In en, this message translates to:
  /// **'25 min (Barakah block)'**
  String get focusPreset25;

  /// No description provided for @focusPreset45.
  ///
  /// In en, this message translates to:
  /// **'45 min (Deep work)'**
  String get focusPreset45;

  /// No description provided for @focusPreset60.
  ///
  /// In en, this message translates to:
  /// **'60 min (Mastery)'**
  String get focusPreset60;

  /// No description provided for @energyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Energy & Sunnah Routine'**
  String get energyTitle;

  /// No description provided for @energySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Qaylulah & Battery'**
  String get energySubtitle;

  /// No description provided for @qaylulah.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Qaylulah'**
  String get qaylulah;

  /// No description provided for @qaylulahDesc.
  ///
  /// In en, this message translates to:
  /// **'A 20-min midday Sunnah power nap to recharge your afternoon'**
  String get qaylulahDesc;

  /// No description provided for @qaylulahStart.
  ///
  /// In en, this message translates to:
  /// **'Start Qaylulah Nap'**
  String get qaylulahStart;

  /// No description provided for @qaylulahWakingDua.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillahil-ladhi ahyana ba\'da ma amatana wa ilayhin-nushur'**
  String get qaylulahWakingDua;

  /// No description provided for @sunnahFasting.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Fasting'**
  String get sunnahFasting;

  /// No description provided for @sunnahFastingDesc.
  ///
  /// In en, this message translates to:
  /// **'Mondays, Thursdays, and the White Days (13th, 14th, 15th)'**
  String get sunnahFastingDesc;

  /// No description provided for @sunnahFastingIntention.
  ///
  /// In en, this message translates to:
  /// **'Fast for Allah today'**
  String get sunnahFastingIntention;

  /// No description provided for @energyPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical Vitality'**
  String get energyPhysical;

  /// No description provided for @energySpiritual.
  ///
  /// In en, this message translates to:
  /// **'Spiritual State'**
  String get energySpiritual;

  /// No description provided for @energyMental.
  ///
  /// In en, this message translates to:
  /// **'Mental Focus'**
  String get energyMental;

  /// No description provided for @energySaved.
  ///
  /// In en, this message translates to:
  /// **'Energy check-in updated'**
  String get energySaved;

  /// No description provided for @qualityDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Practical Action'**
  String get qualityDetailsAction;

  /// No description provided for @qualityDetailsContext.
  ///
  /// In en, this message translates to:
  /// **'Islamic Foundation'**
  String get qualityDetailsContext;

  /// No description provided for @adhkarTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Adhkar & Remembrances'**
  String get adhkarTitle;

  /// No description provided for @adhkarMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning Adhkar'**
  String get adhkarMorning;

  /// No description provided for @adhkarEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening Adhkar'**
  String get adhkarEvening;

  /// No description provided for @adhkarWaking.
  ///
  /// In en, this message translates to:
  /// **'Waking Up Du\'as'**
  String get adhkarWaking;

  /// No description provided for @adhkarSleeping.
  ///
  /// In en, this message translates to:
  /// **'Bedtime Adhkar'**
  String get adhkarSleeping;

  /// No description provided for @adhkarPostPrayer.
  ///
  /// In en, this message translates to:
  /// **'Post-Salah Adhkar'**
  String get adhkarPostPrayer;

  /// No description provided for @adhkarDailySunnah.
  ///
  /// In en, this message translates to:
  /// **'Daily Sunnah Remembrances'**
  String get adhkarDailySunnah;

  /// No description provided for @adhkarTapToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to count'**
  String get adhkarTapToCount;

  /// No description provided for @adhkarCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed! Alhamdulillah'**
  String get adhkarCompleted;

  /// No description provided for @adhkarCompletedMsg.
  ///
  /// In en, this message translates to:
  /// **'May Allah accept your remembrance and fill your day with Barakah.'**
  String get adhkarCompletedMsg;

  /// No description provided for @adhkarVirtue.
  ///
  /// In en, this message translates to:
  /// **'Hadith & Spiritual Virtue'**
  String get adhkarVirtue;

  /// No description provided for @adhkarNext.
  ///
  /// In en, this message translates to:
  /// **'Next Dhikr'**
  String get adhkarNext;

  /// No description provided for @adhkarPrev.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get adhkarPrev;

  /// No description provided for @adhkarReset.
  ///
  /// In en, this message translates to:
  /// **'Reset Count'**
  String get adhkarReset;

  /// No description provided for @adhkarResetCategory.
  ///
  /// In en, this message translates to:
  /// **'Reset Category'**
  String get adhkarResetCategory;

  /// No description provided for @adhkarTypography.
  ///
  /// In en, this message translates to:
  /// **'Arabic Calligraphy'**
  String get adhkarTypography;

  /// No description provided for @typographyTitle.
  ///
  /// In en, this message translates to:
  /// **'Arabic Typography & Calligraphy'**
  String get typographyTitle;

  /// No description provided for @typographyFontFamily.
  ///
  /// In en, this message translates to:
  /// **'Calligraphy Script'**
  String get typographyFontFamily;

  /// No description provided for @typographyFontSize.
  ///
  /// In en, this message translates to:
  /// **'Arabic Font Size'**
  String get typographyFontSize;

  /// No description provided for @typographyPreview.
  ///
  /// In en, this message translates to:
  /// **'Live Verse Preview'**
  String get typographyPreview;

  /// No description provided for @typographyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Customize Arabic calligraphy and font size'**
  String get typographyTooltip;

  /// No description provided for @adhkarTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Transliteration'**
  String get adhkarTransliteration;

  /// No description provided for @adhkarPillMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning Adhkar • Light & Protection'**
  String get adhkarPillMorning;

  /// No description provided for @adhkarPillEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening Adhkar • Evening Shield'**
  String get adhkarPillEvening;

  /// No description provided for @adhkarPillSleeping.
  ///
  /// In en, this message translates to:
  /// **'Bedtime Adhkar • Guard your night'**
  String get adhkarPillSleeping;

  /// No description provided for @adhkarPillPostPrayer.
  ///
  /// In en, this message translates to:
  /// **'Post-Salah Adhkar • 33x Tasbih'**
  String get adhkarPillPostPrayer;

  /// No description provided for @adhkarProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} completed'**
  String adhkarProgress(int completed, int total);

  /// No description provided for @adhkarEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No remembrances in this category yet.'**
  String get adhkarEmptyState;

  /// No description provided for @adhkarActionRecite.
  ///
  /// In en, this message translates to:
  /// **'Recite'**
  String get adhkarActionRecite;

  /// No description provided for @adhkarActionReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get adhkarActionReview;

  /// No description provided for @adhkarPillTapPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap to recite • 1-tap haptic counter'**
  String get adhkarPillTapPrompt;

  /// No description provided for @adhkarTabMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get adhkarTabMorning;

  /// No description provided for @adhkarTabEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get adhkarTabEvening;

  /// No description provided for @adhkarTabWaking.
  ///
  /// In en, this message translates to:
  /// **'Waking'**
  String get adhkarTabWaking;

  /// No description provided for @adhkarTabBedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get adhkarTabBedtime;

  /// No description provided for @adhkarTabPostSalah.
  ///
  /// In en, this message translates to:
  /// **'Post-Salah'**
  String get adhkarTabPostSalah;

  /// No description provided for @adhkarTabSunnah.
  ///
  /// In en, this message translates to:
  /// **'Sunnah'**
  String get adhkarTabSunnah;

  /// No description provided for @adhkarTabGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get adhkarTabGeneral;

  /// No description provided for @adhkarTabBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get adhkarTabBookmarks;

  /// No description provided for @adhkarBookmarksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookmarked adhkar yet. Tap the bookmark icon to save any remembrance.'**
  String get adhkarBookmarksEmpty;

  /// No description provided for @adhkarResumePrompt.
  ///
  /// In en, this message translates to:
  /// **'Resume from Dhikr {index}'**
  String adhkarResumePrompt(int index);

  /// No description provided for @adhkarCompletedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get adhkarCompletedToday;

  /// No description provided for @adhkarToggleTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Toggle transliteration'**
  String get adhkarToggleTransliteration;

  /// No description provided for @adhkarBookmarkAdd.
  ///
  /// In en, this message translates to:
  /// **'Bookmark dhikr'**
  String get adhkarBookmarkAdd;

  /// No description provided for @adhkarBookmarkRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get adhkarBookmarkRemove;

  /// No description provided for @smartNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Adhkar & Sunnah Reminders'**
  String get smartNotificationsTitle;

  /// No description provided for @smartNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Dynamic reminders anchored to solar prayer times and Sunnah schedules.'**
  String get smartNotificationsDesc;

  /// No description provided for @settingMorningAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Morning Adhkar (Post-Fajr)'**
  String get settingMorningAdhkar;

  /// No description provided for @settingMorningAdhkarDesc.
  ///
  /// In en, this message translates to:
  /// **'Timed 15 min after Fajr during your morning Barakah window.'**
  String get settingMorningAdhkarDesc;

  /// No description provided for @settingEveningAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Evening Adhkar (Post-Asr)'**
  String get settingEveningAdhkar;

  /// No description provided for @settingEveningAdhkarDesc.
  ///
  /// In en, this message translates to:
  /// **'Fortify your soul with evening remembrances before sunset.'**
  String get settingEveningAdhkarDesc;

  /// No description provided for @settingBedtimeAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Bedtime Adhkar & Wind-down'**
  String get settingBedtimeAdhkar;

  /// No description provided for @settingBedtimeAdhkarDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminds you before sleep to recite Surat Al-Ikhlas, Falaq, Nas.'**
  String get settingBedtimeAdhkarDesc;

  /// No description provided for @settingBedtimeTime.
  ///
  /// In en, this message translates to:
  /// **'Target Bedtime'**
  String get settingBedtimeTime;

  /// No description provided for @settingSunnahFasting.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Fasting Reminders'**
  String get settingSunnahFasting;

  /// No description provided for @settingSunnahFastingDesc.
  ///
  /// In en, this message translates to:
  /// **'Nudge on Sunday & Wednesday evenings to intend Mon/Thu fasting.'**
  String get settingSunnahFastingDesc;

  /// No description provided for @settingQaylulah.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Qaylulah Midday Nap'**
  String get settingQaylulah;

  /// No description provided for @settingQaylulahDesc.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminder 30 min before Dhuhr for a 20-min recharge.'**
  String get settingQaylulahDesc;

  /// No description provided for @barakahAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Growth & Analytics'**
  String get barakahAnalyticsTitle;

  /// No description provided for @barakahAnalyticsConsistency.
  ///
  /// In en, this message translates to:
  /// **'7-Day Barakah Matrix'**
  String get barakahAnalyticsConsistency;

  /// No description provided for @barakahAnalyticsEnergyTriad.
  ///
  /// In en, this message translates to:
  /// **'Holistic Energy Triad'**
  String get barakahAnalyticsEnergyTriad;

  /// No description provided for @barakahAnalyticsSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Spiritual'**
  String get barakahAnalyticsSpiritual;

  /// No description provided for @barakahAnalyticsPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get barakahAnalyticsPhysical;

  /// No description provided for @barakahAnalyticsMental.
  ///
  /// In en, this message translates to:
  /// **'Mental'**
  String get barakahAnalyticsMental;

  /// No description provided for @barakahAnalyticsActiveDays.
  ///
  /// In en, this message translates to:
  /// **'{count} / 7 Active Days'**
  String barakahAnalyticsActiveDays(int count);

  /// No description provided for @barakahAnalyticsTotalDhikr.
  ///
  /// In en, this message translates to:
  /// **'{count} Adhkar Completed'**
  String barakahAnalyticsTotalDhikr(int count);

  /// No description provided for @barakahAnalyticsFastingDays.
  ///
  /// In en, this message translates to:
  /// **'{count} Fasting Days'**
  String barakahAnalyticsFastingDays(int count);

  /// No description provided for @barakahAnalyticsCoachingTitle.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Growth Insights'**
  String get barakahAnalyticsCoachingTitle;

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla Compass'**
  String get qiblaTitle;

  /// No description provided for @qiblaTabTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get qiblaTabTimes;

  /// No description provided for @qiblaTabCompass.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaTabCompass;

  /// No description provided for @qiblaBearing.
  ///
  /// In en, this message translates to:
  /// **'{degrees}° from North'**
  String qiblaBearing(String degrees);

  /// No description provided for @qiblaDistance.
  ///
  /// In en, this message translates to:
  /// **'{distance} km to Kaaba, Makkah'**
  String qiblaDistance(String distance);

  /// No description provided for @qiblaFacingKaaba.
  ///
  /// In en, this message translates to:
  /// **'You are facing the Kaaba'**
  String get qiblaFacingKaaba;

  /// No description provided for @qiblaDirectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirectionLabel;

  /// No description provided for @qiblaDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get qiblaDistanceLabel;

  /// No description provided for @qiblaTurnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn {degrees}° Right'**
  String qiblaTurnRight(String degrees);

  /// No description provided for @qiblaTurnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn {degrees}° Left'**
  String qiblaTurnLeft(String degrees);

  /// No description provided for @qiblaCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate Compass: Rotate device in a figure-8 motion away from metal interference.'**
  String get qiblaCalibrate;

  /// No description provided for @solarDialTitle.
  ///
  /// In en, this message translates to:
  /// **'Solar Prayer Arc'**
  String get solarDialTitle;

  /// No description provided for @solarCurrentWindow.
  ///
  /// In en, this message translates to:
  /// **'Active Window: {slot}'**
  String solarCurrentWindow(String slot);

  /// No description provided for @solarNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {prayer}'**
  String solarNext(String prayer);

  /// No description provided for @slotTahajjud.
  ///
  /// In en, this message translates to:
  /// **'Tahajjud / Pre-Fajr'**
  String get slotTahajjud;

  /// No description provided for @slotNight.
  ///
  /// In en, this message translates to:
  /// **'Night / Qiyam'**
  String get slotNight;

  /// No description provided for @widgetAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Productive Muslim'**
  String get widgetAppTitle;

  /// No description provided for @widgetNextPrayerLabel.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get widgetNextPrayerLabel;

  /// No description provided for @widgetDhikrCount.
  ///
  /// In en, this message translates to:
  /// **'Dhikr: {count} completed'**
  String widgetDhikrCount(int count);

  /// No description provided for @widgetBtnPrayers.
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get widgetBtnPrayers;

  /// No description provided for @widgetBtnAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Adhkar'**
  String get widgetBtnAdhkar;

  /// No description provided for @widgetBtnFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get widgetBtnFocus;

  /// No description provided for @widgetBtnPlusOne.
  ///
  /// In en, this message translates to:
  /// **'+1'**
  String get widgetBtnPlusOne;

  /// No description provided for @hijriCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Hijri Calendar & Fasting'**
  String get hijriCalendarTitle;

  /// No description provided for @hijriToday.
  ///
  /// In en, this message translates to:
  /// **'Today: {date}'**
  String hijriToday(String date);

  /// No description provided for @whiteDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'White Days (Ayyam al-Beed)'**
  String get whiteDaysLabel;

  /// No description provided for @whiteDaysDesc.
  ///
  /// In en, this message translates to:
  /// **'13th, 14th & 15th of the lunar month'**
  String get whiteDaysDesc;

  /// No description provided for @mondayThursdaySunnah.
  ///
  /// In en, this message translates to:
  /// **'Monday & Thursday Sunnah'**
  String get mondayThursdaySunnah;

  /// No description provided for @fastingCountdownSuhoor.
  ///
  /// In en, this message translates to:
  /// **'Suhoor ends in {time}'**
  String fastingCountdownSuhoor(String time);

  /// No description provided for @fastingCountdownIftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar in {time}'**
  String fastingCountdownIftar(String time);

  /// No description provided for @fastingTodayActive.
  ///
  /// In en, this message translates to:
  /// **'Fasting Today'**
  String get fastingTodayActive;

  /// No description provided for @fastingTodayInactive.
  ///
  /// In en, this message translates to:
  /// **'Not Fasting Today'**
  String get fastingTodayInactive;

  /// No description provided for @fastingIntendAction.
  ///
  /// In en, this message translates to:
  /// **'Intend to Fast'**
  String get fastingIntendAction;

  /// No description provided for @fastingLoggedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Fasting record updated'**
  String get fastingLoggedSuccess;

  /// No description provided for @iftarDuaTitle.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Iftar Du\'a'**
  String get iftarDuaTitle;

  /// No description provided for @iftarDuaArabic.
  ///
  /// In en, this message translates to:
  /// **'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ'**
  String get iftarDuaArabic;

  /// No description provided for @iftarDuaTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Dhahaba adh-dhama\'u wabtallatil-\'urooqu wa thabatal-ajru in sha Allah'**
  String get iftarDuaTransliteration;

  /// No description provided for @iftarDuaTranslation.
  ///
  /// In en, this message translates to:
  /// **'The thirst has gone, the veins are moistened, and the reward is confirmed, if Allah wills.'**
  String get iftarDuaTranslation;

  /// No description provided for @fastingStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} days fasted'**
  String fastingStreak(int count);

  /// No description provided for @fastingVirtueTitle.
  ///
  /// In en, this message translates to:
  /// **'Virtue of Fasting'**
  String get fastingVirtueTitle;

  /// No description provided for @fastingVirtueDesc.
  ///
  /// In en, this message translates to:
  /// **'Fasting 3 days each month is like fasting the entire year (Bukhari & Muslim).'**
  String get fastingVirtueDesc;

  /// No description provided for @fastingGuidelinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Fasting Guidelines'**
  String get fastingGuidelinesTitle;

  /// No description provided for @suhoorSunnahTitle.
  ///
  /// In en, this message translates to:
  /// **'Do Not Skip Suhoor'**
  String get suhoorSunnahTitle;

  /// No description provided for @suhoorSunnahDesc.
  ///
  /// In en, this message translates to:
  /// **'The Prophet (ﷺ) said: \"Take Suhoor, for in Suhoor there is Barakah (blessing).\" (Bukhari)'**
  String get suhoorSunnahDesc;

  /// No description provided for @hydrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Optimal Hydration'**
  String get hydrationTitle;

  /// No description provided for @hydrationDesc.
  ///
  /// In en, this message translates to:
  /// **'Drink ample water between Iftar and Suhoor to maintain high energy and mental focus.'**
  String get hydrationDesc;

  /// No description provided for @breakPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Hasten to Break the Fast'**
  String get breakPromptTitle;

  /// No description provided for @breakPromptDesc.
  ///
  /// In en, this message translates to:
  /// **'Break your fast promptly at Maghrib with dates and water, following the Sunnah.'**
  String get breakPromptDesc;

  /// No description provided for @whiteDayBadge.
  ///
  /// In en, this message translates to:
  /// **'White Day'**
  String get whiteDayBadge;

  /// No description provided for @prevMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous Month'**
  String get prevMonthTooltip;

  /// No description provided for @nextMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next Month'**
  String get nextMonthTooltip;

  /// No description provided for @todayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTooltip;

  /// No description provided for @suhoorWindow.
  ///
  /// In en, this message translates to:
  /// **'Suhoor Window'**
  String get suhoorWindow;

  /// No description provided for @fastInProgress.
  ///
  /// In en, this message translates to:
  /// **'Fast in Progress'**
  String get fastInProgress;

  /// No description provided for @iftarCompleted.
  ///
  /// In en, this message translates to:
  /// **'Iftar Completed'**
  String get iftarCompleted;

  /// No description provided for @sunnahBadge.
  ///
  /// In en, this message translates to:
  /// **'Sunnah'**
  String get sunnahBadge;

  /// No description provided for @copyDuaTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy Du\'a'**
  String get copyDuaTooltip;

  /// No description provided for @duaCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Du\'a copied to clipboard'**
  String get duaCopiedMessage;

  /// No description provided for @iftarHadithRef.
  ///
  /// In en, this message translates to:
  /// **'Sunan Abi Dawud (2357) — Sahih'**
  String get iftarHadithRef;

  /// No description provided for @heatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'12-Week Consistency Heatmap'**
  String get heatmapTitle;

  /// No description provided for @heatmapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Barakah & habit momentum'**
  String get heatmapSubtitle;

  /// No description provided for @heatmapLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get heatmapLess;

  /// No description provided for @heatmapMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get heatmapMore;

  /// No description provided for @heatmapActiveDays.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} active days'**
  String heatmapActiveDays(int count, int total);

  /// No description provided for @heatmapScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity score: {count}'**
  String heatmapScoreLabel(int count);

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Sovereignty & Local Backup'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Export or restore your tasks, habits, and reflections safely on device.'**
  String get backupRestoreDesc;

  /// No description provided for @backupExportBtn.
  ///
  /// In en, this message translates to:
  /// **'Export Backup (JSON)'**
  String get backupExportBtn;

  /// No description provided for @backupImportBtn.
  ///
  /// In en, this message translates to:
  /// **'Restore from JSON'**
  String get backupImportBtn;

  /// No description provided for @backupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup JSON copied to clipboard!'**
  String get backupExportSuccess;

  /// No description provided for @backupExportError.
  ///
  /// In en, this message translates to:
  /// **'Failed to export backup. Please try again.'**
  String get backupExportError;

  /// No description provided for @backupImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data successfully restored!'**
  String get backupImportSuccess;

  /// No description provided for @backupImportError.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup JSON payload. Please check and try again.'**
  String get backupImportError;

  /// No description provided for @backupConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get backupConfirmTitle;

  /// No description provided for @backupConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Restoring will replace all current local data with the backup contents. Are you sure you want to proceed?'**
  String get backupConfirmMsg;

  /// No description provided for @backupRestorePasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your exported JSON backup text here...'**
  String get backupRestorePasteHint;

  /// No description provided for @backupCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get backupCancel;

  /// No description provided for @backupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore Now'**
  String get backupConfirm;

  /// No description provided for @preferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences & Touch'**
  String get preferencesTitle;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Vibration feedback on taps, counters, and completions'**
  String get hapticFeedbackDesc;

  /// No description provided for @languageDesc.
  ///
  /// In en, this message translates to:
  /// **'Change app display language'**
  String get languageDesc;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageAr.
  ///
  /// In en, this message translates to:
  /// **'العربية (Arabic)'**
  String get languageAr;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @quickToolkit.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Toolkit'**
  String get quickToolkit;

  /// No description provided for @allTools.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get allTools;

  /// No description provided for @fastingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Days'**
  String get fastingSubtitle;

  /// No description provided for @adhkarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Remembrances'**
  String get adhkarSubtitle;

  /// No description provided for @timeAwareMorningTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning Barakah Window'**
  String get timeAwareMorningTitle;

  /// No description provided for @timeAwareMorningDesc.
  ///
  /// In en, this message translates to:
  /// **'Start with morning adhkar & set your daily intention.'**
  String get timeAwareMorningDesc;

  /// No description provided for @timeAwareMiddayTitle.
  ///
  /// In en, this message translates to:
  /// **'Midday Qaylulah & Focus'**
  String get timeAwareMiddayTitle;

  /// No description provided for @timeAwareMiddayDesc.
  ///
  /// In en, this message translates to:
  /// **'Recharge with a 20-min Sunnah nap or start deep work.'**
  String get timeAwareMiddayDesc;

  /// No description provided for @timeAwareEveningTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening Adhkar & Wind-down'**
  String get timeAwareEveningTitle;

  /// No description provided for @timeAwareEveningDesc.
  ///
  /// In en, this message translates to:
  /// **'Recite your evening protections and review today\'s progress.'**
  String get timeAwareEveningDesc;

  /// No description provided for @timeAwareNightTitle.
  ///
  /// In en, this message translates to:
  /// **'Night Reflection & Muhasabah'**
  String get timeAwareNightTitle;

  /// No description provided for @timeAwareNightDesc.
  ///
  /// In en, this message translates to:
  /// **'Record your gratitude (Shukr) and recite bedtime adhkar.'**
  String get timeAwareNightDesc;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get startNow;

  /// No description provided for @fastingTitle.
  ///
  /// In en, this message translates to:
  /// **'Fasting & Hijri'**
  String get fastingTitle;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy & Routines'**
  String get energy;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Sovereignty & Account'**
  String get profileSubtitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @enterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name or seeker title'**
  String get enterNameHint;

  /// No description provided for @spiritualMotto.
  ///
  /// In en, this message translates to:
  /// **'Sacred Intention / Daily Motto'**
  String get spiritualMotto;

  /// No description provided for @enterMottoHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Seeking Allah\'s pleasure through Ihsan'**
  String get enterMottoHint;

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar Symbol'**
  String get chooseAvatar;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @spiritualRank.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Rank'**
  String get spiritualRank;

  /// No description provided for @nextRankProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress to next rank'**
  String get nextRankProgress;

  /// No description provided for @lifetimeMomentum.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Momentum'**
  String get lifetimeMomentum;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best: {days}d'**
  String bestStreak(int days);

  /// No description provided for @habitsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Habits Built'**
  String get habitsCompleted;

  /// No description provided for @tasksAccomplished.
  ///
  /// In en, this message translates to:
  /// **'Tasks Done'**
  String get tasksAccomplished;

  /// No description provided for @focusHours.
  ///
  /// In en, this message translates to:
  /// **'Focus Hours'**
  String get focusHours;

  /// No description provided for @spiritualMilestones.
  ///
  /// In en, this message translates to:
  /// **'Consistency Milestones'**
  String get spiritualMilestones;

  /// No description provided for @milestoneUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get milestoneUnlocked;

  /// No description provided for @milestoneLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get milestoneLocked;

  /// No description provided for @qualitiesCoaching.
  ///
  /// In en, this message translates to:
  /// **'9 Qualities Coaching'**
  String get qualitiesCoaching;

  /// No description provided for @topStrength.
  ///
  /// In en, this message translates to:
  /// **'Core Strength'**
  String get topStrength;

  /// No description provided for @growthFocus.
  ///
  /// In en, this message translates to:
  /// **'Growth Focus'**
  String get growthFocus;

  /// No description provided for @dataSovereignty.
  ///
  /// In en, this message translates to:
  /// **'Data & Sovereignty'**
  String get dataSovereignty;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export JSON Backup'**
  String get exportBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get restoreBackup;

  /// No description provided for @shareUmmah.
  ///
  /// In en, this message translates to:
  /// **'Share Productive Muslim'**
  String get shareUmmah;

  /// No description provided for @offlinePrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'100% Offline & Private — Your deeds remain between you and Allah.'**
  String get offlinePrivacyNotice;

  /// No description provided for @badgeFajrVanguard.
  ///
  /// In en, this message translates to:
  /// **'Fajr Vanguard'**
  String get badgeFajrVanguard;

  /// No description provided for @badgeFajrVanguardDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintained a 7-day Fajr prayer & morning adhkar streak.'**
  String get badgeFajrVanguardDesc;

  /// No description provided for @badgeIstiqamahMaster.
  ///
  /// In en, this message translates to:
  /// **'Istiqamah Master'**
  String get badgeIstiqamahMaster;

  /// No description provided for @badgeIstiqamahMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Achieved a 21-day continuous habit momentum.'**
  String get badgeIstiqamahMasterDesc;

  /// No description provided for @badgeWhiteDaysGuardian.
  ///
  /// In en, this message translates to:
  /// **'White Days Guardian'**
  String get badgeWhiteDaysGuardian;

  /// No description provided for @badgeWhiteDaysGuardianDesc.
  ///
  /// In en, this message translates to:
  /// **'Fasted the sacred White Days (Ayyam al-Beed).'**
  String get badgeWhiteDaysGuardianDesc;

  /// No description provided for @badgeDhikrAbundance.
  ///
  /// In en, this message translates to:
  /// **'Dhikr Abundance'**
  String get badgeDhikrAbundance;

  /// No description provided for @badgeDhikrAbundanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Reached 1,000+ total tasbeeh repetitions.'**
  String get badgeDhikrAbundanceDesc;

  /// No description provided for @badgeNiyyahPurity.
  ///
  /// In en, this message translates to:
  /// **'Niyyah Purity'**
  String get badgeNiyyahPurity;

  /// No description provided for @badgeNiyyahPurityDesc.
  ///
  /// In en, this message translates to:
  /// **'Recorded pure intentions for 14 consecutive days.'**
  String get badgeNiyyahPurityDesc;

  /// No description provided for @badgeMuhasabahDevotee.
  ///
  /// In en, this message translates to:
  /// **'Muhasabah Devotee'**
  String get badgeMuhasabahDevotee;

  /// No description provided for @badgeMuhasabahDevoteeDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed 4 consecutive weekly spiritual self-audits.'**
  String get badgeMuhasabahDevoteeDesc;

  /// No description provided for @barakahReflectiveHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Barakah & Reflection'**
  String get barakahReflectiveHeaderTitle;

  /// No description provided for @barakahReflectiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mindful intention, sincere action, and gratitude.'**
  String get barakahReflectiveSubtitle;

  /// No description provided for @barakahActivityRecordDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Activity counts describe self-reported app usage, not a measure of divine blessing, faith, or sincerity.'**
  String get barakahActivityRecordDisclaimer;

  /// No description provided for @todayRecordedActivity.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Recorded Activity'**
  String get todayRecordedActivity;

  /// No description provided for @habitsLoggedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} habits kept'**
  String habitsLoggedCount(int count);

  /// No description provided for @focusMinutesLoggedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} focus mins'**
  String focusMinutesLoggedCount(int count);

  /// No description provided for @reflectionsLoggedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reflections'**
  String reflectionsLoggedCount(int count);

  /// No description provided for @reflectionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Reflection saved'**
  String get reflectionCompleted;

  /// No description provided for @reflectionPending.
  ///
  /// In en, this message translates to:
  /// **'Reflection pending'**
  String get reflectionPending;

  /// No description provided for @muhasabahHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening Muhasabah'**
  String get muhasabahHeaderTitle;

  /// No description provided for @muhasabahHeaderQuote.
  ///
  /// In en, this message translates to:
  /// **'Take account of yourselves before you are taken to account, and weigh your deeds before they are weighed.'**
  String get muhasabahHeaderQuote;

  /// No description provided for @muhasabahPromptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Thoughtful Prompts'**
  String get muhasabahPromptsTitle;

  /// No description provided for @muhasabahPromptFree.
  ///
  /// In en, this message translates to:
  /// **'Free Reflection'**
  String get muhasabahPromptFree;

  /// No description provided for @muhasabahPromptGratitude.
  ///
  /// In en, this message translates to:
  /// **'What blessing did you receive today that you are grateful for?'**
  String get muhasabahPromptGratitude;

  /// No description provided for @muhasabahPromptPatience.
  ///
  /// In en, this message translates to:
  /// **'Where did you face difficulty today, and how did you seek Allah\'s help?'**
  String get muhasabahPromptPatience;

  /// No description provided for @muhasabahPromptForgiveness.
  ///
  /// In en, this message translates to:
  /// **'What shortcoming can you ask forgiveness (Istighfar) for tonight?'**
  String get muhasabahPromptForgiveness;

  /// No description provided for @muhasabahPromptIhsan.
  ///
  /// In en, this message translates to:
  /// **'How did you strive for excellence (Ihsan) in your work or dealings?'**
  String get muhasabahPromptIhsan;

  /// No description provided for @muhasabahPromptIntention.
  ///
  /// In en, this message translates to:
  /// **'What intention do you renew for tomorrow?'**
  String get muhasabahPromptIntention;

  /// No description provided for @muhasabahSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save Reflection'**
  String get muhasabahSaveAction;

  /// No description provided for @muhasabahInputHint.
  ///
  /// In en, this message translates to:
  /// **'Jot down your reflections, gratitude, or lessons learned...'**
  String get muhasabahInputHint;

  /// No description provided for @muhasabahSavedToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reflections'**
  String get muhasabahSavedToday;

  /// No description provided for @muhasabahEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Take a quiet moment to reflect whenever you are ready. No scores, no streaks.'**
  String get muhasabahEmptyMessage;

  /// No description provided for @muhasabahDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Reflection?'**
  String get muhasabahDeleteConfirmTitle;

  /// No description provided for @muhasabahDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this reflection entry?'**
  String get muhasabahDeleteConfirmMessage;

  /// No description provided for @muhasabahReflectionSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Reflection saved quietly.'**
  String get muhasabahReflectionSavedToast;
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
