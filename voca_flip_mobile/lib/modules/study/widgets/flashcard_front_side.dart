import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../data/models/card_model.dart';

/// Widget hiển thị mặt trước (Front Side) của thẻ Flashcard.
///
/// Theo design Stitch (VocaFlip Screen - Light Theme):
/// - Thẻ trắng nền sáng, bo góc lớn 40px (2.5rem).
/// - Shadow nhẹ tạo độ nổi tinh tế.
/// - Term hiển thị giữa thẻ, font Lexend bold, màu primary (#1337EC).
/// - Gradient mờ ở đáy thẻ tạo chiều sâu.
/// - Layout tối giản — không có icon phụ.
class FlashcardFrontSide extends StatelessWidget {
  /// Dữ liệu thẻ cần hiển thị
  final FlashcardModel card;

  /// Callback khi người dùng tap vào thẻ để lật
  final VoidCallback? onTap;

  const FlashcardFrontSide({super.key, required this.card, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        // Tỉ lệ 3:4 theo design (aspect ratio)
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          // Nền trắng cho thẻ
          color: AppColors.cardBackground,
          // Bo góc lớn 40px theo design Stitch
          borderRadius: BorderRadius.circular(40),
          // Shadow nhẹ — rgba(0,0,0,0.08) theo design
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 50,
              offset: Offset(0, 20),
              spreadRadius: 0,
            ),
          ],
          // Viền trắng tinh tế
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Stack(
            fit: StackFit.expand, // Bắt buộc Stack lấp đầy Container
            children: [
              // ── Nội dung chính: Term ──
              // Sử dụng Align hoặc Center trực tiếp trong Stack
              _buildTermContent(),

              // ── Hướng dẫn "Tap to flip" ở đáy thẻ ──
              _buildTapHintLabel(),
            ],
          ),
        ),
      ),
    );
  }

  /// Nội dung chính — Term ở giữa thẻ
  Widget _buildTermContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          card.term,
          style: AppTextStyles.flashcardTerm,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Dòng chữ hướng dẫn ở đáy thẻ
  Widget _buildTapHintLabel() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          'Tap to flip',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textHint.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
