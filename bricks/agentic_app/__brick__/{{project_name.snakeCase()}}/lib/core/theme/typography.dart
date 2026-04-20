import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTypography {
  static TextTheme get textTheme {
    final sourceSans = GoogleFonts.sourceSans3TextTheme();
    final lexend = GoogleFonts.lexendTextTheme();

    return sourceSans.copyWith(
      displayLarge: lexend.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.02,
      ),
      displayMedium: lexend.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.06,
      ),
      displaySmall: lexend.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.08,
      ),
      headlineLarge: lexend.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.12,
      ),
      headlineMedium: lexend.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.16,
      ),
      headlineSmall: lexend.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      titleLarge: lexend.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.24,
      ),
      titleMedium: lexend.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleSmall: lexend.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.34,
      ),
      bodyLarge: sourceSans.bodyLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.1,
      ),
      bodyMedium: sourceSans.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.47,
      ),
      bodySmall: sourceSans.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: sourceSans.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      labelMedium: sourceSans.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelSmall: sourceSans.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}
