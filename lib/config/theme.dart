import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Synapse Dark Theme Configuration
/// Features deep gradients, neon accents, and high-contrast typography
/// optimized for focus and reduced eye strain during extended sessions.
class SynapseTheme {
  SynapseTheme._();

  // Core Palette
  static const Color _bgDeep = Color(0xFF0A0E17);
  static const Color _bgSurface = Color(0xFF111827);
  static const Color _bgCard = Color(0xFF1A2235);
  static const Color _accentPrimary = Color(0xFF00F5D4);  // Neon Cyan
  static const Color _accentSecondary = Color(0xFF7B2FF7); // Electric Purple
  static const Color _accentWarning = Color(0xFFFFB800);
  static const Color _accentDanger = Color(0xFFFF4757);
  static const Color _textPrimary = Color(0xFFE8ECF1);
  static const Color _textSecondary = Color(0xFF8B95A5);

  /// Gradient definitions for custom painting and backgrounds
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_bgDeep, Color(0xFF162032), _bgDeep],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_bgCard, Color(0xFF1E2A45)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [_accentPrimary, _accentSecondary],
  );

  /// Main ThemeData instance
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bgDeep,
      primaryColor: _accentPrimary,
      colorScheme: const ColorScheme.dark(
        primary: _accentPrimary,
        secondary: _accentSecondary,
        surface: _bgSurface,
        error: _accentDanger,
        onPrimary: _bgDeep,
        onSurface: _textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: _bgCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A3550), width: 1),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: _textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentPrimary,
          foregroundColor: _bgDeep,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _accentPrimary;
          }
          return _textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _accentPrimary.withOpacity(0.3);
          }
          return _bgCard;
        }),
      ),
    );
  }

  // Expose palette for direct access in painters and custom widgets
  static Color get accentPrimary => _accentPrimary;
  static Color get accentSecondary => _accentSecondary;
  static Color get accentWarning => _accentWarning;
  static Color get accentDanger => _accentDanger;
  static Color get textPrimary => _textPrimary;
  static Color get textSecondary => _textSecondary;
}
