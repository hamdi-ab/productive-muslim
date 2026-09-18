import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/constants/app_radius.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  final SettingsService? settings;

  const OnboardingScreen({super.key, this.settings});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  String _selectedIntention = '';
  final List<String> _selectedQualities = [];
  final _nameController = TextEditingController();
  _PermissionState _permissionState = _PermissionState.initial;

  SettingsService get _settings => widget.settings ?? SettingsService.empty();

  static const _maxQualities = 3;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      titleKey: 'onboardingWelcomeTitle',
      subtitleKey: 'onboardingWelcomeSubtitle',
      icon: Icons.spa_outlined,
    ),
    OnboardingStep(
      titleKey: 'onboardingNameTitle',
      subtitleKey: 'onboardingNameSubtitle',
      icon: Icons.person_outline,
      hasInput: true,
    ),
    OnboardingStep(
      titleKey: 'onboardingIntentionTitle',
      subtitleKey: 'onboardingIntentionSubtitle',
      icon: Icons.flag_outlined,
      hasChips: true,
    ),
    OnboardingStep(
      titleKey: 'onboardingQualitiesTitle',
      subtitleKey: 'onboardingQualitiesSubtitle',
      icon: Icons.star_outline,
      hasQualities: true,
    ),
    OnboardingStep(
      titleKey: 'onboardingPermissionTitle',
      subtitleKey: 'onboardingPermissionSubtitle',
      icon: Icons.notifications_outlined,
      hasPermission: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_currentStep == 1 && _nameController.text.isNotEmpty) {
      await _settings.setUserName(_nameController.text);
    }

    if (_currentStep == 2 && _selectedIntention.isNotEmpty) {
      await _settings.setUserIntention(_selectedIntention);
    }

    if (_currentStep == 3 && _selectedQualities.isNotEmpty) {
      await _settings.setSelectedQualities(_selectedQualities);
    }

    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      await _settings.setOnboardingCompleted();
      if (mounted) context.go('/');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _skip() async {
    await _settings.setOnboardingCompleted();
    if (mounted) context.go('/');
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _permissionState = _PermissionState.requesting);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _permissionState = _PermissionState.serviceOff);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        await _settings.setLocationPermission('denied');
        setState(() => _permissionState = _PermissionState.denied);
      } else if (permission == LocationPermission.deniedForever) {
        await _settings.setLocationPermission('denied_forever');
        setState(() => _permissionState = _PermissionState.deniedForever);
      } else {
        await _settings.setLocationPermission('granted');
        setState(() => _permissionState = _PermissionState.granted);
      }
    } catch (_) {
      setState(() => _permissionState = _PermissionState.denied);
    }
  }

  Future<void> _openSettings() async {
    await Geolocator.openAppSettings();
  }

  bool get _canProceed {
    if (_currentStep == 1) return _nameController.text.isNotEmpty;
    if (_currentStep == 2) return _selectedIntention.isNotEmpty;
    if (_currentStep == 3) return _selectedQualities.isNotEmpty;
    return true;
  }

  void _toggleQuality(String quality) {
    setState(() {
      if (_selectedQualities.contains(quality)) {
        _selectedQualities.remove(quality);
      } else if (_selectedQualities.length < _maxQualities) {
        _selectedQualities.add(quality);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final step = _steps[_currentStep];

    return Scaffold(
      appBar: AppBar(
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
        actions: [
          TextButton(onPressed: _skip, child: Text(l10n.skip)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Icon(
                step.icon,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                step.titleKey.tr(l10n),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (step.subtitleKey != null)
                Text(
                  step.subtitleKey!.tr(l10n),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 48),
              Row(
                spacing: 8,
                children: List.generate(_steps.length, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _currentStep
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              if (step.hasInput) _buildNameInput(),
              if (step.hasChips) _buildIntentionChips(l10n),
              if (step.hasQualities) _buildQualitiesSelection(),
              if (step.hasPermission) _buildPermissionWidget(l10n),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _canProceed ? _nextStep : null,
                child: Text(
                  _currentStep == _steps.length - 1
                      ? l10n.startYourDay
                      : l10n.nextStep,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return TextField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(),
    );
  }

  Widget _buildIntentionChips(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: Text(l10n.seekingBarakah),
          selected: _selectedIntention == 'barakah',
          onSelected: (selected) {
            setState(() => _selectedIntention = selected ? 'barakah' : '');
          },
        ),
        FilterChip(
          label: Text(l10n.consistentWorship),
          selected: _selectedIntention == 'worship',
          onSelected: (selected) {
            setState(() => _selectedIntention = selected ? 'worship' : '');
          },
        ),
        FilterChip(
          label: Text(l10n.mindfulProductivity),
          selected: _selectedIntention == 'productivity',
          onSelected: (selected) {
            setState(() => _selectedIntention = selected ? 'productivity' : '');
          },
        ),
      ],
    );
  }

  Widget _buildQualitiesSelection() {
    final l10n = AppLocalizations.of(context)!;
    final qualities = [
      (id: 'taqwa', label: l10n.qualityTaqwa, icon: Icons.mosque_outlined),
      (id: 'ikhlas', label: l10n.qualityIkhlas, icon: Icons.favorite_outline),
      (
        id: 'sabr',
        label: l10n.qualitySabr,
        icon: Icons.hourglass_empty_outlined,
      ),
      (id: 'shukr', label: l10n.qualityShukr, icon: Icons.thumb_up_outlined),
      (
        id: 'tawakkul',
        label: l10n.qualityTawakkul,
        icon: Icons.shield_outlined,
      ),
      (id: 'ihsan', label: l10n.qualityIhsan, icon: Icons.star_outline),
      (id: 'ilm', label: l10n.qualityIlm, icon: Icons.menu_book_outlined),
      (id: 'dawah', label: l10n.qualityDawah, icon: Icons.campaign_outlined),
      (id: 'ummah', label: l10n.qualityUmmah, icon: Icons.groups_outlined),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: qualities.map((q) {
        final selected = _selectedQualities.contains(q.id);
        return FilterChip(
          avatar: Icon(q.icon, size: 18),
          label: Text(q.label),
          selected: selected,
          onSelected: (_) => _toggleQuality(q.id),
        );
      }).toList(),
    );
  }

  Widget _buildPermissionWidget(AppLocalizations l10n) {
    switch (_permissionState) {
      case _PermissionState.initial:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                const Icon(Icons.location_on_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  l10n.onboardingPermissionBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _requestLocationPermission,
                  child: Text(l10n.onboardingPermissionGrant),
                ),
              ],
            ),
          ),
        );

      case _PermissionState.requesting:
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                SizedBox(height: 48),
                CircularProgressIndicator(),
                SizedBox(height: 16),
              ],
            ),
          ),
        );

      case _PermissionState.granted:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.onboardingPermissionGranted,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

      case _PermissionState.denied:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                const Icon(Icons.location_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  l10n.onboardingPermissionDeniedBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: _requestLocationPermission,
                      child: Text(l10n.onboardingPermissionRetry),
                    ),
                    FilledButton.tonal(
                      onPressed: _openSettings,
                      child: Text(l10n.onboardingPermissionOpenSettings),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      case _PermissionState.deniedForever:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                const Icon(Icons.block_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  l10n.onboardingPermissionDeniedBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _openSettings,
                  child: Text(l10n.onboardingPermissionOpenSettings),
                ),
              ],
            ),
          ),
        );

      case _PermissionState.serviceOff:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                const Icon(Icons.location_disabled_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  l10n.onboardingPermissionServiceOffBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _openSettings,
                  child: Text(l10n.onboardingPermissionOpenSettings),
                ),
              ],
            ),
          ),
        );
    }
  }
}

enum _PermissionState {
  initial,
  requesting,
  granted,
  denied,
  deniedForever,
  serviceOff,
}

class OnboardingStep {
  final String titleKey;
  final String? subtitleKey;
  final IconData icon;
  final bool hasInput;
  final bool hasChips;
  final bool hasQualities;
  final bool hasPermission;

  const OnboardingStep({
    required this.titleKey,
    this.subtitleKey,
    required this.icon,
    this.hasInput = false,
    this.hasChips = false,
    this.hasQualities = false,
    this.hasPermission = false,
  });
}

extension _StringTr on String {
  String tr(AppLocalizations l10n) {
    switch (this) {
      case 'onboardingWelcomeTitle':
        return l10n.onboardingWelcomeTitle;
      case 'onboardingWelcomeSubtitle':
        return l10n.onboardingWelcomeSubtitle;
      case 'onboardingNameTitle':
        return l10n.onboardingNameTitle;
      case 'onboardingNameSubtitle':
        return l10n.onboardingNameSubtitle;
      case 'onboardingIntentionTitle':
        return l10n.onboardingIntentionTitle;
      case 'onboardingIntentionSubtitle':
        return l10n.onboardingIntentionSubtitle;
      case 'onboardingQualitiesTitle':
        return l10n.onboardingQualitiesTitle;
      case 'onboardingQualitiesSubtitle':
        return l10n.onboardingQualitiesSubtitle;
      case 'onboardingPermissionTitle':
        return l10n.onboardingPermissionTitle;
      case 'onboardingPermissionSubtitle':
        return l10n.onboardingPermissionSubtitle;
      default:
        return this;
    }
  }
}
