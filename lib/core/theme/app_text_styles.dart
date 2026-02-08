import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Effulgence'26 Typography System
/// Primary:  Orbitron (Industrial Tech Headers - UPPERCASE DOMINANT)
/// Secondary: Inter (Clean Body Text)
class AppTextStyles {
  AppTextStyles._();

  // ═══════════════════════════════════════════════════════════════
  // FONT FAMILIES
  // ═══════════════════════════════════════════════════════════════
  static String get _primaryFont => GoogleFonts.orbitron().fontFamily!;
  static String get _bodyFont => GoogleFonts.inter().fontFamily!;

  // ═══════════════════════════════════════════════════════════════
  // DISPLAY STYLES (Hero Headers - "EFFULGENCE", "ABOUT EFFULGENCE")
  // ═══════════════════════════════════════════════════════════════
  static TextStyle get displayLarge => TextStyle(
        fontFamily: _primaryFont,
        fontSize: 56,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: 4,
        height: 1.1,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: _primaryFont,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors. textPrimary,
        letterSpacing: 3,
        height: 1.2,
      );

  static TextStyle get displaySmall => TextStyle(
        fontFamily: _primaryFont,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors. textPrimary,
        letterSpacing: 2,
        height: 1.2,
      );

  // ═══════════════════════════════════════════════════════════════
  // HEADLINE STYLES (Section Headers with Brush Strokes)
  // ═══════════════════════════════════════════════════════════════
  static TextStyle get headlineLarge => TextStyle(
        fontFamily: _primaryFont,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors. textPrimary,
        letterSpacing: 1.5,
        height: 1.3,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily:  _primaryFont,
        fontSize:  22,
        fontWeight: FontWeight.w700,
        color: AppColors. textPrimary,
        
        letterSpacing: 1,
        height: 1.3,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontFamily: _primaryFont,
        fontSize: 18,
        fontWeight: FontWeight. w600,
        color: AppColors. textPrimary,
        letterSpacing: 0.75,
        height: 1.4,
      );

  // ═══════════════════════════════════════════════════════════════
  // TITLE STYLES (Card Titles, Event Names)
  // ═══════════════════════════════════════════════════════════════
  static TextStyle get titleLarge => TextStyle(
        fontFamily:  _bodyFont,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: _bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get titleSmall => TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ═══════════════════════════════════════════════════════════════
  // BODY STYLES (Generous line height for dark UI readability)
  // ═══════════════════════════════════════════════════════════════
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors. textSecondary,
        height: 1.6,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.5,
      );

  // ═══════════════════════════════════════════════════════════════
  // LABEL STYLES (Metadata, Badges, Tags)
  // ═══════════════════════════════════════════════════════════════
  static TextStyle get labelLarge => TextStyle(
        fontFamily:  _bodyFont,
        fontSize:  14,
        fontWeight:  FontWeight.w600,
        color: AppColors. textPrimary,
        letterSpacing: 0.8,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing:  0.8,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: _bodyFont,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      );

  // ═══════════════════════════════════════════════════════════════
  // BUTTON STYLES (Confident, Bold)
  // ═══════════════════════════════════════════════════════════════
  static TextStyle get buttonLarge => TextStyle(
        fontFamily: _primaryFont,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors. textPrimary,
        letterSpacing: 1.2,
      );

  static TextStyle get buttonMedium => TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.8,
      );

  static TextStyle get buttonSmall => TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors. textPrimary,
        letterSpacing: 0.5,
      );

  // ═══════════════════════════════════════════════════════════════
  // SPECIAL STYLES
  // ═══════════════════════════════════════════════════════════════
  
  /// "INNOVATION AND BEYOND" tagline style
  static TextStyle get tagline => TextStyle(
        fontFamily: _primaryFont,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary,
        letterSpacing: 2,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.4,
      );

  static TextStyle get link => TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors. primary,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primary,
      );

  static TextStyle get error => TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.error,
        height: 1.4,
      );

  // ═══════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════
  
  /// Apply uppercase transformation (for tech headers)
  static TextStyle uppercase(TextStyle style) {
    return style; // Flutter handles via Text widget's textTransform
  }

  /// Apply accent color to any style
  static TextStyle withAccent(TextStyle style, Color accentColor) {
    return style.copyWith(color: accentColor);
  }
}