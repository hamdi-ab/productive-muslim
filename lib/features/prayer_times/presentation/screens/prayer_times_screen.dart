import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
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

    return BlocProvider(
      create: (_) =>
          PrayerTimesBloc(getIt<PrayerTimeService>())
            ..add(const PrayerTimesLoaded()),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.prayerTimes)),
        body: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
          builder: (context, state) {
            return switch (state) {
              PrayerTimesInitial() || PrayerTimesLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              PrayerTimesData(:final prayerTimes, :final nextPrayer) =>
                _PrayerTimesList(
                  prayerTimes: prayerTimes,
                  nextPrayer: nextPrayer,
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

  const _PrayerTimesList({required this.prayerTimes, required this.nextPrayer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeFormat = DateFormat.jm();

    final entries = [
      (l10n.fajr, prayerTimes.fajr as DateTime),
      (l10n.sunrise, prayerTimes.sunrise as DateTime),
      (l10n.dhuhr, prayerTimes.dhuhr as DateTime),
      (l10n.asr, prayerTimes.asr as DateTime),
      (l10n.maghrib, prayerTimes.maghrib as DateTime),
      (l10n.isha, prayerTimes.isha as DateTime),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final (name, time) = entries[index];
        final isNext = name.toLowerCase() == nextPrayer.toLowerCase();

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
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.primary.withValues(alpha: 0.08)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isNext
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          if (isNext)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isNext ? FontWeight.w600 : FontWeight.normal,
                color: isNext ? AppColors.primary : null,
              ),
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
              color: isNext ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
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
