import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0A0538);
  static const Color primary = Color(0xFFCC97FF);
  static const Color primaryDim = Color(0xFF9E41F5);
  static const Color secondary = Color(0xFFFED01B);
  static const Color secondaryDim = Color(0xFFEEC200);
  static const Color tertiary = Color(0xFFFF8887);
  static const Color surfaceContainerHighest = Color(0xFF201A61);
  static const Color surfaceContainerHigh = Color(0xFF1A1456);
  static const Color surfaceContainer = Color(0xFF140F4C);
  static const Color surfaceContainerLow = Color(0xFF0E0841);
  static const Color onSurface = Color(0xFFE6E2FF);
  static const Color onSurfaceVariant = Color(0xFFA9A5DE);
  static const Color error = Color(0xFFFF6E84);
  static const Color errorContainer = Color(0xFFA70138);

  // Rarity Colors
  static const Color rarityCommon = Color(0xFFA9A5DE); // Greyish Blue-Grey
  static const Color rarityUncommon = Color(0xFF4CAF50); // Green
  static const Color rarityRare = Color(0xFF2196F3); // Blue
  static const Color rarityEpic = Color(0xFF9C27B0); // Purple
  static const Color rarityLegendary = Color(0xFFFFC107); // Yellow/Gold
  static const Color rarityMythic = Color(0xFFFF5252); // Red Accent

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        background: background,
        surface: surfaceContainer,
        error: error,
        onPrimary: Color(0xFF46007C),
        onSecondary: Color(0xFF594700),
        onSurface: onSurface,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.epilogue(
          color: onSurface,
          fontWeight: FontWeight.w900,
          fontSize: 32,
        ),
        headlineMedium: GoogleFonts.epilogue(
          color: primary,
          fontWeight: FontWeight.w800,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: onSurface,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: onSurfaceVariant,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          color: onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF46007C),
          textStyle: GoogleFonts.epilogue(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}
