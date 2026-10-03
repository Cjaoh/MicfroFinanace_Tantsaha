import 'package:flutter/material.dart';

/// Palette Tantsaha, alignée sur la maquette (vert agricole + fond crème).
/// Les noms des couleurs sont conservés pour ne rien casser dans les écrans.
class AppColors {
  // Verts principaux
  static const primary      = Color(0xFF1B5E3A); // vert foncé (cartes, boutons, nav active)
  static const primaryLight = Color(0xFF2E7D4F); // vert moyen
  static const primaryPale  = Color(0xFFF4F7F2); // fond crème des écrans
  static const borderColor  = Color(0xFFDCE6DC); // bordures de cartes
  static const accentText   = Color(0xFF0F3D26); // texte foncé
  static const mutedText    = Color(0xFF5F7566); // texte secondaire gris-vert
  static const subtleGreen  = Color(0xFFBFE3CC); // petit texte sur fond vert foncé

  // Revenus (vert)
  static const revBg        = Color(0xFFE3F2E6);
  static const revText      = Color(0xFF14532D);
  static const revAmount    = Color(0xFF1E8449);

  // Dépenses (rouge)
  static const depBg        = Color(0xFFFDECEA);
  static const depText      = Color(0xFF7F1D1D);
  static const depAmount    = Color(0xFFD32F2F);

  // Épargne (orange) — utilisée à l'étape suivante
  static const savBg        = Color(0xFFFFF3E0);
  static const savAmount    = Color(0xFFEF8F00);

  static const balText      = Color(0xFF1B5E3A);
  static const white        = Color(0xFFFFFFFF);
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: AppColors.borderColor, width: 0.5),
      ),
    ),
    useMaterial3: true,
  );
}