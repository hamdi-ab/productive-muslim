import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/data/services/adhkar_service.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/data/services/settings_service.dart';

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockPrayerTimeService mockPrayerService;
  late SettingsService settingsService;
  late AdhkarService adhkarService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    mockPrayerService = MockPrayerTimeService();
    settingsService = SettingsService(prefs: prefs);
    adhkarService = AdhkarService(
      prayerTimeService: mockPrayerService,
      settingsService: settingsService,
    );
  });

  group('AdhkarService Context & Solar Window Triggers', () {
    test('returns morning category during morning hours', () {
      final now = DateTime(2026, 9, 28, 6, 0); // 06:00 AM
      final date = DateTime(2026, 9, 28);
      final pt = PrayerTimes(
        date: date,
        coordinates: Coordinates(21.4225, 39.8262),
        calculationParameters: CalculationMethodParameters.muslimWorldLeague(),
      );

      final category = adhkarService.getCurrentContextCategory(
        now: now,
        prayerTimes: pt,
      );

      expect(category, DhikrCategory.morning);
    });

    test('returns evening category during evening hours', () {
      final date = DateTime(2026, 9, 28);
      final pt = PrayerTimes(
        date: date,
        coordinates: Coordinates(21.4225, 39.8262),
        calculationParameters: CalculationMethodParameters.muslimWorldLeague(),
      );

      // Asr to Maghrib window
      final asrTime = pt.asr.toLocal();
      final now = asrTime.add(const Duration(minutes: 30));

      final category = adhkarService.getCurrentContextCategory(
        now: now,
        prayerTimes: pt,
      );

      expect(category, DhikrCategory.evening);
    });

    test('returns sleeping category at night post-Isha', () {
      final date = DateTime(2026, 9, 28);
      final pt = PrayerTimes(
        date: date,
        coordinates: Coordinates(21.4225, 39.8262),
        calculationParameters: CalculationMethodParameters.muslimWorldLeague(),
      );

      final ishaTime = pt.isha.toLocal();
      final now = ishaTime.add(const Duration(minutes: 45));

      final category = adhkarService.getCurrentContextCategory(
        now: now,
        prayerTimes: pt,
      );

      expect(category, DhikrCategory.sleeping);
    });

    test('records completed dhikr session and counts for today', () async {
      await adhkarService.recordDhikrCompletion(
        dhikrId: 'ayat_al_kursi',
        date: '2026-09-28',
      );

      final completedIds = adhkarService.getCompletedDhikrIdsForDate(
        '2026-09-28',
      );
      expect(completedIds, contains('ayat_al_kursi'));
      expect(
        adhkarService.isDhikrCompleted('ayat_al_kursi', date: '2026-09-28'),
        true,
      );
    });
  });
}
