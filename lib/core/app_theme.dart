import 'package:flutter/material.dart';

class AppTheme {
  // Palette — deep navy + electric cyan accent on dark slate
  static const Color bgBase = Color(0xFF0D1117);
  static const Color bgSurface = Color(0xFF161B22);
  static const Color bgCard = Color(0xFF1C2128);
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentDim = Color(0xFF0090B3);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color borderColor = Color(0xFF30363D);
  static const Color successGreen = Color(0xFF3FB950);
  static const Color warningAmber = Color(0xFFD29922);
  static const Color dangerRed = Color(0xFFF85149);
  static const Color volunteerBlue = Color(0xFF58A6FF);
  static const Color candidatePurple = Color(0xFFBC8CFF);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgBase,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          surface: bgSurface,
          onSurface: textPrimary,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'monospace',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
            height: 1.5,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        cardTheme: CardThemeData(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: borderColor, width: 1),
          ),
        ),
        dividerColor: borderColor,
      );
}