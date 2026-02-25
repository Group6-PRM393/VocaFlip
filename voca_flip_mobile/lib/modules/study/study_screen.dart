import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import 'study_notifier.dart';
import 'study_result_screen.dart';
import 'widgets/flashcard_front_side.dart';
import 'widgets/flashcard_back_side.dart';

import '../../data/models/responses/study_session_response.dart';

class StudyScreen extends StatefulWidget {
  final String? deckId;

  /// Du lieu session da tao san (VD: tu daily-review).
  /// Neu co gia tri, se dung truc tiep thay vi goi API start.
  final StudySessionResponse? sessionData;

  const StudyScreen({super.key, this.deckId, this.sessionData});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  StudyNotifier? _notifier;

  final GlobalKey<FlipCardState> _flipCardKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final notifier = StudyNotifier(prefs);
    notifier.addListener(_onStateChanged);

    setState(() {
      _notifier = notifier;
    });

    if (widget.sessionData != null) {
      // study due cards
      notifier.loadFromResponse(widget.sessionData!);
    } else if (widget.deckId != null) {
      //study deck
      notifier.startSession(widget.deckId!);
    }
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onStateChanged);
    _notifier?.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    final n = _notifier;
    if (n == null) return;

    if (n.status == StudyStatus.completed) {
      _navigateToResult(n);
      return;
    }

    setState(() {});
  }

  void _navigateToResult(StudyNotifier n) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => StudyResultScreen(
          forgotCount: n.forgotCount,
          rememberedCount: n.rememberedCount,
          accuracy: n.accuracy,
          deckId: widget.deckId,
        ),
      ),
    );
  }

  void _onCardFlip(bool isFront) {
    _notifier?.onCardFlip(isFront);
  }

  void _onSrsRating(int grade) async {
    final n = _notifier;
    if (n == null) return;

    await n.submitRating(grade);

    if (n.status == StudyStatus.studying) {
      final flipCardState = _flipCardKey.currentState;
      if (flipCardState != null && !flipCardState.isFront) {
        flipCardState.toggleCard();
      }
    }
  }

  /// diaglog for exit
  Future<void> _showExitConfirmation() async {
    final n = _notifier;

    if (n == null || n.session == null) {
      Navigator.of(context).pop();
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Study Session?'),
        content: const Text(
          'Your learning progress will be saved. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continue studying'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      await n.forceCompleteSession();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = _notifier;

    if (n == null || n.status == StudyStatus.loading) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (n.status == StudyStatus.error) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Không thể bắt đầu phiên học',
                  style: AppTextStyles.headerLabel,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  n.errorMessage ?? 'Lỗi không xác định',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (widget.deckId != null) {
                      n.startSession(widget.deckId!);
                    }
                  },
                  child: const Text('Thử lại'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (n.status == StudyStatus.initial || n.currentCard == null) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: const Center(child: Text('Chưa có dữ liệu phiên học')),
      );
    }

    final currentCard = n.currentCard!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressSection(n.progress),
            Expanded(
              child: Center(
                child: FlipCard(
                  key: _flipCardKey,
                  direction: FlipDirection.HORIZONTAL,
                  speed: 400,
                  onFlipDone: _onCardFlip,
                  front: FlashcardFrontSide(card: currentCard),
                  back: FlashcardBackSide(card: currentCard),
                ),
              ),
            ),
            if (n.isFlipped) _buildSrsButtons(n) else const SizedBox.shrink(),
            if (n.isFlipped) const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildIconButton(Icons.close_rounded, () => _showExitConfirmation()),
          Expanded(
            child: Text(
              'STUDY SESSION',
              textAlign: TextAlign.center,
              style: AppTextStyles.headerLabel.copyWith(
                fontSize: 18,
                letterSpacing: 1.5,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, size: 24, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildProgressSection(double progress) {
    final n = _notifier!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PROGRESS', style: AppTextStyles.progressLabel),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${n.currentIndex + 1} ',
                      style: AppTextStyles.progressCounter,
                    ),
                    TextSpan(
                      text: '/ ${n.totalCards}',
                      style: AppTextStyles.progressCounter.copyWith(
                        color: AppColors.divider,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppColors.progressTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSrsButtons(StudyNotifier n) {
    final isSubmitting = n.status == StudyStatus.submitting;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: isSubmitting
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Row(
              children: [
                _buildSrsButton(
                  label: 'Forgot',
                  textColor: AppColors.buttonForgot,
                  bgColor: AppColors.buttonForgotBg,
                  borderColor: AppColors.buttonForgotBorder,
                  onTap: () => _onSrsRating(0),
                ),
                const SizedBox(width: 10),
                _buildSrsButton(
                  label: 'Hard',
                  textColor: AppColors.buttonHard,
                  bgColor: AppColors.buttonHardBg,
                  borderColor: AppColors.buttonHardBorder,
                  onTap: () => _onSrsRating(1),
                ),
                const SizedBox(width: 10),
                _buildSrsButton(
                  label: 'Good',
                  textColor: AppColors.buttonGood,
                  bgColor: AppColors.buttonGoodBg,
                  borderColor: AppColors.buttonGoodBorder,
                  onTap: () => _onSrsRating(2),
                ),
                const SizedBox(width: 10),
                _buildSrsButton(
                  label: 'Easy',
                  textColor: AppColors.buttonEasy,
                  bgColor: AppColors.buttonEasyBg,
                  borderColor: AppColors.buttonEasyBorder,
                  onTap: () => _onSrsRating(3),
                ),
              ],
            ),
    );
  }

  Widget _buildSrsButton({
    required String label,
    required Color textColor,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
