import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Các TextStyle dùng chung trong ứng dụng VocaFlip.
/// Sử dụng font Lexend theo design Stitch.
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

  // ── Flashcard Term (mặt trước) — to, bold, màu textPrimary (đen) ──
  static TextStyle flashcardTerm = GoogleFonts.lexend(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // ── Header Label (STUDY SESSION) ──
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

  // ── Progress Label (PROGRESS) ──
  static TextStyle progressLabel = GoogleFonts.lexend(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  // ── Progress Counter (12 / 50) ──
  static TextStyle progressCounter = GoogleFonts.lexend(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
}
