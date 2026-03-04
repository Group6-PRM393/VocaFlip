import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';

class SpaceRepetitionCard extends StatelessWidget {
  final int dueCount;
  final VoidCallback onStartReview;

  const SpaceRepetitionCard({
    super.key,
    required this.dueCount,
    required this.onStartReview,
  });

  bool get _hasDueCards => dueCount > 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hasDueCards
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: _hasDueCards
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _hasDueCards
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _hasDueCards
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.divider,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _hasDueCards
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _hasDueCards
                                  ? 'READY FOR REVIEW'
                                  : 'ALL CAUGHT UP',
                              style: GoogleFonts.lexend(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: _hasDueCards
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Spaced Repetition',
                        style: GoogleFonts.lexend(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _hasDueCards
                            ? '$dueCount cards due today.'
                            : 'No cards due. Great job!',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _hasDueCards
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: _hasDueCards
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _hasDueCards ? onStartReview : null,
                icon: Icon(
                  _hasDueCards
                      ? Icons.play_arrow_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 20,
                ),
                label: Text(
                  _hasDueCards ? 'Start Review Session' : 'All Caught Up!',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _hasDueCards ? AppColors.primary : AppColors.divider,
                  foregroundColor:
                      _hasDueCards ? Colors.white : AppColors.textSecondary,
                  disabledBackgroundColor: AppColors.divider,
                  disabledForegroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _hasDueCards ? 4 : 0,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
