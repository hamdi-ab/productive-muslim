import 'package:flutter/material.dart';

import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/features/barakah/presentation/screens/barakah_screen.dart';
import 'package:productive_muslim/features/reflect/presentation/widgets/muhasabah_view.dart';
import 'package:productive_muslim/features/reflect/presentation/widgets/reflect_tab_switcher.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

export 'package:productive_muslim/features/reflect/presentation/widgets/reflect_tab_switcher.dart';

/// Primary reflection hub combining evening Muhasabah (intentions & self-audit)
/// and Barakah & Growth into a unified experience.
class ReflectScreen extends StatefulWidget {
  final ReflectTab initialTab;

  const ReflectScreen({super.key, this.initialTab = ReflectTab.muhasabah});

  @override
  State<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends State<ReflectScreen> {
  late ReflectTab _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  void didUpdateWidget(covariant ReflectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedTab = widget.initialTab;
    }
  }

  void _onTabChanged(ReflectTab tab) {
    if (_selectedTab == tab) return;
    AppHaptics.selectionClick();
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasParentScaffold = Scaffold.maybeOf(context) != null;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1512)
          : const Color(0xFFF8FAF9),
      appBar: hasParentScaffold
          ? null
          : ProductiveAppBar(title: l10n.reflect, showBackButton: true),
      body: Stack(
        children: [
          Column(
            children: [
              // Segmented Capsule Switcher [Muhasabah | Barakah]
              ReflectTabSwitcher(
                selectedTab: _selectedTab,
                onTabChanged: _onTabChanged,
                isDark: isDark,
              ),

              // Active Tab Content View
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _selectedTab == ReflectTab.muhasabah
                      ? const MuhasabahView(
                          key: ValueKey('reflect_muhasabah_view'),
                        )
                      : const BarakahScreen(
                          key: ValueKey('reflect_barakah_view'),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
