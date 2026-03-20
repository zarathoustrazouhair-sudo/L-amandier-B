import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.parchmentBg,
      colorScheme: const ColorScheme.light(
        primary:    AppColors.primaryBlue,
        secondary:  AppColors.accentGold,
        tertiary:   AppColors.mosaicGreen,
        error:      AppColors.errorRed,
        surface:    AppColors.cardSurface,
        background: AppColors.parchmentBg,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge:  GoogleFonts.cinzel(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
        displayMedium: GoogleFonts.cinzel(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
        headlineLarge: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
        headlineMedium: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
        bodyLarge:  GoogleFonts.inter(fontSize: 15, color: AppColors.primaryBlue),
        bodyMedium: GoogleFonts.inter(fontSize: 13, color: AppColors.primaryBlue),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: AppColors.primaryBlue.withOpacity(0.08),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.primaryBlue,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      dividerColor: AppColors.dividerLine,
      dividerTheme: const DividerThemeData(color: AppColors.dividerLine, thickness: 1),
    );
  }
}
