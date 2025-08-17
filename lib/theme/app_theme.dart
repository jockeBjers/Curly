import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1B3A2B);
  static const Color secondaryColor = Color(0xFF607D8B);
  static const Color tertiaryColor = Color(0xFF37474F);
  static const Color backgroundColor = Color(0xFF23272A);
  static const Color surfaceColor = Color.fromARGB(255, 40, 41, 40);
  static const Color mainColor = Color.fromARGB(255, 233, 196, 30);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        scrolledUnderElevation: 0,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Color(0xFF4CAF50),
        selectionHandleColor: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 4,
        backgroundColor: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: mainColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF455A64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.black87,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white70, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(),
      useMaterial3: true,
    );
  }
}
