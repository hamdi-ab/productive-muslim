import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/data/services/prayer_time_service.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Settings tile that displays geolocation status and allows toggling or prompting
/// location permissions for accurate prayer calculation and Qibla bearing.
class SettingsLocationPermissionTile extends StatefulWidget {
  const SettingsLocationPermissionTile({super.key});

  @override
  State<SettingsLocationPermissionTile> createState() =>
      _SettingsLocationPermissionTileState();
}

class _SettingsLocationPermissionTileState
    extends State<SettingsLocationPermissionTile> {
  LocationPermission _permission = LocationPermission.denied;
  bool _serviceEnabled = false;
  bool _loading = false;
  String? _locationName;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      String? locName;
      if (getIt.isRegistered<PrayerTimeService>()) {
        locName = getIt<PrayerTimeService>().cachedLocationName;
      }
      if (mounted) {
        setState(() {
          _serviceEnabled = serviceEnabled;
          _permission = permission;
          _locationName = locName;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggle(bool value) async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      if (value) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please enable location services on your device.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          await _checkStatus();
          return;
        }

        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }

        if (perm == LocationPermission.deniedForever) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  kIsWeb
                      ? 'Please allow location in your browser site settings (address bar icon).'
                      : 'Location permission permanently denied. Open settings to grant.',
                ),
                action: !kIsWeb
                    ? SnackBarAction(
                        label: 'Settings',
                        onPressed: () => Geolocator.openAppSettings(),
                      )
                    : null,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (perm == LocationPermission.whileInUse ||
            perm == LocationPermission.always) {
          if (getIt.isRegistered<PrayerTimeService>()) {
            await getIt<PrayerTimeService>().getCurrentPosition();
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                kIsWeb
                    ? 'To revoke location access, adjust permissions in your browser address bar.'
                    : 'To revoke location access, adjust permissions in device settings.',
              ),
              action: !kIsWeb
                  ? SnackBarAction(
                      label: 'Settings',
                      onPressed: () => Geolocator.openAppSettings(),
                    )
                  : null,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        await _checkStatus();
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGranted =
        _permission == LocationPermission.whileInUse ||
        _permission == LocationPermission.always;

    String subtitleText;
    if (isGranted) {
      subtitleText = _locationName != null && _locationName!.isNotEmpty
          ? '📍 $_locationName • Accurate prayer times active'
          : 'Active for accurate local prayer times & Qibla';
    } else if (!_serviceEnabled) {
      subtitleText = 'Location service disabled on device';
    } else if (_permission == LocationPermission.deniedForever) {
      subtitleText = 'Permission denied permanently. Tap to open settings';
    } else {
      subtitleText = l10n.onboardingPermissionBody;
    }

    return SwitchListTile(
      key: const Key('setting_location_permission_toggle'),
      activeThumbColor: AppColors.secondary,
      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isGranted ? AppColors.primary : Colors.grey).withValues(
            alpha: 0.12,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isGranted ? Icons.location_on_rounded : Icons.location_off_rounded,
          color: isGranted ? AppColors.primary : Colors.grey,
          size: 20,
        ),
      ),
      title: const Text(
        'Location Access',
        style: TextStyle(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitleText,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      value: isGranted,
      onChanged: _loading ? null : _toggle,
    );
  }
}
