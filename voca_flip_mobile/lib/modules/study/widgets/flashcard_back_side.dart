import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../../data/models/responses/study_card_response.dart';
import '../../../data/services/tts_service.dart';

class FlashcardBackSide extends StatelessWidget {
  final StudyCardResponse card;

  const FlashcardBackSide({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 30,
            offset: Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Column(
              children: [
                if (card.imageUrl != null) _buildHeaderImage(),
                Expanded(
                  child: card.imageUrl == null
                      ? Center(child: _buildContent())
                      : _buildContent(),
                ),
              ],
            ),

            Positioned(top: 12, right: 12, child: _buildAudioButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Image.network(
        card.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildAudioButton() {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => TtsService().speak(card.phonetic!),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.volume_up_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            card.front,
            style: GoogleFonts.lexend(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          if (card.phonetic != null) ...[
            const SizedBox(height: 4),
            Text(
              card.phonetic!,
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 12),

          Container(
            width: 48,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'DEFINITION',
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            card.back,
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E293B),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          if (card.exampleSentence != null) ...[
            const SizedBox(height: 16),
            _buildExampleBox(),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildExampleBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFDBEAFE),
          width: 1,
        ),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: _buildExampleRichText(),
      ),
    );
  }

  TextSpan _buildExampleRichText() {
    final example = card.exampleSentence!;
    final termLower = card.front.toLowerCase();
    final exampleLower = example.toLowerCase();
    final termIndex = exampleLower.indexOf(termLower);

    if (termIndex == -1) {
      return TextSpan(
        text: '"$example"',
        style: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          color: const Color(0xFF475569),
          height: 1.5,
        ),
      );
    }

    final before = example.substring(0, termIndex);
    final termInExample = example.substring(
      termIndex,
      termIndex + card.front.length,
    );
    final after = example.substring(termIndex + card.front.length);

    final baseStyle = GoogleFonts.notoSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: const Color(0xFF475569),
      height: 1.5,
    );

    return TextSpan(
      children: [
        TextSpan(text: '"$before', style: baseStyle),
        TextSpan(
          text: termInExample,
          style: baseStyle.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
        ),
        TextSpan(text: '$after"', style: baseStyle),
      ],
    );
  }
}
