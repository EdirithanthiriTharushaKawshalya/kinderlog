import 'package:flutter/material.dart';

class AppTheme {
  // Brand & Status Colors
  static const Color primaryTeal = Color(0xFF0D9488); // Teal 600 - Main Brand / Present
  static const Color secondaryCoral = Color(0xFFF43F5E); // Rose 500 - Absent
  static const Color alertAmber = Color(0xFFF59E0B); // Amber 500 - Tardy
  static const Color excusedIndigo = Color(0xFF6366F1); // Indigo 500 - Excused
  static const Color bgGrey = Color(0xFFF3F4F6); // Grey 100 - Main Background

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: secondaryCoral,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: bgGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: primaryTeal),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Custom text styling helpers
const TextStyle kTitleLarge = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
  letterSpacing: -0.5,
);

const TextStyle kTitleMedium = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
  letterSpacing: -0.2,
);

const TextStyle kBodyMedium = TextStyle(
  fontSize: 14,
  color: Colors.black54,
);
