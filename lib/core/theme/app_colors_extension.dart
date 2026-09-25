import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Branding Primary & Secondary
  static const Color primary = Color(0xFF0F4C3A); // Deep Emerald
  static const Color primaryLight = Color(0xFF10B981); // Bright Mint
  static const Color primaryDark = Color(0xFF082E23); // Dark Forest
  static const Color secondary = Color(0xFFD4AF37); // Warm Gold
  static const Color secondaryLight = Color(0xFFF59E0B); // Amber Gold
  static const Color secondaryDark = Color(
    0xFF92600E,
  ); // Deep Warm Amber (WCAG AA Compliant on Light surfaces)

  // Surfaces
  static const Color background = Color(0xFFF8FAF9); // Soft Porcelain Light
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF0F4F2);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0B1512); // Midnight Forest
  static const Color darkSurface = Color(0xFF13221C); // Deep Emerald Surface
  static const Color darkSurfaceSubtle = Color(0xFF1B2D26);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textDisabled = Color(0xFF9CA3AF);

  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // States & Accents
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F4C3A), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF13221C), Color(0xFF1B2D26)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Borders
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF1E3A2F);

  // Glassmorphic Colors
  static Color glassBackgroundLight = Colors.white.withValues(alpha: 0.88);
  static Color glassBackgroundDark = const Color(0xFF13221C)
      .withValues(alpha: 0.85);
  static Color glassBorderLight = const Color(0xFF0F4C3A)
      .withValues(alpha: 0.08);
  static Color glassBorderDark = Colors.white.withValues(alpha: 0.12);
}
