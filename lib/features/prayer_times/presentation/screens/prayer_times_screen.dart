import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_bloc.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_event.dart';
import 'package:productive_muslim/features/prayer_times/logic/prayer_times_state.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasParentScaffold = Scaffold.maybeOf(context) != null;

    return BlocProvider(
      create: (_) =>
          PrayerTimesBloc(getIt<PrayerTimeService>())
            ..add(const PrayerTimesLoaded()),
      child: Scaffold(
        appBar: hasParentScaffold
            ? null
            : AppBar(title: Text(l10n.prayerTimes)),
        body: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
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
                _PrayerTimesList(
                  prayerTimes: prayerTimes,
                  nextPrayer: nextPrayer,
                  locationName: locationName,
                ),
              PrayerTimesLocationRequired() => _LocationRequired(l10n: l10n),
              PrayerTimesError(:final message) => _ErrorState(message: message),
            };
          },
        ),
      ),
    );
  }
}

class _PrayerTimesList extends StatelessWidget {
  final dynamic prayerTimes;
  final String nextPrayer;
  final String? locationName;

  const _PrayerTimesList({
    required this.prayerTimes,
    required this.nextPrayer,
    this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat.jm();

    final entries = [
      ('Fajr', l10n.fajr, prayerTimes.fajr as DateTime),
      ('Sunrise', l10n.sunrise, prayerTimes.sunrise as DateTime),
      ('Dhuhr', l10n.dhuhr, prayerTimes.dhuhr as DateTime),
      ('Asr', l10n.asr, prayerTimes.asr as DateTime),
      ('Maghrib', l10n.maghrib, prayerTimes.maghrib as DateTime),
      ('Isha', l10n.isha, prayerTimes.isha as DateTime),
    ];

    final hasLocation = locationName != null && locationName!.isNotEmpty;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: entries.length + (hasLocation ? 1 : 0),
      itemBuilder: (context, index) {
        if (hasLocation && index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  locationName!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final entryIndex = hasLocation ? index - 1 : index;
        final (key, name, time) = entries[entryIndex];
        final isNext = key.toLowerCase() == nextPrayer.toLowerCase();

        return _PrayerTile(
          name: name,
          time: timeFormat.format(time),
          isNext: isNext,
        );
      },
    );
  }
}

class _PrayerTile extends StatelessWidget {
  final String name;
  final String time;
  final bool isNext;

  const _PrayerTile({
    required this.name,
    required this.time,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        borderRadius: 20,
        blur: 15,
        color: isNext
            ? (isDark
                  ? AppColors.primaryLight.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.12))
            : (isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.7)),
        borderColor: isNext
            ? (isDark ? AppColors.primaryLight : AppColors.primary)
            : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isNext
                    ? AppColors.secondary.withValues(alpha: 0.2)
                    : (isDark
                          ? AppColors.darkSurfaceSubtle
                          : AppColors.surfaceSubtle),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time_rounded,
                size: 18,
                color: isNext
                    ? AppColors.secondary
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                  color: isNext
                      ? (isDark ? AppColors.primaryLight : AppColors.primary)
                      : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary),
                ),
              ),
            ),
            if (isNext)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ),
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                color: isNext
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationRequired extends StatelessWidget {
  final AppLocalizations l10n;
  const _LocationRequired({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.onboardingPermissionDeniedBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
