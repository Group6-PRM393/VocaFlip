import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/features/game/models/flip_match_models.dart';

class FlipDifficultyOption {
  const FlipDifficultyOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.gridLabel,
    required this.cardCount,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final String gridLabel;
  final int cardCount;
  final IconData icon;
}

class FlipDeckSelectorSection extends StatelessWidget {
  const FlipDeckSelectorSection({
    super.key,
    required this.decks,
    required this.selectedDeckIndex,
    required this.showingDeckEnd,
    required this.scrollController,
    required this.onToggleViewAllDecks,
    required this.onSelectDeck,
  });

  final List<FlipGameDeck> decks;
  final int selectedDeckIndex;
  final bool showingDeckEnd;
  final ScrollController scrollController;
  final VoidCallback onToggleViewAllDecks;
  final ValueChanged<int> onSelectDeck;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Select Deck',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF27324D),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onToggleViewAllDecks,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  showingDeckEnd ? 'Back' : 'View All',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 206,
          child: ListView.separated(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: decks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final deck = decks[index];
              final isSelected = selectedDeckIndex == index;

              return GestureDetector(
                onTap: () => onSelectDeck(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFD6E0FF),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: 110,
                          width: double.infinity,
                          child: deck.coverImageUrl != null
                              ? Image.network(
                                  deck.coverImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFE6ECFF),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported_rounded,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFFE6ECFF),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.layers_rounded,
                                    color: AppColors.textHint,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        deck.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2A45),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${deck.totalCards} Cards',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7D869F),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FlipDifficultySection extends StatelessWidget {
  const FlipDifficultySection({
    super.key,
    required this.hint,
    required this.options,
    required this.selectedOptionId,
    required this.isOptionSupported,
    required this.onSelectOption,
  });

  final String hint;
  final List<FlipDifficultyOption> options;
  final String selectedOptionId;
  final bool Function(FlipDifficultyOption option) isOptionSupported;
  final ValueChanged<FlipDifficultyOption> onSelectOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty Level',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF27324D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF66718E),
          ),
        ),
        const SizedBox(height: 10),
        ...options.map(
          (option) => FlipDifficultyOptionTile(
            option: option,
            supported: isOptionSupported(option),
            selected: option.id == selectedOptionId && isOptionSupported(option),
            onTap: () => onSelectOption(option),
          ),
        ),
      ],
    );
  }
}

class FlipDifficultyOptionTile extends StatelessWidget {
  const FlipDifficultyOptionTile({
    super.key,
    required this.option,
    required this.supported,
    required this.selected,
    required this.onTap,
  });

  final FlipDifficultyOption option;
  final bool supported;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: supported ? Colors.white : const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (supported
                        ? const Color(0xFFD8E0F5)
                        : const Color(0xFFE2E5EF)),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: !supported
                    ? Colors.transparent
                    : selected
                    ? AppColors.primary.withValues(alpha: 0.13)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: selected ? 20 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Opacity(
            opacity: supported ? 1 : 0.62,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFE8EEFF),
                  ),
                  child: Icon(
                    option.icon,
                    size: 18,
                    color: selected ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            option.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B233A),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFDCE7FF)
                                  : const Color(0xFFF0F3FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              supported
                                  ? option.gridLabel
                                  : 'Need ${option.cardCount} Cards',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? const Color(0xFF1136A8)
                                    : const Color(0xFF66718E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        option.subtitle,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF66718E),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFFB6BED6),
                      width: 1.6,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.circle, size: 8, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FlipPastPerformanceCard extends StatelessWidget {
  const FlipPastPerformanceCard({
    super.key,
    required this.history,
    required this.summary,
    required this.formatDuration,
  });

  final List<FlipScoreHistoryEntry> history;
  final FlipGameSummary summary;
  final String Function(int seconds) formatDuration;

  @override
  Widget build(BuildContext context) {
    final bestSeconds = history.isEmpty
        ? null
        : history.map((entry) => entry.seconds).reduce((a, b) => a < b ? a : b);

    final bestAccuracy = history
        .map((entry) {
          final pairs = math.max(1, entry.cardCount ~/ 2);
          final moves = math.max(pairs, entry.moves);
          return (pairs / moves) * 100;
        })
        .fold<double>(0, math.max);

    final fallbackTop3 = ([...history]..sort((a, b) => b.score.compareTo(a.score)))
        .take(3)
        .map((entry) => entry.score)
        .toList();
    final top3Scores = summary.top3Scores.isNotEmpty
        ? summary.top3Scores
        : fallbackTop3;

    String scoreAt(int index) {
      if (index >= top3Scores.length) return '--';
      return top3Scores[index].toString();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Past Performance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B2440),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FlipStatBox(
                  label: 'BEST TIME',
                  value: bestSeconds == null ? '--:--' : formatDuration(bestSeconds),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FlipStatBox(
                  label: 'ACCURACY',
                  value: bestAccuracy == 0
                      ? '-- %'
                      : '${bestAccuracy.round().clamp(0, 100)} %',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _FlipStatBox(label: 'TOP 1', value: scoreAt(0))),
              const SizedBox(width: 10),
              Expanded(child: _FlipStatBox(label: 'TOP 2', value: scoreAt(1))),
              const SizedBox(width: 10),
              Expanded(child: _FlipStatBox(label: 'TOP 3', value: scoreAt(2))),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlipStatBox extends StatelessWidget {
  const _FlipStatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF7E89A7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1D2642),
            ),
          ),
        ],
      ),
    );
  }
}
