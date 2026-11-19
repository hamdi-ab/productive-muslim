/// Centralized route paths and deep link identifiers for Productive Muslim.
abstract final class AppRoutes {
  // Primary Bottom Navigation Shell Tabs (Five Pillars)
  static const home = '/';
  static const adhkar = '/adhkar';
  static const myDay = '/my-day';
  static const prayerTimes = '/prayer-times';
  static const reflect = '/reflect';

  // Subpages & Root Detail Screens (no bottom bar)
  static const onboarding = '/onboarding';
  static const settings = '/settings';
  static const profile = '/profile';
  static const focus = '/focus';
  static const energy = '/energy';
  static const fasting = '/fasting';
  static const barakahReview = '/barakah/review';
  static const adhkarExplore = '/adhkar/explore';

  // My Day sub-destinations / nested paths
  static const myDayTasks = '/my-day/tasks';
  static const myDayHabits = '/my-day/habits';
  static const myDayFocus = '/my-day/focus';

  // Reflect sub-destinations / nested paths
  static const reflectMuhasabah = '/reflect/muhasabah';
  static const reflectBarakah = '/reflect/barakah';

  // Aliases & Legacy Paths (preserved for notification payloads & deep links)
  static const plan = '/plan';
  static const tasks = '/tasks';
  static const habits = '/habits';
  static const journal = '/journal';
  static const barakah = '/barakah';
  static const intentions = '/intentions';
  static const prayerTimesUnderscore = '/prayer_times';
  static const streak = '/streak';
}
