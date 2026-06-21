import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand & Status Colors
  static const Color primaryTeal = Color(0xFF7F56D9); // Lavender Purple - Main Brand / Present
  static const Color secondaryCoral = Color(0xFFFB7185); // Rose 400 - Absent
  static const Color alertAmber = Color(0xFFFBBF24); // Amber 400 - Tardy
  static const Color excusedIndigo = Color(0xFF60A5FA); // Sky Blue 400 - Excused
  static const Color bgGrey = Color(0xFFF8F9FE); // Warm Lavender scaffold background

  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light(useMaterial3: true);
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: secondaryCoral,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: bgGrey,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme).copyWith(
        titleLarge: GoogleFonts.fredoka(
          textStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D2939),
            letterSpacing: -0.5,
          ),
        ),
        titleMedium: GoogleFonts.fredoka(
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D2939),
            letterSpacing: -0.2,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        titleTextStyle: GoogleFonts.fredoka(
          textStyle: const TextStyle(
            color: Color(0xFF1D2939), // Charcoal text
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87), // keep them black
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFF4EBFF), width: 1.5), // Soft lavender border
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE9D7FE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF4EBFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.plusJakartaSans(color: Colors.black54),
        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.black38),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Fully rounded buttons
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          side: const BorderSide(color: primaryTeal, width: 1.5),
          textStyle: GoogleFonts.plusJakartaSans(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28), // Professional corners
        ),
        titleTextStyle: GoogleFonts.fredoka(
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D2939),
          ),
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          textStyle: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners dropdowns
        ),
      ),
    );
  }
}

// Custom text styling helpers
const TextStyle kTitleLarge = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: Color(0xFF1D2939), // Charcoal
  letterSpacing: -0.5,
  fontFamily: 'Fredoka',
);

const TextStyle kTitleMedium = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Color(0xFF1D2939), // Charcoal
  letterSpacing: -0.2,
  fontFamily: 'Fredoka',
);

const TextStyle kBodyMedium = TextStyle(
  fontSize: 14,
  color: Colors.black54,
  fontFamily: 'Plus Jakarta Sans',
);
