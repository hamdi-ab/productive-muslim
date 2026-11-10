import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/domain/models/barakah_reminder.dart';
import 'package:productive_muslim/features/settings/logic/settings_bloc.dart';
import 'package:productive_muslim/features/settings/logic/settings_event.dart';
import 'package:productive_muslim/features/settings/logic/settings_state.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Card configuring daily evening Barakah prompt time and activation state.
class SettingsBarakahReminderCard extends StatelessWidget {
  final SettingsState state;
  final ReminderContent content;

  const SettingsBarakahReminderCard({
    super.key,
    required this.state,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final interactive = state.supported && !state.pending;
    final time = TimeOfDay(hour: state.hour, minute: state.minute);
    final cardBorder = isDark
        ? const Color(0x2610B981)
        : const Color(0x1A0F4C3A);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    final message = switch (state.failure) {
      ReminderFailure.permissionDenied => l10n.barakahReminderDenied,
      ReminderFailure.operationFailed => l10n.barakahReminderError,
      ReminderFailure.unavailable => l10n.barakahReminderUnsupported,
      null => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          color: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: cardBorder, width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                SwitchListTile(
                  key: const Key('barakah_reminder_toggle'),
                  activeThumbColor: AppColors.secondary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    l10n.barakahReminderLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    l10n.barakahReminderDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  value: state.enabled,
                  onChanged: interactive
                      ? (enabled) => context.read<SettingsBloc>().add(
                          ReminderToggled(enabled, content),
                        )
                      : null,
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 16,
                  color: dividerColor,
                ),
                ListTile(
                  key: const Key('barakah_reminder_time'),
                  contentPadding: const EdgeInsets.only(left: 56, right: 16),
                  title: Text(
                    l10n.barakahReminderTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    time.format(context),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              time.format(context),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  enabled: interactive,
                  onTap: interactive
                      ? () async {
                          final bloc = context.read<SettingsBloc>();
                          final selected = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (selected != null && !bloc.isClosed) {
                            bloc.add(
                              ReminderTimeChanged(
                                selected.hour,
                                selected.minute,
                                content,
                              ),
                            );
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
        if (!state.supported)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(l10n.barakahReminderUnsupported),
          )
        else if (state.pending)
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(l10n.barakahReminderPending),
            ),
          )
        else if (message != null)
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(message),
            ),
          ),
      ],
    );
  }
}
