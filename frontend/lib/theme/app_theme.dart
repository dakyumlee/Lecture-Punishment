import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryDark = Color(0xFF00010D);
  static const Color secondaryDark = Color(0xFF595048);
  static const Color accentBrown = Color(0xFF736A63);
  static const Color lightGray = Color(0xFFD9D4D2);
  static const Color pureBlack = Color(0xFF0D0D0D);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      primaryColor: secondaryDark,
      fontFamily: 'JoseonGulim',
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF595048),
        secondary: Color(0xFF736A63),
        surface: Color(0xFF00010D),
        error: Colors.red,
        onPrimary: Color(0xFFD9D4D2),
        onSecondary: Color(0xFFD9D4D2),
        onSurface: Color(0xFFD9D4D2),
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightGray,
          fontFamily: 'JoseonGulim',
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: lightGray,
          fontFamily: 'JoseonGulim',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: lightGray,
          fontFamily: 'JoseonGulim',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: lightGray,
          fontFamily: 'JoseonGulim',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryDark,
          foregroundColor: lightGray,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'JoseonGulim',
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: secondaryDark,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }
}
