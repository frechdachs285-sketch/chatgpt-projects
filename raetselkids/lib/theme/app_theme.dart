import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    const seed = Color(0xFF7A6CF6);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFFFFCF5),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF2B2B3A),
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFF2B2B3A),
          fontWeight: FontWeight.w900,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF2B2B3A),
          fontWeight: FontWeight.w900,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF4B4B5A),
          fontSize: 18,
          height: 1.25,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}
