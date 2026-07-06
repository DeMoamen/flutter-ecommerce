import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Luxurious Premium Colors
  static const Color _primaryLight = Color(0xFF1A1A1D); // Deep Charcoal/Black
  static const Color _primaryDark = Color(0xFFFFFFFF);
  static const Color _accentColor = Color(0xFFC5A880); // Refined Champagne Gold
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _backgroundLight = Color(0xFFF9FAFB); // Very clean off-white
  static const Color _surfaceDark = Color(0xFF121212); // Deep dark
  static const Color _backgroundDark = Color(0xFF09090B); // Almost black

  // ─── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: _primaryLight,
          secondary: _accentColor,
          surface: _surfaceLight,
        ),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme).apply(
          bodyColor: _primaryLight,
          displayColor: _primaryLight,
        ),
        scaffoldBackgroundColor: _backgroundLight,
        appBarTheme: AppBarTheme(
          backgroundColor: _backgroundLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: _primaryLight),
          titleTextStyle: GoogleFonts.cairo(
            color: _primaryLight,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _surfaceLight,
          selectedItemColor: _accentColor,
          unselectedItemColor: Color(0xFF9E9E9E),
          elevation: 20,
          type: BottomNavigationBarType.fixed,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceLight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          hintStyle: GoogleFonts.cairo(color: const Color(0xFF9E9E9E), fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _accentColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryLight,
            foregroundColor: _accentColor, // Gold text on black button is very luxurious
            elevation: 0, // Flat design is more modern
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0, // We use border and soft color instead of heavy shadows for a modern look
          color: _surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFF0F0F0), width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFEEEEEE),
          thickness: 1,
          space: 24,
        ),
      );

  // ─── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: _accentColor,
          secondary: _accentColor,
          surface: _surfaceDark,
        ),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: _primaryDark,
          displayColor: _primaryDark,
        ),
        scaffoldBackgroundColor: _backgroundDark,
        appBarTheme: AppBarTheme(
          backgroundColor: _backgroundDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: _primaryDark),
          titleTextStyle: GoogleFonts.cairo(
            color: _primaryDark,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _surfaceDark,
          selectedItemColor: _accentColor,
          unselectedItemColor: Color(0xFF757575),
          elevation: 20,
          type: BottomNavigationBarType.fixed,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceDark,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          hintStyle: GoogleFonts.cairo(color: const Color(0xFF757575), fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _accentColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: _primaryLight, // Dark text on gold button
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: _surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2C2C2C),
          thickness: 1,
          space: 24,
        ),
      );
}
