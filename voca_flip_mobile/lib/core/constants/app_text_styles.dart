import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';

/// Các TextStyle dùng chung trong ứng dụng VocaFlip.
/// Sử dụng font Lexend
class AppTextStyles {
  AppTextStyles._();

  // ── Heading ──
  static TextStyle heading1 = GoogleFonts.lexend(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.lexend(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Flashcard Term (mặt trước) ──
  static TextStyle flashcardTerm = GoogleFonts.lexend(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // ── Header Label (Study Session) ──
  static TextStyle headerLabel = GoogleFonts.lexend(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: 2.0,
  );

  // ── Header Subtitle (Daily Review) ──
  static TextStyle headerSubtitle = GoogleFonts.lexend(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryLight,
  );

  // ── Body ──
  static TextStyle bodyLarge = GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ── Caption / Hint ──
  static TextStyle caption = GoogleFonts.lexend(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  // ── Progress Label (Progress) ──
  static TextStyle progressLabel = GoogleFonts.lexend(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  // ── Progress Counter ──
  static TextStyle progressCounter = GoogleFonts.lexend(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
  // ── Auth & Splash ──
  static TextStyle authHeroTitle = GoogleFonts.lexend(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle authHeroSubtitle = GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle authLabel = GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textHint,
  );

  static TextStyle authInput = GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle authScreenTitle = GoogleFonts.lexend(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static TextStyle authScreenBody = GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.45,
  );

  static TextStyle authScreenLabel = GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle authScreenInput = GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle authTopBarTitle = GoogleFonts.lexend(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle authOtpDigit = GoogleFonts.lexend(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle splashTitle = GoogleFonts.lexend(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: -1.0,
    shadows: [
      const Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
    ],
  );

  static TextStyle splashSubtitle = GoogleFonts.lexend(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.splashTextAccent,
    letterSpacing: 0.5,
  );

  static TextStyle splashLoading = GoogleFonts.lexend(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: AppColors.splashLoadingText.withValues(alpha: 0.8),
  );
}
