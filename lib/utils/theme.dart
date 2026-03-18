// lib/utils/theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern vibrant palette
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF00C9A7);
  static const Color accentColor = Color(0xFFFFC93C);
  static const Color backgroundColor = Color(0xFFF7F8FA);
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF0F1F6);
  static const Color textPrimary = Color(0xFF22223B);
  static const Color textSecondary = Color(0xFF9A9A9A);
  static const Color errorColor = Color(0xFFE57373);
  static const Color successColor = Color(0xFF43A047);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color warningColor = Color(0xFFFFB300);

  // Pomodoro Timer Colors
  static const Color workColor = Color(0xFFFD5E53);
  static const Color shortBreakColor = Color(0xFF43A047);
  static const Color longBreakColor = Color(0xFF1E88E5);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: surfaceColor,
      onSurface: textPrimary,
    ),
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: GoogleFonts.nunito().fontFamily,
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      headlineLarge: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
      headlineMedium: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      titleLarge: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      bodyLarge: const TextStyle(fontSize: 16),
      bodyMedium: const TextStyle(fontSize: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: cardColor,
      shadowColor: primaryColor.withOpacity(0.08),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      titleTextStyle: GoogleFonts.nunito(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 6,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      selectedColor: accentColor.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelStyle: const TextStyle(color: textPrimary),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.9),
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: Color(0xFF23243B),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF181A20),
    fontFamily: GoogleFonts.nunito().fontFamily,
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
      headlineMedium: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
      titleLarge: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
      bodyLarge: const TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: const TextStyle(fontSize: 14, color: Colors.white70),
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: const Color(0xFF23243B),
      shadowColor: primaryColor.withOpacity(0.12),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.nunito(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 6,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF23243B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF23243B),
      selectedColor: accentColor.withOpacity(0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelStyle: const TextStyle(color: Colors.white),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF23243B).withOpacity(0.95),
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.white54,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF23243B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF35354D),
      thickness: 1,
    ),
  );
}