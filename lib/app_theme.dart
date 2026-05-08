import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF05190E);
  static const Color primaryContainer = Color(0xFF1A2E22);
  static const Color petalPink = Color(0xFF6F5959);
  static const Color pinkContainer = Color(0xFFF6D9D9);
  static const Color richGold = Color(0xFF211300);
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
          backgroundColor: const Color.fromARGB(255, 36, 77, 54),
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
          borderSide: BorderSide(color: primaryGreen),
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
    const Color neonCyan = Color(0xFF00FFFF);
    const Color neonMagenta = Color(0xFFFF00FF);
    const Color neonLime = Color(0xFF39FF14);
    const Color neonPink = Color(0xFFFF10F0);
    const Color darkBg = Color(0xFF0D0D0D);
    const Color neonSurface = Color(0xFF111213);
    const Color outlineNeon = Color(0xFF2A2B2F);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      dividerColor: outlineNeon,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonMagenta,
        tertiary: neonLime,
        surface: neonSurface,
        background: darkBg,
        outline: outlineNeon,
        error: Color(0xFFFF4D4D),
      ),
      textTheme: _textTheme(neonCyan, Colors.white).copyWith(
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
        iconTheme: IconThemeData(color: neonCyan),
        titleTextStyle: TextStyle(
          color: neonCyan,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: neonSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outlineNeon, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: outlineNeon,
        space: 12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: outlineNeon, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: neonCyan, width: 2),
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
          color: neonCyan,
        ),
        hintStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white54,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: neonSurface,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: outlineNeon, width: 1),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: neonCyan,
        selectionColor: Color(0x3300FFFF),
        selectionHandleColor: neonCyan,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonCyan,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonCyan,
          side: const BorderSide(color: neonCyan, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      iconTheme: const IconThemeData(color: neonCyan),



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
