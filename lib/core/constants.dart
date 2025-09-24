import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF6A5ACD); // Slate Blue
  static const Color secondaryColor = Color(0xFF48D1CC); // Medium Turquoise
  static const Color backgroundColor = Color(0xFFF5F5F5); // White Smoke
  static const Color textColor = Color(0xFF333333); // Dark Gray
  static const Color errorColor = Color(0xFFFF6347); // Tomato
  static const Color chartColor1 = Color(0xFFFFD700); // Gold
  static const Color chartColor2 = Color(0xFFADFF2F); // Green Yellow
  static const Color textGrey = Color(0xFFB0B0B0); // Light Grey
  static const Color textDark = Color(0xFF222222); // Almost Black
}

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );
  static const TextStyle headline2 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );
  static const TextStyle bodyText1 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );
  static const TextStyle bodyText2 = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );
}
