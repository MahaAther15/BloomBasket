import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF7457A2); // Updated to Purple
  static const Color primaryContainer = Color(0xFF1A2E22);
  static const Color petalPink = Color(0xFF6F5959);
  static const Color pinkContainer = Color(0xFFF6D9D9);
  static const Color richGold = Color(0xFFF7C948); // Updated to Gold
  static const Color goldContainer = Color(0xFF3B2600);
  static const Color alabaster = Color(0xFFFBF9F6);
  static const Color onSurface = Color(0xFF1B1C1A);
  static const Color outline = Color(0xFF737873);

  // Added textSecondary color
  static const Color textSecondary = Color(0xFF8A8E89);

  // Pastel floral palette (soft, feminine)
  static const Color pastelPink = Color.fromARGB(255, 255, 243, 250);
  static const Color pastelLavender = Color.fromARGB(255, 182, 114, 255);
  static const Color pastelMint = Color.fromARGB(255, 87, 218, 170);
  static const Color pastelPeach = Color.fromARGB(255, 212, 159, 86);
  static const Color pastelBg = Color.fromARGB(255, 255, 252, 253);
  static const Color pastelText = Color.fromARGB(255, 0, 0, 0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryGreen,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        onPrimaryContainer: Colors.white,
        secondary: petalPink,
        onSecondary: Colors.white,
        secondaryContainer: pinkContainer,
        onSecondaryContainer: onSurface,
        tertiary: richGold,
        onTertiary: Colors.white,
        tertiaryContainer: goldContainer,
        onTertiaryContainer: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: alabaster,
        onSurface: onSurface,
        outline: outline,
      ),
      scaffoldBackgroundColor: alabaster,
      textTheme: _textTheme(const Color.fromARGB(255, 28, 64, 44), onSurface),
      appBarTheme: const AppBarTheme(
        backgroundColor: alabaster,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryGreen),
        titleTextStyle: TextStyle(
          color: primaryGreen,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 4,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: richGold, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 125, 93, 175)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.8,
          color: primaryGreen,
        ),
        hintStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
      hintColor: textSecondary,
      disabledColor: textSecondary.withOpacity(0.5),
    );
  }

  static ThemeData get neonTheme {
    const Color primaryPurple = Color(0xFF7457A2);
    const Color accentGold = Color(0xFFF7C948);
    const Color darkBg = Color(0xFF1A1523);
    const Color surfaceColor = Color(0xFF261F33);
    const Color outlineColor = Color(0xFF3D3352);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      dividerColor: outlineColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: accentGold,
        tertiary: accentGold,
        surface: surfaceColor,
        background: darkBg,
        outline: outlineColor,
        error: Color(0xFFFF4D4D),
      ),
      textTheme: _textTheme(primaryPurple, Colors.white).copyWith(
        bodySmall: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: Colors.white70,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryPurple),
        titleTextStyle: TextStyle(
          color: primaryPurple,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outlineColor.withOpacity(0.5), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        color: outlineColor.withOpacity(0.5),
        space: 12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: outlineColor.withOpacity(0.5), width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryPurple, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF4D4D), width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF4D4D), width: 2),
        ),
        labelStyle: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: primaryPurple,
        ),
        hintStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white54,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceColor,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: outlineColor.withOpacity(0.5), width: 1),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryPurple,
        selectionColor: Color(0x337457A2),
        selectionHandleColor: primaryPurple,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          side: const BorderSide(color: primaryPurple, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      iconTheme: const IconThemeData(color: primaryPurple),
    );
  }

  static TextTheme _textTheme(Color primary, Color surface) {
    return TextTheme(
      displayLarge: GoogleFonts.notoSerif(
        fontSize: 64,
        fontWeight: FontWeight.w400,
        height: 1.1,
        letterSpacing: -1.28,
        color: primary,
      ),
      displayMedium: GoogleFonts.notoSerif(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        height: 1.2,
        color: primary,
      ),
      displaySmall: GoogleFonts.notoSerif(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: primary,
      ),
      headlineLarge: GoogleFonts.notoSerif(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: primary,
      ),
      headlineMedium: GoogleFonts.notoSerif(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: primary,
      ),
      headlineSmall: GoogleFonts.notoSerif(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: primary,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: surface,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: surface,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: surface,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: surface,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: surface,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: surface.withOpacity(0.7),
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 1.8,
        color: surface,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: surface.withOpacity(0.7),
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: surface.withOpacity(0.7),
      ),
    );
  }
}
