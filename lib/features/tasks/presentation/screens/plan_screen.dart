import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/domain/repositories/habit_repository.dart';
import 'package:productive_muslim/domain/repositories/task_repository.dart';
import 'package:productive_muslim/features/habits/logic/habit_bloc.dart';
import 'package:productive_muslim/features/habits/logic/habit_event.dart';
import 'package:productive_muslim/features/habits/presentation/screens/create_habit_sheet.dart';
import 'package:productive_muslim/features/habits/presentation/screens/habit_screen.dart';
import 'package:productive_muslim/features/tasks/logic/task_bloc.dart';
import 'package:productive_muslim/features/tasks/logic/task_event.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/create_task_sheet.dart';
import 'package:productive_muslim/features/tasks/presentation/screens/task_screen.dart';
import 'package:productive_muslim/features/tasks/presentation/widgets/plan_atmosphere_background.dart';
import 'package:productive_muslim/features/tasks/presentation/widgets/plan_barakah_alignment_meter.dart';
import 'package:productive_muslim/features/tasks/presentation/widgets/plan_date_navigator.dart';
import 'package:productive_muslim/features/tasks/presentation/widgets/plan_spiritual_anchor_banner.dart';
import 'package:productive_muslim/features/tasks/presentation/widgets/plan_tab_switcher.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

enum PlanTab { tasks, habits }

/// Screen orchestrating the daily planning experience with spiritual alignment, date navigation,
/// and quick switching between actionable Tasks and ongoing Habits.
class PlanScreen extends StatefulWidget {
  final PlanTab initialTab;

  const PlanScreen({super.key, this.initialTab = PlanTab.tasks});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late PlanTab _selectedTab;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  void _onTabChanged(PlanTab tab) {
    if (_selectedTab == tab) return;
    AppHaptics.selectionClick();
    setState(() => _selectedTab = tab);
  }

  void _changeDate(int days) {
    AppHaptics.selectionClick();
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  void _goToToday() {
    AppHaptics.selectionClick();
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    AppHaptics.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF141E1A) : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      AppHaptics.selectionClick();
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showCreateTaskSheet(BuildContext context) {
    AppHaptics.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (ctx) =>
            TaskBloc(ctx.read<TaskRepository>())
              ..add(TaskLoaded(_formattedDate)),
        child: CreateTaskSheet(
          date: _formattedDate,
          onSwitchToHabit: () {
            Navigator.pop(context);
            _showCreateHabitSheet(context);
          },
        ),
      ),
    );
  }

  void _showCreateHabitSheet(BuildContext context) {
    AppHaptics.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (ctx) =>
            HabitBloc(ctx.read<HabitRepository>())..add(const HabitLoaded()),
        child: CreateHabitSheet(
          onSwitchToTask: () {
            Navigator.pop(context);
            _showCreateTaskSheet(context);
          },
        ),
      ),
    );
  }

  void _showCreateAction(BuildContext context) {
    if (_selectedTab == PlanTab.tasks) {
      _showCreateTaskSheet(context);
    } else {
      _showCreateHabitSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1512) : null,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE9C349), Color(0xFFFFD54F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE9C349).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            AppHaptics.lightImpact();
            _showCreateAction(context);
          },
          elevation: 0,
          highlightElevation: 0,
          backgroundColor: Colors.transparent,
          icon: const Icon(Icons.add_rounded, color: Color(0xFF241A00)),
          label: Text(
            _selectedTab == PlanTab.tasks ? l10n.newTask : l10n.newHabit,
            style: const TextStyle(
              color: Color(0xFF241A00),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background atmospheric sacred geometry & ambient glows
          PlanAtmosphereBackground(isDark: isDark),

          // Main Planning View
          Column(
            children: [
              // 1. Date Switcher Navigator
              PlanDateNavigator(
                selectedDate: _selectedDate,
                isDark: isDark,
                onDateOffsetChanged: _changeDate,
                onGoToToday: _goToToday,
                onPickDate: () => _pickDate(context),
              ),

              // 2. Spiritual Anchor Banner (Bismillah & Niyyah Renewal)
              PlanSpiritualAnchorBanner(isDark: isDark),

              // 3. Barakah Alignment Progress Meter
              PlanBarakahAlignmentMeter(
                formattedDate: _formattedDate,
                isDark: isDark,
              ),

              // 4. Segmented Capsule Switcher [Tasks | Habits]
              PlanTabSwitcher(
                selectedTab: _selectedTab,
                onTabChanged: _onTabChanged,
                isDark: isDark,
              ),

              // 5. Active Tab Content View
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _selectedTab == PlanTab.tasks
                      ? TaskScreen(
                          key: ValueKey('plan_task_view_$_formattedDate'),
                          date: _formattedDate,
                        )
                      : const HabitScreen(key: ValueKey('plan_habit_view')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
