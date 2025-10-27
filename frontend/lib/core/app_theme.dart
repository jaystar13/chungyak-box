import 'package:flutter/material.dart';
import 'app_constants.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      tertiary: Colors.indigoAccent,
      brightness: Brightness.light,
    ),
    textTheme: Typography.blackMountainView,
    typography: Typography.material2021(),
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
  );
}
