import 'package:flutter/material.dart';
import 'package:insync/src/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Segoe UI',
      scaffoldBackgroundColor: AppColors.lightBackgroundGray,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPureBlack,
        secondary: AppColors.lightSuccessGreen,
        surface: AppColors.lightPureWhite,
        onPrimary: AppColors.lightPureWhite,
        onSecondary: AppColors.lightPureWhite,
        onSurface: AppColors.lightPureBlack,
        tertiary: AppColors.lightCalmBlue,
        error: AppColors.lightSoftRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightPureWhite,
        foregroundColor: AppColors.lightPureBlack,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPureBlack,
          foregroundColor: AppColors.lightPureWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.lightSubtleGray),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightCalmBlue,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBackgroundGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightSubtleGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightSubtleGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightCalmBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightSoftRed, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.lightNeutralGray),
        iconColor: AppColors.lightNeutralGray,
      ),
      cardTheme: CardTheme(
        color: AppColors.lightPureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Segoe UI',
      scaffoldBackgroundColor: AppColors.darkBackgroundGray,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPureWhite,
        secondary: AppColors.darkSuccessGreen,
        surface: AppColors.darkCardBackground,
        onPrimary: AppColors.darkPureBlack,
        onSecondary: AppColors.darkPureWhite,
        onSurface: AppColors.darkPureWhite,
        tertiary: AppColors.darkCalmBlue,
        error: AppColors.darkSoftRed,
        surfaceContainerHighest: AppColors.darkBackgroundGray,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCardBackground,
        foregroundColor: AppColors.darkPureWhite,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPureWhite,
          foregroundColor: AppColors.darkPureBlack,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.darkSubtleGray),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkCalmBlue,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSubtleGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkSubtleGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkSubtleGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkCalmBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkSoftRed, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.darkNeutralGray),
        iconColor: AppColors.darkNeutralGray,
      ),
      cardTheme: CardTheme(
        color: AppColors.darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
