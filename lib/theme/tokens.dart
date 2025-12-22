import 'package:flutter/material.dart';

sealed class AppTokens {
  static const Color bg = Color(0xFF0E0E0F);
  static const Color card = Color(0xFF161616);
  static const Color cardAlt = Color(0xFF1A1A1A);

  static const Color textMuted = Color(0xFF9A9A9A);
  static const Color textSubtle = Color(0xFF7A7A7A);

  // Accent used for streak glow and subtle highlights.
  static const Color accent = Color(0xFF8B5CF6);

  static const double r12 = 12;
  static const double r16 = 16;

  static const double p8 = 8;
  static const double p12 = 12;
  static const double p16 = 16;
  static const double p24 = 24;
  static const double p32 = 32;

  static const double imageH = 132;

  // Library stash tile tints (kept subtle + dark).
  static const Color stashReadLaterBg = Color(0xFF1D1B26);
  static const Color stashScannedBg = Color(0xFF162125);
}
