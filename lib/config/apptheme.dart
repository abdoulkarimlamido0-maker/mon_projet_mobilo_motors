import 'package:flutter/material.dart';

class AppColors {
  static const Color indigoDeep = Color(0xFF1E2A4A);
  static const Color indigoMid  = Color(0xFF2F4470);
  static const Color sand       = Color(0xFFF0E4CC);
  static const Color sandLight  = Color(0xFFF8F1E1);
  static const Color sun        = Color(0xFFE8622C);
  static const Color sunDark   = Color(0xFFC74F1E);
  static const Color millet    = Color(0xFF3F7A52);
  static const Color charcoal  = Color(0xFF211A14);
  static const Color white     = Color(0xFFFFFDF8);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.sandLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.indigoDeep,
        primary: AppColors.indigoDeep,
        secondary: AppColors.sun,
        surface: AppColors.sandLight,
      ),
      fontFamily: 'Roboto',
    );
  }
}