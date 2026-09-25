import 'package:adhan_dart/adhan_dart.dart';

sealed class PrayerTimesState {
  const PrayerTimesState();

  const factory PrayerTimesState.initial() = PrayerTimesInitial;
  const factory PrayerTimesState.loading() = PrayerTimesLoading;
  const factory PrayerTimesState.loaded({
    required PrayerTimes prayerTimes,
    required String nextPrayer,
    required Duration timeUntilNextPrayer,
    String? locationName,
  }) = PrayerTimesData;
  const factory PrayerTimesState.locationRequired() =
      PrayerTimesLocationRequired;
  const factory PrayerTimesState.error(String message) = PrayerTimesError;
}

class PrayerTimesInitial extends PrayerTimesState {
  const PrayerTimesInitial();
}

class PrayerTimesLoading extends PrayerTimesState {
  const PrayerTimesLoading();
}

class PrayerTimesData extends PrayerTimesState {
  final PrayerTimes prayerTimes;
  final String nextPrayer;
  final Duration timeUntilNextPrayer;
  final String? locationName;

  const PrayerTimesData({
    required this.prayerTimes,
    required this.nextPrayer,
    required this.timeUntilNextPrayer,
    this.locationName,
  });
}

class PrayerTimesLocationRequired extends PrayerTimesState {
  const PrayerTimesLocationRequired();
}

class PrayerTimesError extends PrayerTimesState {
  final String message;
  const PrayerTimesError(this.message);
}
