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
    if (tile.isMatched) {
      return IgnorePointer(
        child: AnimatedOpacity(
          opacity: 0,
          duration: const Duration(milliseconds: 180),
          child: _faceDownContent(),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
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
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.help_outline_rounded, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _faceUpContent() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tile.side == FlipTileSide.word
              ? const Color(0xFF93C5FD)
              : const Color(0xFFFDE68A),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tile.side == FlipTileSide.word ? 'WORD' : 'MEANING',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
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
        ],
      ),
    );
  }
}
