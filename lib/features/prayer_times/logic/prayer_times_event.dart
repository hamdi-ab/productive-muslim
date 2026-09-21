sealed class PrayerTimesEvent {
  const PrayerTimesEvent();

  factory PrayerTimesEvent.loaded() = PrayerTimesLoaded;
}

class PrayerTimesLoaded extends PrayerTimesEvent {
  const PrayerTimesLoaded();
}
