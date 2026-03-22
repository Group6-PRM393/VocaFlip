import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';

class FlipMatchGameStatusCard extends StatelessWidget {
  const FlipMatchGameStatusCard({
    super.key,
    required this.elapsedSeconds,
    required this.moves,
    required this.score,
    required this.formatDuration,
  });

  final int elapsedSeconds;
  final int moves;
  final int score;
  final String Function(int seconds) formatDuration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FlipStatusItem(
              icon: Icons.timer_rounded,
              label: 'TIMER',
              value: formatDuration(elapsedSeconds),
              iconBg: const Color(0xFFDCE7FF),
              valueColor: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 38, color: const Color(0xFFCFD8F5)),
          Expanded(
            child: _FlipStatusItem(
              icon: Icons.ads_click_rounded,
              label: 'MOVES',
              value: moves.toString(),
              iconBg: const Color(0xFFF0DBFF),
              valueColor: const Color(0xFF9C33C7),
            ),
          ),
          Container(width: 1, height: 38, color: const Color(0xFFCFD8F5)),
          Expanded(
            child: _FlipStatusItem(
              icon: Icons.workspace_premium_rounded,
              label: 'SCORE',
              value: score.toString(),
              iconBg: const Color(0xFFFFE8C6),
              valueColor: const Color(0xFFC97A00),
            ),
          ),
        ],
      ),
    );
  }
}

class FlipMatchFinishedCard extends StatelessWidget {
  const FlipMatchFinishedCard({
    super.key,
    required this.activeCardCount,
    required this.moves,
    required this.elapsedSeconds,
    required this.lastScore,
    required this.formatDuration,
    required this.onPlayAgain,
    required this.onBackToDecks,
  });

  final int activeCardCount;
  final int moves;
  final int elapsedSeconds;
  final int lastScore;
  final String Function(int seconds) formatDuration;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToDecks;

  @override
  Widget build(BuildContext context) {
    final pairCount = math.max(1, activeCardCount ~/ 2);
    final accuracy = ((pairCount / math.max(moves, pairCount)) * 100)
        .round()
        .clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E0FF)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Great run!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF202B47),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Time ${formatDuration(elapsedSeconds)} • Score $lastScore • Accuracy $accuracy%',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF626C89),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPlayAgain,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Play Again'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBackToDecks,
                  icon: const Icon(Icons.view_carousel_rounded),
                  label: const Text('Back to Decks'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FlipMatchStartButtonBar extends StatelessWidget {
  const FlipMatchStartButtonBar({
    super.key,
    required this.startingGame,
    required this.hasDecks,
    required this.onStart,
  });

  final bool startingGame;
  final bool hasDecks;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SizedBox(
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A4ED6), Color(0xFF4D84FF)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: FilledButton.icon(
              onPressed: startingGame || !hasDecks ? null : onStart,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              icon: startingGame
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(
                startingGame ? 'Preparing...' : 'Start Game',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlipStatusItem extends StatelessWidget {
  const _FlipStatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBg,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconBg;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: valueColor),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7680A0),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
