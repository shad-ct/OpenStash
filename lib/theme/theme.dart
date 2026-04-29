import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

ThemeData buildOpenstashTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  final textTheme = GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
    headlineSmall: GoogleFonts.outfit(
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: -0.5,
    ),
    titleLarge: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      height: 1.15,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      height: 1.15,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.outfit(
      fontWeight: FontWeight.w400,
      height: 1.3,
      color: Colors.white70,
    ),
    bodySmall: GoogleFonts.outfit(
      fontWeight: FontWeight.w400,
      height: 1.3,
      color: AppTokens.textMuted,
    ),
    labelSmall: GoogleFonts.outfit(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppTokens.bg,
    canvasColor: AppTokens.bg,
    cardColor: AppTokens.card,
    dividerColor: Colors.white.withOpacity(0.08),
    colorScheme: const ColorScheme.dark(
      primary: AppTokens.accent,
      secondary: AppTokens.accentAlt,
      surface: AppTokens.card,
      background: AppTokens.bg,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppTokens.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      centerTitle: false,
      titleTextStyle: textTheme.headlineSmall,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: Colors.white,
      unselectedItemColor: AppTokens.textSubtle,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white.withOpacity(0.05),
      selectedColor: AppTokens.accent.withOpacity(0.2),
      disabledColor: AppTokens.cardAlt,
      labelStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
      secondaryLabelStyle: textTheme.bodySmall?.copyWith(color: AppTokens.accent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: Colors.white.withOpacity(0.1)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppTokens.cardAlt,
      contentTextStyle: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      elevation: 10,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppTokens.textSubtle),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTokens.accent),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.p16,
        vertical: AppTokens.p16,
      ),
    ),
  );
}
