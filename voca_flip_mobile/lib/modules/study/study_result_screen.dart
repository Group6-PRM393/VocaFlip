import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import 'study_screen.dart';

class StudyResultScreen extends StatelessWidget {
  final int forgotCount;

  final int rememberedCount;

  final double accuracy;

  final String? deckId;

  const StudyResultScreen({
    super.key,
    required this.forgotCount,
    required this.rememberedCount,
    required this.accuracy,
    this.deckId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerRight,
                child: _buildCloseButton(context),
              ),

              const Spacer(flex: 2),

              _buildCelebrationIcon(),
              const SizedBox(height: 24),

              Text(
                'Great Job!',
                style: GoogleFonts.lexend(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Deck Completed!',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              _buildStatsRow(),

              const Spacer(flex: 3),

              _buildStudyAgainButton(context),
              const SizedBox(height: 12),
              _buildBackToHomeButton(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 20,
            color: AppColors.textHint,
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primaryLight.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.emoji_events_rounded,
        size: 48,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              value: forgotCount.toString(),
              label: 'Forgot',
              valueColor: AppColors.buttonForgot,
            ),
          ),
          Container(width: 1, height: 48, color: AppColors.divider),
          Expanded(
            child: _buildStatItem(
              value: rememberedCount.toString(),
              label: 'Remembered',
              valueColor: Colors.green,
            ),
          ),
          Container(width: 1, height: 48, color: AppColors.divider),
          Expanded(
            child: _buildStatItem(
              value: '${accuracy.toStringAsFixed(0)}%',
              label: 'Accuracy',
              valueColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStudyAgainButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // Tạo phiên học mới cho cùng deck
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => StudyScreen(deckId: deckId)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Study Again',
          style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBackToHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          elevation: 0,
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Back to Home',
          style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
