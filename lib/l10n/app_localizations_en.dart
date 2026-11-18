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
  String get onboardingWelcomeTitle => 'Build your day around what matters';

  @override
  String get onboardingWelcomeSubtitle =>
      'Prayer, tasks, habits, and intentions — together in one space';

  @override
  String get onboardingNameTitle => 'What is your name?';

  @override
  String get onboardingNameSubtitle =>
      'We use it to personalize your experience';

  @override
  String get onboardingIntentionTitle => 'What brings you today?';

  @override
  String get onboardingIntentionSubtitle =>
      'Choose or write your own intention';

  @override
  String get onboardingPermissionTitle => 'Set up prayer times';

  @override
  String get onboardingPermissionSubtitle =>
      'Get accurate adhan notifications for your location';

  @override
  String get onboardingPermissionBody =>
      'Allow location access for accurate prayer times?';

  @override
  String get onboardingPermissionGrant => 'Allow Access';

  @override
  String get onboardingPermissionGranted => 'Location access granted';

  @override
  String get onboardingPermissionDenied => 'Location access denied';

  @override
  String get onboardingPermissionDeniedBody =>
      'We need your location for accurate prayer times. You can enable it in your device settings.';

  @override
  String get onboardingPermissionOpenSettings => 'Open Settings';

  @override
  String get onboardingPermissionRetry => 'Try Again';

  @override
  String get onboardingPermissionServiceOff => 'Location services are off';

  @override
  String get onboardingPermissionServiceOffBody =>
      'Please enable location services on your device to get accurate prayer times.';

  @override
  String get allowLocation =>
      'Allow location access for accurate prayer times?';

  @override
  String get onboardingQualitiesTitle => 'What qualities do you want to build?';

  @override
  String get onboardingQualitiesSubtitle => 'Choose up to 3 to focus on';

  @override
  String get qualityTaqwa => 'God-Consciousness';

  @override
  String get qualityTaqwaDesc => 'Mindfulness of Allah in every action';

  @override
  String get qualityIkhlas => 'Sincerity';

  @override
  String get qualityIkhlasDesc => 'Purity of intention for Allah alone';

  @override
  String get qualitySabr => 'Patience';

  @override
  String get qualitySabrDesc => 'Steadfastness through trials and delay';

  @override
  String get qualityShukr => 'Gratitude';

  @override
  String get qualityShukrDesc =>
      'Recognizing and appreciating Allah\'s blessings';

  @override
  String get qualityTawakkul => 'Trust in Allah';

  @override
  String get qualityTawakkulDesc => 'Reliance on Allah after doing your part';

  @override
  String get qualityIhsan => 'Excellence';

  @override
  String get qualityIhsanDesc => 'Doing everything as if Allah is watching';

  @override
  String get qualityIlm => 'Knowledge';

  @override
  String get qualityIlmDesc => 'Seeking beneficial knowledge continuously';

  @override
  String get qualityDawah => 'Invitation';

  @override
  String get qualityDawahDesc => 'Calling others to Islam through character';

  @override
  String get qualityUmmah => 'Community';

  @override
  String get qualityUmmahDesc => 'Strength through brotherhood and sisterhood';

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
  String get myDay => 'My Day';

  @override
  String get overview => 'Overview';

  @override
  String get adhkar => 'Adhkar Studio';

  @override
  String get reflect => 'Reflect';

  @override
  String get muhasabah => 'Muhasabah';

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
  String get taskStartTime => 'Start time';

  @override
  String get taskEndTime => 'End time';

  @override
  String get taskNotes => 'Notes (optional)';

  @override
  String get taskRepeat => 'Repeat';

  @override
  String get taskRepeatDaily => 'Daily';

  @override
  String get taskRepeatWeekly => 'Weekly';

  @override
  String get taskOverdue => 'Overdue';

  @override
  String get taskScheduled => 'Scheduled';

  @override
  String get taskNoTime => 'No time set';

  @override
  String get taskSwipeComplete => 'Complete';

  @override
  String get taskSwipeDelete => 'Delete';

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
  String get sunrise => 'Sunrise';

  @override
  String get adhan => 'Adhan';

  @override
  String get adhanNotificationsDescription => 'Get notified at prayer times';

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
  String get barakahWeeklyTitle => 'Weekly reflection review';

  @override
  String get barakahWeeklyPrevious => 'Previous week';

  @override
  String get barakahWeeklyNext => 'Next week';

  @override
  String barakahWeeklyRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get barakahWeeklyDescription =>
      'Browse your saved daily reflections. These counts describe your self-reported answers and selections, not a measure of divine blessing.';

  @override
  String get barakahWeeklyAnswers => 'Saved answers';

  @override
  String barakahWeeklyCount(String label, String count) {
    return '$label: $count';
  }

  @override
  String get barakahWeeklySources => 'Selected sources';

  @override
  String get barakahWeeklySourcesDescription =>
      'Days you selected each source with Yes or Somewhat, counted once per day. Selections do not establish a cause of blessing.';

  @override
  String get barakahWeeklyNoSources =>
      'No sources selected with Yes or Somewhat this week.';

  @override
  String get barakahWeeklyDays => 'Daily reflections · Monday to Sunday';

  @override
  String get barakahWeeklyMissing => 'No saved response';

  @override
  String get barakahWeeklyFuture => 'Upcoming day';

  @override
  String get barakahWeeklySkipped => 'Skipped';

  @override
  String get barakahWeeklyNote => 'Saved note';

  @override
  String get barakahWeeklyEmpty =>
      'No daily responses saved for this week. Daily reflections you save on the Barakah screen will appear here; free-form history is separate.';

  @override
  String get barakahWeeklyFailure =>
      'This week\'s reflections could not be loaded. Please try again.';

  @override
  String get barakahHistoryTitle => 'Free-form Barakah history';

  @override
  String get habitMarkComplete => 'Mark complete';

  @override
  String get habitUnmark => 'Unmark';

  @override
  String get habitAddName => 'Habit name';

  @override
  String get habitAddCategory => 'Category';

  @override
  String get habitNoCompletions => 'No completions yet';

  @override
  String get habitToday => 'Today';

  @override
  String get habitSwipeDelete => 'Delete';

  @override
  String get enterYourName => 'Enter your name...';

  @override
  String get weeklyTrack => 'Weekly Track';

  @override
  String get reflectionHint => 'Your reflection...';

  @override
  String get intentionTitle => 'Intention title';

  @override
  String get sphereSpiritual => 'Spiritual Sphere';

  @override
  String get spherePhysical => 'Physical Sphere';

  @override
  String get sphereSocial => 'Social Sphere';

  @override
  String get sphereSpiritualDesc =>
      'Salah, Quran, Dhikr, Fasting, and Islamic learning';

  @override
  String get spherePhysicalDesc =>
      'Sleep, Qaylulah, nutrition, fitness, and vitality';

  @override
  String get sphereSocialDesc => 'Family, marriage, work excellence, and Ummah';

  @override
  String get prayerSlot => 'Prayer Window';

  @override
  String get prayerSlotNone => 'Specific time only';

  @override
  String get slotEarlyMorning => 'Post-Fajr Barakah Hour';

  @override
  String get slotEarlyMorningDesc =>
      'Early morning golden hours for high focus';

  @override
  String get slotDuha => 'Mid-Morning (Duha)';

  @override
  String get slotDuhaDesc => 'Forenoon prime work and study block';

  @override
  String get slotDhuhr => 'Post-Dhuhr';

  @override
  String get slotDhuhrDesc => 'Early afternoon block following Dhuhr prayer';

  @override
  String get slotAsr => 'Post-Asr';

  @override
  String get slotAsrDesc =>
      'Late afternoon reflection or physical activity block';

  @override
  String get slotMaghrib => 'Between Maghrib & Isha';

  @override
  String get slotMaghribDesc => 'Family time, Quran reading, and light tasks';

  @override
  String get slotIsha => 'Post-Isha / Evening';

  @override
  String get slotIshaDesc => 'Night routine, reflection, and early sleep';

  @override
  String get focus => 'Focus Mode';

  @override
  String get focusTitle => 'Khushu\' Focus Session';

  @override
  String get focusSubtitle => 'Khushu\' Timer';

  @override
  String get focusNiyyahPrompt =>
      'Bismillah — Renew your intention for Allah before starting';

  @override
  String get focusDua =>
      'Rabbi zidni \'ilman (My Lord, increase me in knowledge)';

  @override
  String get focusStart => 'Start Focus';

  @override
  String get focusPause => 'Pause';

  @override
  String get focusResume => 'Resume';

  @override
  String get focusReset => 'Reset';

  @override
  String get focusComplete => 'Focus Session Complete! Alhamdulillah';

  @override
  String get focusCompleteMessage =>
      'May Allah put Barakah in your efforts and accept your work.';

  @override
  String focusTotalMinutes(int minutes) {
    return 'Total Focus: $minutes mins';
  }

  @override
  String get focusSelectTask => 'Select a task to focus on (optional)';

  @override
  String get focusPrayerWarningTitle => 'Prayer Approaching';

  @override
  String focusPrayerOverlap(String prayerName, int minutes) {
    return 'Next prayer ($prayerName) is in ${minutes}m. Your session will overlap with Salah.';
  }

  @override
  String focusPrayerSuggestion(int minutes, String prayerName) {
    return 'Set $minutes min session to finish before $prayerName';
  }

  @override
  String get focusMarkTaskComplete => 'Mark linked task as completed';

  @override
  String get focusTaskCompletedSuccess => 'Task completed! 🎉';

  @override
  String focusWindDownWarning(int minutes) {
    return 'Salah in ${minutes}m • Wind down your session';
  }

  @override
  String get focusPreset15 => '15 min (Sprint)';

  @override
  String get focusPreset25 => '25 min (Barakah block)';

  @override
  String get focusPreset45 => '45 min (Deep work)';

  @override
  String get focusPreset60 => '60 min (Mastery)';

  @override
  String get energyTitle => 'Daily Energy & Sunnah Routine';

  @override
  String get energySubtitle => 'Qaylulah & Battery';

  @override
  String get qaylulah => 'Sunnah Qaylulah';

  @override
  String get qaylulahDesc =>
      'A 20-min midday Sunnah power nap to recharge your afternoon';

  @override
  String get qaylulahStart => 'Start Qaylulah Nap';

  @override
  String get qaylulahWakingDua =>
      'Alhamdulillahil-ladhi ahyana ba\'da ma amatana wa ilayhin-nushur';

  @override
  String get sunnahFasting => 'Sunnah Fasting';

  @override
  String get sunnahFastingDesc =>
      'Mondays, Thursdays, and the White Days (13th, 14th, 15th)';

  @override
  String get sunnahFastingIntention => 'Fast for Allah today';

  @override
  String get energyPhysical => 'Physical Vitality';

  @override
  String get energySpiritual => 'Spiritual State';

  @override
  String get energyMental => 'Mental Focus';

  @override
  String get energySaved => 'Energy check-in updated';

  @override
  String get qualityDetailsAction => 'Practical Action';

  @override
  String get qualityDetailsContext => 'Islamic Foundation';

  @override
  String get adhkarTitle => 'Daily Adhkar & Remembrances';

  @override
  String get adhkarMorning => 'Morning Adhkar';

  @override
  String get adhkarEvening => 'Evening Adhkar';

  @override
  String get adhkarWaking => 'Waking Up Du\'as';

  @override
  String get adhkarSleeping => 'Bedtime Adhkar';

  @override
  String get adhkarPostPrayer => 'Post-Salah Adhkar';

  @override
  String get adhkarDailySunnah => 'Daily Sunnah Remembrances';

  @override
  String get adhkarTapToCount => 'Tap anywhere to count';

  @override
  String get adhkarCompleted => 'Completed! Alhamdulillah';

  @override
  String get adhkarCompletedMsg =>
      'May Allah accept your remembrance and fill your day with Barakah.';

  @override
  String get adhkarVirtue => 'Hadith & Spiritual Virtue';

  @override
  String get adhkarNext => 'Next Dhikr';

  @override
  String get adhkarPrev => 'Previous';

  @override
  String get adhkarReset => 'Reset Count';

  @override
  String get adhkarResetCategory => 'Reset Category';

  @override
  String get adhkarTypography => 'Arabic Calligraphy';

  @override
  String get typographyTitle => 'Arabic Typography & Calligraphy';

  @override
  String get typographyFontFamily => 'Calligraphy Script';

  @override
  String get typographyFontSize => 'Arabic Font Size';

  @override
  String get typographyPreview => 'Live Verse Preview';

  @override
  String get typographyTooltip => 'Customize Arabic calligraphy and font size';

  @override
  String get adhkarTransliteration => 'Transliteration';

  @override
  String get adhkarPillMorning => 'Morning Adhkar • Light & Protection';

  @override
  String get adhkarPillEvening => 'Evening Adhkar • Evening Shield';

  @override
  String get adhkarPillSleeping => 'Bedtime Adhkar • Guard your night';

  @override
  String get adhkarPillPostPrayer => 'Post-Salah Adhkar • 33x Tasbih';

  @override
  String adhkarProgress(int completed, int total) {
    return '$completed / $total completed';
  }

  @override
  String get adhkarEmptyState => 'No remembrances in this category yet.';

  @override
  String get adhkarActionRecite => 'Recite';

  @override
  String get adhkarActionReview => 'Review';

  @override
  String get adhkarPillTapPrompt => 'Tap to recite • 1-tap haptic counter';

  @override
  String get adhkarTabMorning => 'Morning';

  @override
  String get adhkarTabEvening => 'Evening';

  @override
  String get adhkarTabWaking => 'Waking';

  @override
  String get adhkarTabBedtime => 'Bedtime';

  @override
  String get adhkarTabPostSalah => 'Post-Salah';

  @override
  String get adhkarTabSunnah => 'Sunnah';

  @override
  String get adhkarTabGeneral => 'General';

  @override
  String get adhkarTabBookmarks => 'Bookmarks';

  @override
  String get adhkarBookmarksEmpty =>
      'No bookmarked adhkar yet. Tap the bookmark icon to save any remembrance.';

  @override
  String adhkarResumePrompt(int index) {
    return 'Resume from Dhikr $index';
  }

  @override
  String get adhkarCompletedToday => 'Completed today';

  @override
  String get adhkarToggleTransliteration => 'Toggle transliteration';

  @override
  String get adhkarBookmarkAdd => 'Bookmark dhikr';

  @override
  String get adhkarBookmarkRemove => 'Remove bookmark';

  @override
  String get smartNotificationsTitle => 'Smart Adhkar & Sunnah Reminders';

  @override
  String get smartNotificationsDesc =>
      'Dynamic reminders anchored to solar prayer times and Sunnah schedules.';

  @override
  String get settingMorningAdhkar => 'Morning Adhkar (Post-Fajr)';

  @override
  String get settingMorningAdhkarDesc =>
      'Timed 15 min after Fajr during your morning Barakah window.';

  @override
  String get settingEveningAdhkar => 'Evening Adhkar (Post-Asr)';

  @override
  String get settingEveningAdhkarDesc =>
      'Fortify your soul with evening remembrances before sunset.';

  @override
  String get settingBedtimeAdhkar => 'Bedtime Adhkar & Wind-down';

  @override
  String get settingBedtimeAdhkarDesc =>
      'Reminds you before sleep to recite Surat Al-Ikhlas, Falaq, Nas.';

  @override
  String get settingBedtimeTime => 'Target Bedtime';

  @override
  String get settingSunnahFasting => 'Sunnah Fasting Reminders';

  @override
  String get settingSunnahFastingDesc =>
      'Nudge on Sunday & Wednesday evenings to intend Mon/Thu fasting.';

  @override
  String get settingQaylulah => 'Sunnah Qaylulah Midday Nap';

  @override
  String get settingQaylulahDesc =>
      'Gentle reminder 30 min before Dhuhr for a 20-min recharge.';

  @override
  String get barakahAnalyticsTitle => 'Weekly Growth & Analytics';

  @override
  String get barakahAnalyticsConsistency => '7-Day Barakah Matrix';

  @override
  String get barakahAnalyticsEnergyTriad => 'Holistic Energy Triad';

  @override
  String get barakahAnalyticsSpiritual => 'Spiritual';

  @override
  String get barakahAnalyticsPhysical => 'Physical';

  @override
  String get barakahAnalyticsMental => 'Mental';

  @override
  String barakahAnalyticsActiveDays(int count) {
    return '$count / 7 Active Days';
  }

  @override
  String barakahAnalyticsTotalDhikr(int count) {
    return '$count Adhkar Completed';
  }

  @override
  String barakahAnalyticsFastingDays(int count) {
    return '$count Fasting Days';
  }

  @override
  String get barakahAnalyticsCoachingTitle => 'Spiritual Growth Insights';

  @override
  String get qiblaTitle => 'Qibla Compass';

  @override
  String get qiblaTabTimes => 'Prayer Times';

  @override
  String get qiblaTabCompass => 'Qibla Direction';

  @override
  String qiblaBearing(String degrees) {
    return '$degrees° from North';
  }

  @override
  String qiblaDistance(String distance) {
    return '$distance km to Kaaba, Makkah';
  }

  @override
  String get qiblaFacingKaaba => 'You are facing the Kaaba';

  @override
  String get qiblaDirectionLabel => 'Qibla Direction';

  @override
  String get qiblaDistanceLabel => 'Distance';

  @override
  String qiblaTurnRight(String degrees) {
    return 'Turn $degrees° Right';
  }

  @override
  String qiblaTurnLeft(String degrees) {
    return 'Turn $degrees° Left';
  }

  @override
  String get qiblaCalibrate =>
      'Calibrate Compass: Rotate device in a figure-8 motion away from metal interference.';

  @override
  String get solarDialTitle => 'Solar Prayer Arc';

  @override
  String solarCurrentWindow(String slot) {
    return 'Active Window: $slot';
  }

  @override
  String solarNext(String prayer) {
    return 'Next: $prayer';
  }

  @override
  String get slotTahajjud => 'Tahajjud / Pre-Fajr';

  @override
  String get slotNight => 'Night / Qiyam';

  @override
  String get widgetAppTitle => 'Productive Muslim';

  @override
  String get widgetNextPrayerLabel => 'Next Prayer';

  @override
  String widgetDhikrCount(int count) {
    return 'Dhikr: $count completed';
  }

  @override
  String get widgetBtnPrayers => 'Prayers';

  @override
  String get widgetBtnAdhkar => 'Adhkar';

  @override
  String get widgetBtnFocus => 'Focus';

  @override
  String get widgetBtnPlusOne => '+1';

  @override
  String get hijriCalendarTitle => 'Hijri Calendar & Fasting';

  @override
  String hijriToday(String date) {
    return 'Today: $date';
  }

  @override
  String get whiteDaysLabel => 'White Days (Ayyam al-Beed)';

  @override
  String get whiteDaysDesc => '13th, 14th & 15th of the lunar month';

  @override
  String get mondayThursdaySunnah => 'Monday & Thursday Sunnah';

  @override
  String fastingCountdownSuhoor(String time) {
    return 'Suhoor ends in $time';
  }

  @override
  String fastingCountdownIftar(String time) {
    return 'Iftar in $time';
  }

  @override
  String get fastingTodayActive => 'Fasting Today';

  @override
  String get fastingTodayInactive => 'Not Fasting Today';

  @override
  String get fastingIntendAction => 'Intend to Fast';

  @override
  String get fastingLoggedSuccess => 'Fasting record updated';

  @override
  String get iftarDuaTitle => 'Sunnah Iftar Du\'a';

  @override
  String get iftarDuaArabic =>
      'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ';

  @override
  String get iftarDuaTransliteration =>
      'Dhahaba adh-dhama\'u wabtallatil-\'urooqu wa thabatal-ajru in sha Allah';

  @override
  String get iftarDuaTranslation =>
      'The thirst has gone, the veins are moistened, and the reward is confirmed, if Allah wills.';

  @override
  String fastingStreak(int count) {
    return '$count days fasted';
  }

  @override
  String get fastingVirtueTitle => 'Virtue of Fasting';

  @override
  String get fastingVirtueDesc =>
      'Fasting 3 days each month is like fasting the entire year (Bukhari & Muslim).';

  @override
  String get fastingGuidelinesTitle => 'Sunnah Fasting Guidelines';

  @override
  String get suhoorSunnahTitle => 'Do Not Skip Suhoor';

  @override
  String get suhoorSunnahDesc =>
      'The Prophet (ﷺ) said: \"Take Suhoor, for in Suhoor there is Barakah (blessing).\" (Bukhari)';

  @override
  String get hydrationTitle => 'Optimal Hydration';

  @override
  String get hydrationDesc =>
      'Drink ample water between Iftar and Suhoor to maintain high energy and mental focus.';

  @override
  String get breakPromptTitle => 'Hasten to Break the Fast';

  @override
  String get breakPromptDesc =>
      'Break your fast promptly at Maghrib with dates and water, following the Sunnah.';

  @override
  String get whiteDayBadge => 'White Day';

  @override
  String get prevMonthTooltip => 'Previous Month';

  @override
  String get nextMonthTooltip => 'Next Month';

  @override
  String get todayTooltip => 'Today';

  @override
  String get suhoorWindow => 'Suhoor Window';

  @override
  String get fastInProgress => 'Fast in Progress';

  @override
  String get iftarCompleted => 'Iftar Completed';

  @override
  String get sunnahBadge => 'Sunnah';

  @override
  String get copyDuaTooltip => 'Copy Du\'a';

  @override
  String get duaCopiedMessage => 'Du\'a copied to clipboard';

  @override
  String get iftarHadithRef => 'Sunan Abi Dawud (2357) — Sahih';

  @override
  String get heatmapTitle => '12-Week Consistency Heatmap';

  @override
  String get heatmapSubtitle => 'Daily Barakah & habit momentum';

  @override
  String get heatmapLess => 'Less';

  @override
  String get heatmapMore => 'More';

  @override
  String heatmapActiveDays(int count, int total) {
    return '$count of $total active days';
  }

  @override
  String heatmapScoreLabel(int count) {
    return 'Activity score: $count';
  }

  @override
  String get backupRestoreTitle => 'Data Sovereignty & Local Backup';

  @override
  String get backupRestoreDesc =>
      'Export or restore your tasks, habits, and reflections safely on device.';

  @override
  String get backupExportBtn => 'Export Backup (JSON)';

  @override
  String get backupImportBtn => 'Restore from JSON';

  @override
  String get backupExportSuccess => 'Backup JSON copied to clipboard!';

  @override
  String get backupExportError => 'Failed to export backup. Please try again.';

  @override
  String get backupImportSuccess => 'Data successfully restored!';

  @override
  String get backupImportError =>
      'Invalid backup JSON payload. Please check and try again.';

  @override
  String get backupConfirmTitle => 'Restore Data';

  @override
  String get backupConfirmMsg =>
      'Restoring will replace all current local data with the backup contents. Are you sure you want to proceed?';

  @override
  String get backupRestorePasteHint =>
      'Paste your exported JSON backup text here...';

  @override
  String get backupCancel => 'Cancel';

  @override
  String get backupConfirm => 'Restore Now';

  @override
  String get preferencesTitle => 'Preferences & Touch';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackDesc =>
      'Vibration feedback on taps, counters, and completions';

  @override
  String get languageDesc => 'Change app display language';

  @override
  String get languageSystem => 'System Default';

  @override
  String get languageEn => 'English';

  @override
  String get languageAr => 'العربية (Arabic)';

  @override
  String get plan => 'Plan';

  @override
  String get quickToolkit => 'Spiritual Toolkit';

  @override
  String get allTools => 'Quick Access';

  @override
  String get fastingSubtitle => 'Sunnah Days';

  @override
  String get adhkarSubtitle => 'Daily Remembrances';

  @override
  String get timeAwareMorningTitle => 'Morning Barakah Window';

  @override
  String get timeAwareMorningDesc =>
      'Start with morning adhkar & set your daily intention.';

  @override
  String get timeAwareMiddayTitle => 'Midday Qaylulah & Focus';

  @override
  String get timeAwareMiddayDesc =>
      'Recharge with a 20-min Sunnah nap or start deep work.';

  @override
  String get timeAwareEveningTitle => 'Evening Adhkar & Wind-down';

  @override
  String get timeAwareEveningDesc =>
      'Recite your evening protections and review today\'s progress.';

  @override
  String get timeAwareNightTitle => 'Night Reflection & Muhasabah';

  @override
  String get timeAwareNightDesc =>
      'Record your gratitude (Shukr) and recite bedtime adhkar.';

  @override
  String get startNow => 'Open';

  @override
  String get fastingTitle => 'Fasting & Hijri';

  @override
  String get energy => 'Energy & Routines';

  @override
  String get profile => 'Profile';

  @override
  String get profileSubtitle => 'Personal Sovereignty & Account';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get displayName => 'Display Name';

  @override
  String get enterNameHint => 'Enter your name or seeker title';

  @override
  String get spiritualMotto => 'Sacred Intention / Daily Motto';

  @override
  String get enterMottoHint => 'e.g. Seeking Allah\'s pleasure through Ihsan';

  @override
  String get chooseAvatar => 'Choose Avatar Symbol';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get spiritualRank => 'Spiritual Rank';

  @override
  String get nextRankProgress => 'Progress to next rank';

  @override
  String get lifetimeMomentum => 'Lifetime Momentum';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String bestStreak(int days) {
    return 'Best: ${days}d';
  }

  @override
  String get habitsCompleted => 'Habits Built';

  @override
  String get tasksAccomplished => 'Tasks Done';

  @override
  String get focusHours => 'Focus Hours';

  @override
  String get spiritualMilestones => 'Consistency Milestones';

  @override
  String get milestoneUnlocked => 'Unlocked';

  @override
  String get milestoneLocked => 'Locked';

  @override
  String get qualitiesCoaching => '9 Qualities Coaching';

  @override
  String get topStrength => 'Core Strength';

  @override
  String get growthFocus => 'Growth Focus';

  @override
  String get dataSovereignty => 'Data & Sovereignty';

  @override
  String get exportBackup => 'Export JSON Backup';

  @override
  String get restoreBackup => 'Restore from Backup';

  @override
  String get shareUmmah => 'Share Productive Muslim';

  @override
  String get offlinePrivacyNotice =>
      '100% Offline & Private — Your deeds remain between you and Allah.';

  @override
  String get badgeFajrVanguard => 'Fajr Vanguard';

  @override
  String get badgeFajrVanguardDesc =>
      'Maintained a 7-day Fajr prayer & morning adhkar streak.';

  @override
  String get badgeIstiqamahMaster => 'Istiqamah Master';

  @override
  String get badgeIstiqamahMasterDesc =>
      'Achieved a 21-day continuous habit momentum.';

  @override
  String get badgeWhiteDaysGuardian => 'White Days Guardian';

  @override
  String get badgeWhiteDaysGuardianDesc =>
      'Fasted the sacred White Days (Ayyam al-Beed).';

  @override
  String get badgeDhikrAbundance => 'Dhikr Abundance';

  @override
  String get badgeDhikrAbundanceDesc =>
      'Reached 1,000+ total tasbeeh repetitions.';

  @override
  String get badgeNiyyahPurity => 'Niyyah Purity';

  @override
  String get badgeNiyyahPurityDesc =>
      'Recorded pure intentions for 14 consecutive days.';

  @override
  String get badgeMuhasabahDevotee => 'Muhasabah Devotee';

  @override
  String get badgeMuhasabahDevoteeDesc =>
      'Completed 4 consecutive weekly spiritual self-audits.';

  @override
  String get barakahReflectiveHeaderTitle => 'Barakah & Reflection';

  @override
  String get barakahReflectiveSubtitle =>
      'Mindful intention, sincere action, and gratitude.';

  @override
  String get barakahActivityRecordDisclaimer =>
      'Activity counts describe self-reported app usage, not a measure of divine blessing, faith, or sincerity.';

  @override
  String get todayRecordedActivity => 'Today\'s Recorded Activity';

  @override
  String habitsLoggedCount(int count) {
    return '$count habits kept';
  }

  @override
  String focusMinutesLoggedCount(int count) {
    return '$count focus mins';
  }

  @override
  String reflectionsLoggedCount(int count) {
    return '$count reflections';
  }

  @override
  String get reflectionCompleted => 'Reflection saved';

  @override
  String get reflectionPending => 'Reflection pending';

  @override
  String get muhasabahHeaderTitle => 'Evening Muhasabah';

  @override
  String get muhasabahHeaderQuote =>
      'Take account of yourselves before you are taken to account, and weigh your deeds before they are weighed.';

  @override
  String get muhasabahPromptsTitle => 'Thoughtful Prompts';

  @override
  String get muhasabahPromptFree => 'Free Reflection';

  @override
  String get muhasabahPromptGratitude =>
      'What blessing did you receive today that you are grateful for?';

  @override
  String get muhasabahPromptPatience =>
      'Where did you face difficulty today, and how did you seek Allah\'s help?';

  @override
  String get muhasabahPromptForgiveness =>
      'What shortcoming can you ask forgiveness (Istighfar) for tonight?';

  @override
  String get muhasabahPromptIhsan =>
      'How did you strive for excellence (Ihsan) in your work or dealings?';

  @override
  String get muhasabahPromptIntention =>
      'What intention do you renew for tomorrow?';

  @override
  String get muhasabahSaveAction => 'Save Reflection';

  @override
  String get muhasabahInputHint =>
      'Jot down your reflections, gratitude, or lessons learned...';

  @override
  String get muhasabahSavedToday => 'Today\'s Reflections';

  @override
  String get muhasabahEmptyMessage =>
      'Take a quiet moment to reflect whenever you are ready. No scores, no streaks.';

  @override
  String get muhasabahDeleteConfirmTitle => 'Delete Reflection?';

  @override
  String get muhasabahDeleteConfirmMessage =>
      'Are you sure you want to remove this reflection entry?';

  @override
  String get muhasabahReflectionSavedToast => 'Reflection saved quietly.';
}
