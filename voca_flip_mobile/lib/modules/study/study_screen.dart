import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../data/models/card_model.dart';
import 'study_result_screen.dart';
import 'widgets/flashcard_front_side.dart';
import 'widgets/flashcard_back_side.dart';

/// Màn hình học Flashcard (Study Session).
///
/// Theo design Stitch (Variant 899 + Back Side):
/// - Header: nút Close (trái) + "STUDY SESSION" (giữa).
/// - Progress section: Label "PROGRESS" + counter + progress bar.
/// - FlipCard: Mặt trước (term) ↔ Mặt sau (definition, IPA, example).
/// - Bottom:
///   * Chưa lật → Navigation Arrows (Back/Forward).
///   * Đã lật → SRS Rating Buttons (Forgot, Hard, Good, Easy).
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  // ── Dữ liệu mock để preview ──
  final List<FlashcardModel> _mockCards = const [
    FlashcardModel(
      id: '1',
      term: 'Serendipity',
      definition: 'Sự tình cờ may mắn',
      ipa: '/ˌser.ənˈdɪp.ə.ti/',
      example:
          'Finding this restaurant was pure serendipity, we just took a wrong turn.',
      // imageUrl:
      //     'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=400&h=300&fit=crop',
    ),
    FlashcardModel(
      id: '2',
      term: 'Ephemeral',
      definition: 'Tồn tại trong thời gian rất ngắn',
      ipa: '/ɪˈfem.ər.əl/',
      example: 'The ephemeral beauty of cherry blossoms.',
      imageUrl:
          'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=400&h=300&fit=crop',
    ),
    FlashcardModel(
      id: '3',
      term: 'Ubiquitous',
      definition: 'Có mặt ở khắp nơi',
      ipa: '/juːˈbɪk.wɪ.təs/',
      example: 'Smartphones have become ubiquitous in modern life.',
      imageUrl:
          'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400&h=300&fit=crop',
    ),
    FlashcardModel(
      id: '4',
      term: 'Resilience',
      definition: 'Khả năng phục hồi nhanh chóng',
      ipa: '/rɪˈzɪl.i.əns/',
      example: 'She showed great resilience after the setback.',
      imageUrl:
          'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400&h=300&fit=crop',
    ),
    FlashcardModel(
      id: '5',
      term: 'Pragmatic',
      definition: 'Thực tế, thiết thực',
      ipa: '/præɡˈmæt.ɪk/',
      example: 'A pragmatic approach to problem solving.',
      imageUrl:
          'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400&h=300&fit=crop',
    ),
  ];

  /// Chỉ số thẻ hiện tại
  int _currentIndex = 0;

  /// Trạng thái lật thẻ (true = đang hiện mặt sau)
  bool _isFlipped = false;

  /// Đếm số lần đánh giá Forgot và Remembered
  int _forgotCount = 0;
  int _rememberedCount = 0;

  /// Key cho FlipCard để điều khiển lật bằng code
  final GlobalKey<FlipCardState> _flipCardKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();
  }

  /// Xử lý khi tap vào thẻ → lật thẻ
  /// [isFront] = true khi thẻ vừa lật xong về mặt trước
  void _onCardFlip(bool isFront) {
    setState(() {
      _isFlipped = !isFront;
    });
  }

  /// Chuyển sang thẻ tiếp theo sau khi đánh giá SRS
  void _onSrsRating(String rating) {
    // Đếm kết quả đánh giá
    if (rating == 'forgot') {
      _forgotCount++;
    } else {
      // hard, good, easy đều tính là "remembered"
      _rememberedCount++;
    }

    // Kiểm tra đã hết thẻ chưa
    if (_currentIndex >= _mockCards.length - 1) {
      // Tính accuracy
      final total = _forgotCount + _rememberedCount;
      final accuracy = total > 0 ? (_rememberedCount / total) * 100 : 0.0;

      // Chuyển sang màn hình kết quả
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StudyResultScreen(
            forgotCount: _forgotCount,
            rememberedCount: _rememberedCount,
            accuracy: accuracy,
          ),
        ),
      );
      return;
    }

    setState(() {
      // Reset trạng thái lật
      _isFlipped = false;
      // Chuyển sang thẻ tiếp theo
      _currentIndex++;
    });

    // Reset FlipCard về mặt trước (nếu đang ở mặt sau)
    final flipCardState = _flipCardKey.currentState;
    if (flipCardState != null && !flipCardState.isFront) {
      flipCardState.toggleCard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _mockCards[_currentIndex];
    final progress = (_currentIndex + 1) / _mockCards.length;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: Close + Title ──
            _buildHeader(),

            // ── Progress Section ──
            _buildProgressSection(progress),

            // ── FlipCard (chiếm phần lớn màn hình) ──
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

            // ── Bottom Buttons ──
            // Chỉ hiện SRS Buttons khi đã lật thẻ (mặt sau)
            if (_isFlipped) _buildSrsButtons() else const SizedBox.shrink(),

            // Khoảng cách dưới cùng (chỉ khi có nút)
            if (_isFlipped) const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════

  /// Header: [Close]     STUDY SESSION     [_]
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
          // Nút Close (trái)
          _buildIconButton(Icons.close_rounded, () {
            Navigator.of(context).maybePop();
          }),

          // Tiêu đề giữa
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

          // Placeholder bên phải để cân bằng layout
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

  // ═══════════════════════════════════════════════════════════
  // PROGRESS
  // ═══════════════════════════════════════════════════════════

  Widget _buildProgressSection(double progress) {
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
                      text: '${_currentIndex + 1} ',
                      style: AppTextStyles.progressCounter,
                    ),
                    TextSpan(
                      text: '/ ${_mockCards.length}',
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

  // ═══════════════════════════════════════════════════════════
  // SRS RATING BUTTONS (Back Side)
  // ═══════════════════════════════════════════════════════════

  Widget _buildSrsButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _buildSrsButton(
            label: 'Forgot',
            textColor: AppColors.buttonForgot,
            bgColor: AppColors.buttonForgotBg,
            borderColor: AppColors.buttonForgotBorder,
            onTap: () => _onSrsRating('forgot'),
          ),
          const SizedBox(width: 10),
          _buildSrsButton(
            label: 'Hard',
            textColor: AppColors.buttonHard,
            bgColor: AppColors.buttonHardBg,
            borderColor: AppColors.buttonHardBorder,
            onTap: () => _onSrsRating('hard'),
          ),
          const SizedBox(width: 10),
          _buildSrsButton(
            label: 'Good',
            textColor: AppColors.buttonGood,
            bgColor: AppColors.buttonGoodBg,
            borderColor: AppColors.buttonGoodBorder,
            onTap: () => _onSrsRating('good'),
          ),
          const SizedBox(width: 10),
          _buildSrsButton(
            label: 'Easy',
            textColor: AppColors.buttonEasy,
            bgColor: AppColors.buttonEasyBg,
            borderColor: AppColors.buttonEasyBorder,
            onTap: () => _onSrsRating('easy'),
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
