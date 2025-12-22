import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData buildOpenstashTheme() {
  final base = ThemeData.dark(useMaterial3: false);

  final textTheme = base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.15,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.15,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.25,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.25,
          color: AppTokens.textMuted,
        ),
      );

  return base.copyWith(
    scaffoldBackgroundColor: AppTokens.bg,
    canvasColor: AppTokens.bg,
    cardColor: AppTokens.card,
    dividerColor: Colors.white.withOpacity(0.06),
    colorScheme: const ColorScheme.dark(
      primary: AppTokens.accent,
      secondary: AppTokens.accent,
      surface: AppTokens.card,
    ),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppTokens.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppTokens.bg,
      elevation: 0,
      selectedItemColor: Colors.white,
      unselectedItemColor: AppTokens.textSubtle,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppTokens.cardAlt,
      selectedColor: AppTokens.card,
      disabledColor: AppTokens.cardAlt,
      labelStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
      secondaryLabelStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
      shape: const StadiumBorder(),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppTokens.cardAlt,
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppTokens.textSubtle),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.p16,
        vertical: AppTokens.p12,
      ),
    ),
  );
}
