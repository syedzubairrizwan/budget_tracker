import 'package:flutter/material.dart';

class AppColors {
  // Common Colors
  static const Color primaryColor = Color(0xFF6D5DF6);
  static const Color secondaryColor = Color(0xFFFCB045);
  static const Color errorColor = Color(0xFFFF3B30);
  static const Color successColor = Color(0xFF34C759);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightBorder = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F0F12);
  static const Color darkSurface = Color(0xFF1E1E24);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkBorder = Color(0xFF2C2C34);

  // Legacy (Keeping for compatibility or refactoring later)
  static const Color textGrey = Color(0xFFB0B0B0);
  static const Color textDark = Color(0xFF222222);
  static const Color backgroundColor = Color(0xFFF5F5F5); // Restored for compatibility
}

class AppConstants {
  static const String appName = 'Budget Tracker';
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
}
