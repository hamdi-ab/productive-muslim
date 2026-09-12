import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/constants/app_radius.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Build your day around what matters',
      subtitle: 'Prayer, tasks, habits, and intentions — together in one space',
      icon: Icons.spa_outlined,
    ),
    OnboardingStep(
      title: 'What is your name?',
      subtitle: 'We use it to personalize your experience',
      icon: Icons.person_outline,
      hasInput: true,
    ),
    OnboardingStep(
      title: 'What brings you today?',
      subtitle: 'Choose or write your own intention',
      icon: Icons.flag_outlined,
      hasChips: true,
    ),
    OnboardingStep(
      title: 'Set up prayer times',
      subtitle: 'Get accurate adhan notifications for your location',
      icon: Icons.notifications_outlined,
      hasPermission: true,
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            child: Text(l10n.skip),
          ),
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
                style: Theme.of(context).typography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (step.subtitle != null)
                Text(
                  step.subtitle,
                  style: Theme.of(context).typography.bodyMedium,
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
                            : Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
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
    return const TextField(
      textCapitalization: TextCapitalization.words,
      decoration: EdgeInsets(),
    );
  }

  Widget _buildIntentionChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Seeking barakah in my time'),
          onSelected: (selected) {},
        ),
        FilterChip(
          label: const Text('Consistent worship & routine'),
          onSelected: (selected) {},
        ),
        FilterChip(
          label: const Text('Mindful productivity'),
          onSelected: (selected) {},
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
              style: Theme.of(context).typography.bodyMedium,
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
  final Icons icon;
  final bool hasInput;
  final bool hasChips;
  final bool hasPermission;

  OnboardingStep({
    required this.title,
    this.subtitle,
    required this.icon,
    this.hasInput = false,
    this.hasChips = false,
    this.hasPermission = false,
  });
}