import 'package:bloc/bloc.dart';

import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_event.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_state.dart';

class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  final PrayerTimeService _service;

  PrayerTimesBloc(this._service) : super(const PrayerTimesInitial()) {
    on<PrayerTimesLoaded>(_onLoaded);
  }

  Future<void> _onLoaded(
    PrayerTimesLoaded event,
    Emitter<PrayerTimesState> emit,
  ) async {
    emit(const PrayerTimesLoading());

    final position = await _service.getCurrentPosition();
    if (position == null) {
      emit(const PrayerTimesLocationRequired());
      return;
    }

    final prayerTimes = _service.getPrayerTimes(position);
    if (prayerTimes == null) {
      emit(const PrayerTimesError('Could not calculate prayer times'));
      return;
    }

    final nextPrayer = _service.getNextPrayerName(prayerTimes) ?? '--';
    final timeUntil = _service.getTimeUntilNextPrayer(prayerTimes);
    final locationName = _service.getLocationName(position);

    emit(
      PrayerTimesData(
        prayerTimes: prayerTimes,
        nextPrayer: nextPrayer,
        timeUntilNextPrayer: timeUntil ?? Duration.zero,
        locationName: locationName,
      ),
    );
  }
}
