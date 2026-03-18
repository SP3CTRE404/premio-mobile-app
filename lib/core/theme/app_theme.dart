import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.cobaltBlue,
      scaffoldBackgroundColor: AppColors.pureWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.cobaltBlue,
        surface: AppColors.lightSurface,
        onSurface: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.pureWhite,
        selectedItemColor: AppColors.cobaltBlue,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.cobaltBlue,
        foregroundColor: Colors.black, // High contrast for neon
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: Color.fromRGBO(0, 0, 0, 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.cobaltBlue,
      scaffoldBackgroundColor: AppColors.trueBlack,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cobaltBlue,
        surface: AppColors.darkSurface,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.trueBlack,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.trueBlack,
        selectedItemColor: AppColors.cobaltBlue,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.cobaltBlue,
        foregroundColor: Colors.black,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      useMaterial3: true,
    );
  }
}
