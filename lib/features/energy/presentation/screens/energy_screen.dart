import 'package:flutter/material.dart';
import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/productive_app_bar.dart';
import 'package:productive_muslim/features/energy/presentation/widgets/energy_fasting_card.dart';
import 'package:productive_muslim/features/energy/presentation/widgets/energy_hero_header_card.dart';
import 'package:productive_muslim/features/energy/presentation/widgets/energy_physical_anchors_card.dart';
import 'package:productive_muslim/features/energy/presentation/widgets/energy_promise_card.dart';
import 'package:productive_muslim/features/energy/presentation/widgets/energy_triad_card.dart';
import 'package:productive_muslim/features/energy/presentation/widgets/qaylulah_nap_card.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

/// Screen orchestrating the Islamic Triple-Energy framework:
/// 1. Hero Header & Al-Qawiyy tier
/// 2. Energy Triad personal reflection (Ruh, Jism, Aql)
/// 3. Qaylulah (Sunnah midday nap) recharge
/// 4. Sunnah Fasting metabolic alignment
/// 5. Sunnah Physical Anchors
class EnergyScreen extends StatelessWidget {
  const EnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1512) : AppColors.background,
      appBar: ProductiveAppBar(
        title: l10n.energyTitle,
        subtitle: l10n.energySubtitle,
        showBackButton: true,
      ),
      body: Stack(
        children: [
          // Subtle Islamic Lattice Watermark
          Positioned.fill(
            child: CustomPaint(
              painter: _IslamicLatticeBackgroundPainter(isDark: isDark),
            ),
          ),

          // Ambient Radial Glow
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE9C349)
                        .withValues(alpha: isDark ? 0.18 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Body
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Hero Banner: Triple-Energy Management & Al-Qawiyy
                    EnergyHeroHeaderCard(),
                    SizedBox(height: AppSpacing.md),

                    // SECTION 1: Holistic Energy Triad & Battery Gauge
                    EnergyTriadCard(),
                    SizedBox(height: AppSpacing.lg),

                    // SECTION 2: Qaylulah (Midday Sunnah Nap) Recharge
                    QaylulahNapCard(),
                    SizedBox(height: AppSpacing.lg),

                    // SECTION 3: Sunnah Fasting Alignment & Deep Link
                    EnergyFastingCard(),
                    SizedBox(height: AppSpacing.lg),

                    // SECTION 4: Sunnah Physical Anchors (Mohammed Faris)
                    EnergyPhysicalAnchorsCard(),
                    SizedBox(height: AppSpacing.md),

                    // Inspirational Barakah Promise Banner
                    EnergyPromiseCard(),
                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Background Islamic lattice pattern painter
class _IslamicLatticeBackgroundPainter extends CustomPainter {
  final bool isDark;

  const _IslamicLatticeBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? const Color(0xFFE9C349).withValues(alpha: 0.025)
          : const Color(0xFF0F4C3A).withValues(alpha: 0.02)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 50.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), spacing * 0.45, paint);
        final path = Path()
          ..moveTo(x, y - spacing * 0.45)
          ..lineTo(x + spacing * 0.45, y)
          ..lineTo(x, y + spacing * 0.45)
          ..lineTo(x - spacing * 0.45, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicLatticeBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
