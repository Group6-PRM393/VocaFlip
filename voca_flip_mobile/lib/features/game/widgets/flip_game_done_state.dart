import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';

class FlipGameDoneState extends StatelessWidget {
  const FlipGameDoneState({
    super.key,
    required this.elapsedText,
    required this.scoreText,
    required this.onPlayAgain,
  });

  final String elapsedText;
  final String scoreText;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration_rounded,
            size: 36,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Text('You matched all cards!', style: AppTextStyles.heading2),
          const SizedBox(height: 6),
          Text(
            'Time: $elapsedText • Score: $scoreText',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onPlayAgain,
            child: const Text('New game'),
          ),
        ],
      ),
    );
  }
}
