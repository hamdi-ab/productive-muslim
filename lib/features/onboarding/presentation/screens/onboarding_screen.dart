import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/utils/app_haptics.dart';
import 'package:productive_muslim/core/widgets/glass_container.dart';
import 'package:productive_muslim/data/services/settings_service.dart';
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
  final List<String> _selectedQualities = [];
  final _nameController = TextEditingController();
  _PermissionState _permissionState = _PermissionState.initial;

  SettingsService get _settings => widget.settings ?? SettingsService.empty();

  static const _maxQualities = 3;

  final List<OnboardingStep> _steps = [
    const OnboardingStep(
      titleKey: 'onboardingWelcomeTitle',
      subtitleKey: 'onboardingWelcomeSubtitle',
      icon: Icons.nights_stay_rounded,
    ),
    const OnboardingStep(
      titleKey: 'onboardingNameTitle',
      subtitleKey: 'onboardingNameSubtitle',
      icon: Icons.person_rounded,
      hasInput: true,
    ),
    const OnboardingStep(
      titleKey: 'onboardingIntentionTitle',
      subtitleKey: 'onboardingIntentionSubtitle',
      icon: Icons.flag_rounded,
      hasChips: true,
    ),
    const OnboardingStep(
      titleKey: 'onboardingQualitiesTitle',
      subtitleKey: 'onboardingQualitiesSubtitle',
      icon: Icons.star_rounded,
      hasQualities: true,
    ),
    const OnboardingStep(
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

    if (_currentStep == 3 && _selectedQualities.isNotEmpty) {
      await _settings.setSelectedQualities(_selectedQualities);
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
    if (!kIsWeb) {
      await Geolocator.openAppSettings();
    }
  }

  bool get _canProceed {
    if (_currentStep == 1) return _nameController.text.trim().isNotEmpty;
    if (_currentStep == 2) return _selectedIntention.isNotEmpty;
    if (_currentStep == 3) return _selectedQualities.isNotEmpty;
    return true;
  }

  void _toggleQuality(String quality) {
    AppHaptics.selectionClick();
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
          // Subtle background gradient decorative circles
          IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.15 : 0.08,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -80,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withValues(
                        alpha: isDark ? 0.12 : 0.06,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Step Progress Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    key: const Key('step_progress_indicator'),
                    children: List.generate(_steps.length, (i) {
                      final isActive = i <= _currentStep;
                      final isCurrent = i == _currentStep;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: isCurrent ? 6 : 4,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.darkSurfaceSubtle
                                      : AppColors.surfaceSubtle),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                // PageView content
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
                            const SizedBox(height: 32),
                            // Hero Icon Badge with glowing effect
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                step.icon,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              step.titleKey.tr(l10n),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            if (step.subtitleKey != null)
                              Text(
                                step.subtitleKey!.tr(l10n),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                  height: 1.45,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            const SizedBox(height: 36),
                            if (step.hasInput) _buildNameInput(l10n, isDark),
                            if (step.hasChips)
                              _buildIntentionChips(l10n, isDark),
                            if (step.hasQualities)
                              _buildQualitiesSelection(isDark),
                            if (step.hasPermission)
                              _buildPermissionWidget(l10n, isDark),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Bottom Button Action Area
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

  Widget _buildNameInput(AppLocalizations l10n, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderRadius: 20,
      child: TextField(
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: l10n.enterYourName,
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
                : AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          icon: const Icon(
            Icons.edit_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildIntentionChips(AppLocalizations l10n, bool isDark) {
    final intentions = [
      ('barakah', l10n.seekingBarakah, Icons.auto_awesome_rounded),
      ('worship', l10n.consistentWorship, Icons.mosque_rounded),
      ('productivity', l10n.mindfulProductivity, Icons.bolt_rounded),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: intentions.map((item) {
        final selected = _selectedIntention == item.$1;
        return InkWell(
          onTap: () =>
              setState(() => _selectedIntention = selected ? '' : item.$1),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : (isDark
                        ? AppColors.darkSurfaceSubtle
                        : AppColors.surfaceSubtle),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.$3,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQualitiesSelection(bool isDark) {
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
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: qualities.map((q) {
        final selected = _selectedQualities.contains(q.id);
        return InkWell(
          onTap: () => _toggleQuality(q.id),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? (isDark
                        ? AppColors.secondary.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.12))
                  : (isDark
                        ? AppColors.darkSurfaceSubtle
                        : AppColors.surfaceSubtle),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  q.icon,
                  size: 18,
                  color: selected
                      ? (isDark ? AppColors.secondary : AppColors.primary)
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  q.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected
                        ? (isDark ? AppColors.secondary : AppColors.primary)
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPermissionWidget(AppLocalizations l10n, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _permissionState == _PermissionState.granted
                  ? Icons.check_circle_rounded
                  : Icons.location_on_rounded,
              size: 40,
              color: _permissionState == _PermissionState.granted
                  ? (isDark ? AppColors.secondary : AppColors.primary)
                  : AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _permissionState == _PermissionState.granted
                ? l10n.onboardingPermissionGranted
                : l10n.onboardingPermissionBody,
            style: const TextStyle(fontSize: 14, height: 1.45),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_permissionState == _PermissionState.requesting)
            const CircularProgressIndicator()
          else if (_permissionState == _PermissionState.granted)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: isDark ? AppColors.secondary : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.onboardingPermissionGranted,
                    style: TextStyle(
                      color: isDark ? AppColors.secondary : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else if (_permissionState == _PermissionState.deniedForever ||
              _permissionState == _PermissionState.serviceOff)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _openSettings,
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: Text(l10n.onboardingPermissionOpenSettings),
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _requestLocationPermission,
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(l10n.onboardingPermissionGrant),
            ),
        ],
      ),
    );
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
