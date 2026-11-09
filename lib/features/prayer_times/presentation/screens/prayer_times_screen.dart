import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_bloc.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_event.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_state.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/prayer_error_view.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/prayer_location_required_view.dart';
import 'package:productive_muslim/features/prayer_times/presentation/widgets/prayer_times_tabs.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Screen displaying high-precision daily prayer timetable, celestial solar dial,
/// and interactive Qibla compass with ambient sacred aesthetic.
class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasParentScaffold = Scaffold.maybeOf(context) != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) =>
          PrayerTimesBloc(getIt<PrayerTimeService>())
            ..add(const PrayerTimesLoaded()),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1512) : null,
        appBar: hasParentScaffold
            ? null
            : ProductiveAppBar(title: l10n.prayerTimes, showBackButton: true),
        body: Stack(
          children: [
            // Ambient Sacred Glow Backdrops matching Stitch Design
            Positioned(
              top: -80,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondary.withValues(
                          alpha: isDark ? 0.12 : 0.08,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: -60,
              child: IgnorePointer(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(
                          alpha: isDark ? 0.14 : 0.08,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
              builder: (context, state) {
                return switch (state) {
                  PrayerTimesInitial() || PrayerTimesLoading() => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  PrayerTimesData(
                    :final prayerTimes,
                    :final nextPrayer,
                    :final locationName,
                  ) =>
                    PrayerTimesTabs(
                      prayerTimes: prayerTimes,
                      nextPrayer: nextPrayer,
                      locationName: locationName,
                    ),
                  PrayerTimesLocationRequired() => PrayerLocationRequiredView(
                    l10n: l10n,
                  ),
                  PrayerTimesError(:final message) => PrayerErrorView(
                    message: message,
                  ),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}
