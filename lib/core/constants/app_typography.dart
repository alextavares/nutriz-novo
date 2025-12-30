import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static const List<String> _fallbackFamilies = [
    'Inter',
    'Roboto',
    'SF Pro Text',
    'Helvetica Neue',
    'Arial',
  ];

  // Headings - Plus Jakarta Sans (Organic/Geometric)
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.1,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );

  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.1,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );

  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );

  // Body - Inter (Clean readability)
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 0.15,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
    textStyle: const TextStyle(fontFamilyFallback: _fallbackFamilies),
  );
}
