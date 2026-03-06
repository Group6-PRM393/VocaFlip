import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';

class LoginHeroSection extends StatelessWidget {
  const LoginHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: const BoxDecoration(
        color: AppColors.authHeroBg, // bg-blue-50
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.authHeroAccent1.withValues(alpha: 0.5), // blue-100/50
                    Colors.white.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
            ),
          ),
          
          Positioned(
            top: -16,
            left: -16,
            child: _PhoneticSymbol('ə', size: 128, color: AppColors.authHeroAccent2.withValues(alpha: 0.2), angle: 0.2),
          ),
          Positioned(
            top: 48,
            right: -32,
            child: _PhoneticSymbol('æ', size: 96, color: AppColors.splashBgLight.withValues(alpha: 0.15), angle: -0.2),
          ),
          Positioned(
            top: 130,
            left: 32,
            child: _PhoneticSymbol('θ', size: 72, color: AppColors.authHeroAccent3.withValues(alpha: 0.3), angle: 0.78),
          ),
          Positioned(
            bottom: 48,
            right: 64,
            child: _PhoneticSymbol('ʊ', size: 96, color: AppColors.authHeroAccent2.withValues(alpha: 0.2), angle: -0.1),
          ),
          Positioned(
            top: 80,
            left: MediaQuery.of(context).size.width * 0.4,
            child: _PhoneticSymbol('dʒ', size: 60, color: AppColors.authHeroAccent3.withValues(alpha: 0.25), angle: 0.26),
          ),
          Positioned(
            bottom: 16,
            left: -16,
            child: _PhoneticSymbol('ŋ', size: 96, color: AppColors.authHeroAccent4.withValues(alpha: 0.4), angle: -0.17),
          ),
          Positioned(
            top: 16,
            right: MediaQuery.of(context).size.width * 0.3,
            child: _PhoneticSymbol('ʃ', size: 72, color: const Color(0xFFC7D2FE).withValues(alpha: 0.3), angle: 0.2),
          ),
          Positioned(
            top: 156,
            right: -16,
            child: _PhoneticSymbol('ð', size: 96, color: AppColors.authHeroAccent3.withValues(alpha: 0.2), angle: 0.34),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.authHeroAccent4.withValues(alpha: 0.1), // blue-200/10
                    AppColors.authHeroBg.withValues(alpha: 0.1), // blue-50/10
                    Colors.white.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
            ),
          ),
          
          Positioned(
            left: 24,
            bottom: 24,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.style_rounded, color: AppColors.primary, size: 36),
                      const SizedBox(width: 8),
                      Text(
                        'VocaFlip',
                        style: AppTextStyles.authHeroTitle.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Master vocabulary, one flip at a time.',
                      style: AppTextStyles.authHeroSubtitle.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.googleText, // text-slate-700
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneticSymbol extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final double angle;

  const _PhoneticSymbol(this.text, {
    required this.size,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
