import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';
import 'package:voca_flip_mobile/features/game/models/flip_match_models.dart';

class FlipGameTile extends StatelessWidget {
  const FlipGameTile({super.key, required this.tile, required this.onTap});

  final FlipGameTileModel tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tile.isMatched ? null : onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: tile.isFaceUp ? 1 : 0),
        duration: const Duration(milliseconds: 260),
        builder: (context, value, child) {
          final angle = value * math.pi;
          final showFront = angle >= math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showFront
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: _faceUpContent(),
                  )
                : _faceDownContent(),
          );
        },
      ),
    );
  }

  Widget _faceDownContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.style_rounded, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'VOCAFLIP',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _faceUpContent() {
    final bool isWord = tile.side == FlipTileSide.word;
    final bool isMatched = tile.isMatched;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMatched ? const Color(0xFFEFF4FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatched
              ? AppColors.primary
              : (isWord ? const Color(0xFFBCD2FF) : const Color(0xFFD6C7FF)),
          width: isMatched ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
          if (isMatched)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.20),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isWord ? 'WORD' : 'MEANING',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: Text(
                tile.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (isMatched && !isWord) ...[
            const SizedBox(height: 6),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ],
        ],
      ),
    );
  }
}
