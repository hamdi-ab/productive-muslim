import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Light theme
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF2E7D4F),
      onPrimary: Colors.white,
      secondary: const Color(0xFFD4AF37),
      onSecondary: Colors.black87,
      surface: Colors.white,
      onSurface: Colors.black87,
      error: const Color(0xFFD32F2F),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
    ),
    bottomsheetsTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      modalBackgroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
  );

  // Dark theme
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF4CAF7F),
      onPrimary: Colors.black87,
      secondary: const Color(0xFFE0C265),
      onSecondary: Colors.black87,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
      error: const Color(0xFFEF5350),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    useMaterial3: true,
  );
}