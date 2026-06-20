import 'package:flutter/material.dart';

class AppColors {
  // Common Colors
  static const Color primaryColor = Color(0xFF2F69FD); // Electric Blue
  static const Color secondaryColor = Color(0xFF8FD9B6); // Mint Green
  static const Color errorColor = Color(0xFFEF4444); // Red-500
  static const Color successColor = Color(0xFF8FD9B6); // Mint Green (Income/Success)
  static const Color tertiaryColor = Color(0xFFE9621B); // Orange/Coral

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF1F5F9); // Clean slate bg
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate-900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate-500
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate-200

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A); // Slate-900
  static const Color darkSurface = Color(0xFF1E293B); // Slate-800
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate-50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate-400
  static const Color darkBorder = Color(0xFF334155); // Slate-700

  // Legacy (Keeping for compatibility or refactoring later)
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF0F172A);
  static const Color backgroundColor = Color(0xFFF1F5F9);
}

class AppConstants {
  static const String appName = 'Budget Tracker';
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0; // Stitch ROUND_TWELVE
}
