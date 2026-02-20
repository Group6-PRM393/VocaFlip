import 'package:flutter/material.dart';

/// Bảng màu chính của ứng dụng VocaFlip.
/// Dựa theo design Stitch: Light Theme, Primary xanh đậm (#1337EC).
class AppColors {
  AppColors._(); // Không cho phép khởi tạo instance

  // ── Màu nền (Light Theme) ──
  static const Color scaffoldBackground = Color(0xFFF6F6F8); // Nền xám nhạt
  static const Color cardBackground = Color(0xFFFFFFFF); // Thẻ trắng
  static const Color surfaceLight = Color(0xFFF0F0F4);

  // ── Màu chính (Primary) ──
  static const Color primary = Color(0xFF1337EC); // Xanh đậm chủ đạo
  static const Color primaryLight = Color(0xFF4A6AFF);
  static const Color primaryDark = Color(0xFF0A1FAA);

  // ── Màu text ──
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textHint = Color(0xFF64748B); // Slate 500
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Màu cho các nút đánh giá Flashcard (SRS) ──
  static const Color buttonForgot = Color(0xFFEF4444); // Red 500
  static const Color buttonHard = Color(0xFFF59E0B); // Amber 500
  static const Color buttonGood = Color(0xFF3B82F6); // Blue 500
  static const Color buttonEasy = Color(0xFF0EA5E9); // Sky 500

  // ── Màu nền nhạt cho nút SRS ──
  static const Color buttonForgotBg = Color(0xFFFEF2F2); // Red 50
  static const Color buttonHardBg = Color(0xFFFFFBEB); // Amber 50
  static const Color buttonGoodBg = Color(0xFFEFF6FF); // Blue 50
  static const Color buttonEasyBg = Color(0xFFF0F9FF); // Sky 50

  // ── Màu viền cho nút SRS ──
  static const Color buttonForgotBorder = Color(0xFFFEE2E2); // Red 100
  static const Color buttonHardBorder = Color(0xFFFDE68A); // Amber 200
  static const Color buttonGoodBorder = Color(0xFFBFDBFE); // Blue 200
  static const Color buttonEasyBorder = Color(0xFFBAE6FD); // Sky 200

  // ── Màu phụ trợ ──
  static const Color divider = Color(0xFFE2E8F0); // Slate 200
  static const Color progressTrack = Color(0xFFE2E8F0); // Slate 200
  static const Color shadow = Color(0x14000000); // rgba(0,0,0,0.08)
  static const Color cardBorder = Color(0xFFFFFFFF);
  static const Color imageOverlay = Color(0xFFF8FAFC); // Slate 50
}
