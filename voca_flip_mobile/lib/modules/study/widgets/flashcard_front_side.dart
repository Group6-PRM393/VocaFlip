import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../data/models/responses/study_card_response.dart';


class FlashcardFrontSide extends StatelessWidget {
  final StudyCardResponse card;
  final VoidCallback? onTap;

  const FlashcardFrontSide({super.key, required this.card, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 50,
              offset: Offset(0, 20),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildTermContent(),
              _buildTapHintLabel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          card.front,
          style: AppTextStyles.flashcardTerm,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

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
