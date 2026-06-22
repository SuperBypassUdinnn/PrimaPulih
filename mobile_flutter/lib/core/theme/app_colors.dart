import 'package:flutter/material.dart';

/// Palet warna utama PrimaPulih
/// Sumber: Mockup IMG_00001 - IMG_00010
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF1B6EF3);
  static const Color primaryLight = Color(0xFF4D8FF5);
  static const Color primaryDark = Color(0xFF0D4DB8);

  // Background Gradient (biru muda khas mockup)
  static const Color bgGradientTop = Color(0xFFB8D9F8);
  static const Color bgGradientBottom = Color(0xFFDCEEFD);
  static const Color bgLight = Color(0xFFF0F7FF);
  static const Color bgWhite = Color(0xFFFFFFFF);

  // Surface & Card
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F9FF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Header gradient strip
  static const Color headerGradientStart = Color(0xFF4FC3F7);
  static const Color headerGradientEnd = Color(0xFF81C784);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF5A6B7B);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textLink = Color(0xFF1B6EF3);

  // Status Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color successLight = Color(0xFFD4EFDF);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFDECEC);

  // Mood Colors
  static const Color moodHappy = Color(0xFFFFD700);
  static const Color moodSad = Color(0xFF6BB5E8);
  static const Color moodAngry = Color(0xFFE74C3C);
  static const Color moodCalm = Color(0xFF2ECC71);

  // Border & Divider
  static const Color border = Color(0xFFE2EAF4);
  static const Color divider = Color(0xFFF0F4F8);

  // Shadow
  static const Color shadow = Color(0x1A1B6EF3);

  // Gradient definitions
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgGradientTop, bgGradientBottom],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [headerGradientStart, headerGradientEnd],
  );
}
