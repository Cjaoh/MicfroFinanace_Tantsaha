import 'package:flutter/material.dart';

class AppColors {
  static const primary      = Color(0xFF0C447C);
  static const primaryLight = Color(0xFF185FA5);
  static const primaryPale  = Color(0xFFE6F1FB);
  static const borderColor  = Color(0xFFB5D4F4);
  static const accentText   = Color(0xFF042C53);
  static const mutedText    = Color(0xFF185FA5);

  static const revBg        = Color(0xFFEAF3DE);
  static const revText      = Color(0xFF27500A);
  static const revAmount    = Color(0xFF27500A);

  static const depBg        = Color(0xFFFCEBEB);
  static const depText      = Color(0xFF791F1F);
  static const depAmount    = Color(0xFFA32D2D);

  static const balText      = Color(0xFF0C447C);
  static const white        = Color(0xFFFFFFFF);
  static const subtleBlue   = Color(0xFF85B7EB);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.primaryPale,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        side: BorderSide(color: AppColors.borderColor, width: 0.5),
      ),
    ),
    useMaterial3: true,
  );
}
