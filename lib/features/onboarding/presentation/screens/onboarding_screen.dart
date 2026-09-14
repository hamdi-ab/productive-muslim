import 'package:flutter/material.dart';
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
  final _nameController = TextEditingController();

  SettingsService get _settings => widget.settings ?? SettingsService.empty();

  final List<OnboardingStep> _steps = [
    const OnboardingStep(
      title: 'Build your day around what matters',
      subtitle: 'Prayer, tasks, habits, and intentions — together in one space',
      icon: Icons.spa_outlined,
    ),
    const OnboardingStep(
      title: 'What is your name?',
      subtitle: 'We use it to personalize your experience',
      icon: Icons.person_outline,
      hasInput: true,
    ),
    const OnboardingStep(
      title: 'What brings you today?',
      subtitle: 'Choose or write your own intention',
      icon: Icons.flag_outlined,
      hasChips: true,
    ),
    const OnboardingStep(
      title: 'Set up prayer times',
      subtitle: 'Get accurate adhan notifications for your location',
      icon: Icons.notifications_outlined,
      hasPermission: true,
    ),
  ];

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
        child: Padding(
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
                step.title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (step.subtitle != null)
                Text(
                  step.subtitle!,
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
              const Spacer(),
              if (step.hasInput) _buildNameInput(),
              if (step.hasChips) _buildIntentionChips(),
              if (step.hasPermission) _buildPermissionCard(),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _nextStep,
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

  Widget _buildIntentionChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Seeking barakah in my time'),
          selected: _selectedIntention == 'barakah',
          onSelected: (selected) {
            setState(() => _selectedIntention = selected ? 'barakah' : '');
          },
        ),
        FilterChip(
          label: const Text('Consistent worship & routine'),
          selected: _selectedIntention == 'worship',
          onSelected: (selected) {
            setState(() => _selectedIntention = selected ? 'worship' : '');
          },
        ),
        FilterChip(
          label: const Text('Mindful productivity'),
          selected: _selectedIntention == 'productivity',
          onSelected: (selected) {
            setState(() => _selectedIntention = selected ? 'productivity' : '');
          },
        ),
      ],
    );
  }

  Widget _buildPermissionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const Icon(Icons.location_on_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              'Allow location access for accurate prayer times?',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool hasInput;
  final bool hasChips;
  final bool hasPermission;

  const OnboardingStep({
    required this.title,
    this.subtitle,
    required this.icon,
    this.hasInput = false,
    this.hasChips = false,
    this.hasPermission = false,
  });
}
