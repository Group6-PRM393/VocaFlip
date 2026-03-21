import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';
import 'package:voca_flip_mobile/features/game/models/flip_match_models.dart';

class FlipGameTopPanel extends StatelessWidget {
  const FlipGameTopPanel({
    super.key,
    required this.elapsedText,
    required this.matchedText,
    required this.cardsText,
    required this.isFinished,
    required this.scoreText,
    required this.scoreHistory,
    required this.primaryButtonLabel,
    required this.primaryButtonIcon,
    required this.onPrimaryAction,
    required this.formatDuration,
    required this.formatDateTime,
  });

  final String elapsedText;
  final String matchedText;
  final String cardsText;
  final bool isFinished;
  final String scoreText;
  final List<FlipScoreHistoryEntry> scoreHistory;
  final String primaryButtonLabel;
  final IconData primaryButtonIcon;
  final VoidCallback onPrimaryAction;
  final String Function(int seconds) formatDuration;
  final String Function(DateTime dateTime) formatDateTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statChip('Time', elapsedText),
              _statChip('Matched', matchedText),
              _statChip('Cards', cardsText),
              if (isFinished) _statChip('Score', scoreText),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPrimaryAction,
              icon: Icon(primaryButtonIcon),
              label: Text(primaryButtonLabel),
            ),
          ),
          if (scoreHistory.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Lich su diem', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 6),
            ...scoreHistory
                .take(3)
                .map(
                  (entry) => Text(
                    '${entry.score} diem • ${entry.cardCount} the • ${formatDuration(entry.seconds)} • ${formatDateTime(entry.playedAt)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
