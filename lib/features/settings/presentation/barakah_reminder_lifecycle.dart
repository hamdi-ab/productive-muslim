import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:productive_muslim/data/services/barakah_reminder_service.dart';
import 'package:productive_muslim/domain/models/barakah_reminder.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class BarakahReminderLifecycle extends StatefulWidget {
  const BarakahReminderLifecycle({
    super.key,
    required this.service,
    required this.child,
  });

  final BarakahReminderService service;
  final Widget child;

  @override
  State<BarakahReminderLifecycle> createState() =>
      _BarakahReminderLifecycleState();
}

class _BarakahReminderLifecycleState extends State<BarakahReminderLifecycle>
    with WidgetsBindingObserver {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_locale != locale) {
      _locale = locale;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reconcile();
      });
    }
  }

  void _reconcile() {
    final l10n = AppLocalizations.of(context)!;
    unawaited(
      widget.service.reconcile(
        ReminderContent(
          title: l10n.barakahDailyTitle,
          body: l10n.barakahReminderBody,
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reconcile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
