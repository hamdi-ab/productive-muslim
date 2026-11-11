import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/domain/models/habit.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/features/habits/presentation/screens/istiqamah_streak_sheet.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late MockHabitRepository mockHabitRepo;

  setUp(() {
    mockHabitRepo = MockHabitRepository();
    if (getIt.isRegistered<HabitRepository>()) {
      getIt.unregister<HabitRepository>();
    }
    getIt.registerSingleton<HabitRepository>(mockHabitRepo);

    when(() => mockHabitRepo.watchOverallStreak())
        .thenAnswer((_) => Stream.value(5));
    when(() => mockHabitRepo.getLongestStreak()).thenAnswer((_) async => 12);
    when(
      () => mockHabitRepo.watchCompletionsCountByDate(days: any(named: 'days')),
    ).thenAnswer((_) => Stream.value({'2026-11-10': 3}));
    when(() => mockHabitRepo.watchActiveHabits()).thenAnswer(
      (_) => Stream.value([
        Habit(id: 1, name: 'Fajr on time', category: 'islam', createdAt: 0),
        Habit(id: 2, name: 'Morning Adhkar', category: 'islam', createdAt: 0),
      ]),
    );
    when(() => mockHabitRepo.watchCompletionsForDate(any()))
        .thenAnswer((_) => Stream.value({1: true, 2: false}));
  });

  tearDown(() {
    if (getIt.isRegistered<HabitRepository>()) {
      getIt.unregister<HabitRepository>();
    }
  });

  Widget createWidget({Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: IstiqamahStreakSheet()),
    );
  }

  testWidgets('renders all core streak sheet sections in English', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Bismillah / Sacred Consistency Pill
    expect(find.text('SACRED CONSISTENCY (ISTIQAMAH)'), findsOneWidget);

    // Hero Streak Count
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Days Streak'), findsOneWidget);

    // Metrics
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Best Streak'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);

    // Weekly Track Card
    expect(find.text('Current Week Track'), findsOneWidget);

    // Prophetic Hadith
    expect(
      find.text(
        '“The most beloved deeds to Allah are those done regularly, even if small.”',
      ),
      findsOneWidget,
    );

    // Milestone Ladder
    expect(find.text('Istiqamah Milestone Ladder'), findsOneWidget);
    expect(find.text('Bidayah (Spark of Intention)'), findsOneWidget);
    expect(find.text('Thabat (First Solid Week)'), findsOneWidget);

    // CTA
    expect(find.text('View Daily Habits'), findsOneWidget);
  });

  testWidgets('renders properly in Arabic with Arabic digits', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createWidget(locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('مَنْهَجُ الِاسْتِقَامَةِ'), findsOneWidget);
    expect(find.text('٥'), findsOneWidget);
    expect(find.text('يوم استقامة'), findsOneWidget);
    expect(find.text('الاستمرارية'), findsOneWidget);
    expect(find.text('أعلى رقم'), findsOneWidget);
    expect(find.text('عادات اليوم'), findsOneWidget);
    expect(find.text('مسار الأسبوع الحالي'), findsOneWidget);
    expect(find.text('مراتب ومحطات الاستقامة'), findsOneWidget);
    expect(find.text('الذهاب إلى قائمة العادات اليومية'), findsOneWidget);
  });
}
