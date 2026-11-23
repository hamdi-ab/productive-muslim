import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
import 'package:productive_muslim/features/onboarding/presentation/widgets/onboarding_background_decorations.dart';
import 'package:productive_muslim/features/onboarding/presentation/widgets/onboarding_intention_chips.dart';
import 'package:productive_muslim/features/onboarding/presentation/widgets/onboarding_name_input.dart';
import 'package:productive_muslim/features/onboarding/presentation/widgets/onboarding_permission_card.dart';
import 'package:productive_muslim/features/onboarding/presentation/widgets/onboarding_pillars_selector.dart';
import 'package:productive_muslim/features/onboarding/presentation/widgets/onboarding_qualities_selector.dart';
import 'package:productive_muslim/features/onboarding/presentation/widgets/onboarding_step_header.dart';
import 'package:productive_muslim/features/onboarding/presentation/widgets/onboarding_step_indicator.dart';
import 'package:productive_muslim/features/onboarding/presentation/widgets/onboarding_step_model.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  final SettingsService? settings;

  const OnboardingScreen({super.key, this.settings});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentStep = 0;
  String _selectedIntention = '';
  final List<String> _selectedPillars = [];
  final _nameController = TextEditingController();
  OnboardingPermissionState _permissionState =
      OnboardingPermissionState.initial;

  SettingsService get _settings => widget.settings ?? SettingsService.empty();

  static const _maxPillars = 3;

  static const List<OnboardingStep> _steps = [
    OnboardingStep(
      titleKey: 'onboardingWelcomeTitle',
      subtitleKey: 'onboardingWelcomeSubtitle',
      icon: Icons.nights_stay_rounded,
    ),
    OnboardingStep(
      titleKey: 'onboardingNameTitle',
      subtitleKey: 'onboardingNameSubtitle',
      icon: Icons.person_rounded,
      hasInput: true,
    ),
    OnboardingStep(
      titleKey: 'onboardingIntentionTitle',
      subtitleKey: 'onboardingIntentionSubtitle',
      icon: Icons.flag_rounded,
      hasChips: true,
    ),
    OnboardingStep(
      titleKey: 'onboardingPillarsTitle',
      subtitleKey: 'onboardingPillarsSubtitle',
      icon: Icons.view_quilt_rounded,
      hasPillars: true,
    ),
    OnboardingStep(
      titleKey: 'onboardingPermissionTitle',
      subtitleKey: 'onboardingPermissionSubtitle',
      icon: Icons.location_on_rounded,
      hasPermission: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    AppHaptics.lightImpact();
    if (_currentStep == 1 && _nameController.text.isNotEmpty) {
      await _settings.setUserName(_nameController.text);
    }

    if (_currentStep == 2 && _selectedIntention.isNotEmpty) {
      await _settings.setUserIntention(_selectedIntention);
    }

    if (_currentStep == 3 && _selectedPillars.isNotEmpty) {
      await _settings.setSelectedPillars(_selectedPillars);
    }

    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await _settings.setOnboardingCompleted();
      if (mounted) context.go('/');
    }
  }

  void _previousStep() {
    AppHaptics.lightImpact();
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skip() async {
    await _settings.setOnboardingCompleted();
    if (mounted) context.go('/');
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _permissionState = OnboardingPermissionState.requesting);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _permissionState = OnboardingPermissionState.serviceOff);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        await _settings.setLocationPermission('denied');
        setState(() => _permissionState = OnboardingPermissionState.denied);
      } else if (permission == LocationPermission.deniedForever) {
        await _settings.setLocationPermission('denied_forever');
        setState(
          () => _permissionState = OnboardingPermissionState.deniedForever,
        );
      } else {
        await _settings.setLocationPermission('granted');
        setState(() => _permissionState = OnboardingPermissionState.granted);
      }
    } catch (_) {
      setState(() => _permissionState = OnboardingPermissionState.denied);
    }
  }

  Future<void> _openSettings() async {
    if (!kIsWeb) {
      await Geolocator.openAppSettings();
    }
  }

  bool get _canProceed {
    if (_currentStep == 1) return _nameController.text.trim().isNotEmpty;
    if (_currentStep == 2) return _selectedIntention.isNotEmpty;
    if (_currentStep == 3) return _selectedPillars.isNotEmpty;
    return true;
  }

  void _togglePillar(String pillar) {
    AppHaptics.selectionClick();
    setState(() {
      if (_selectedPillars.contains(pillar)) {
        _selectedPillars.remove(pillar);
      } else if (_selectedPillars.length < _maxPillars) {
        _selectedPillars.add(pillar);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _previousStep,
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      final isAr =
                          Localizations.localeOf(context).languageCode == 'ar';
                      _settings.setLocaleCode(isAr ? 'en' : 'ar');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? 'English'
                                : 'العربية',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: _skip,
            child: Text(
              l10n.skip,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          OnboardingBackgroundDecorations(isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                OnboardingStepIndicator(
                  totalSteps: _steps.length,
                  currentStep: _currentStep,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentStep = index);
                    },
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            OnboardingStepHeader(
                              step: step,
                              isDark: isDark,
                              l10n: l10n,
                            ),
                            if (step.hasInput)
                              OnboardingNameInput(
                                controller: _nameController,
                                l10n: l10n,
                                isDark: isDark,
                              ),
                            if (step.hasChips)
                              OnboardingIntentionChips(
                                selectedIntention: _selectedIntention,
                                onSelected: (val) {
                                  setState(() => _selectedIntention = val);
                                },
                                l10n: l10n,
                                isDark: isDark,
                              ),
                            if (step.hasPillars)
                              OnboardingPillarsSelector(
                                selectedPillars: _selectedPillars,
                                onToggle: _togglePillar,
                                isDark: isDark,
                              ),
                            if (step.hasQualities)
                              OnboardingQualitiesSelector(
                                selectedQualities: _selectedPillars,
                                onToggle: _togglePillar,
                                isDark: isDark,
                              ),
                            if (step.hasPermission)
                              OnboardingPermissionCard(
                                state: _permissionState,
                                onRequestPermission: _requestLocationPermission,
                                onOpenSettings: _openSettings,
                                l10n: l10n,
                                isDark: isDark,
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _canProceed ? _nextStep : null,
                      child: Text(
                        _currentStep == _steps.length - 1
                            ? l10n.startYourDay
                            : l10n.nextStep,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
