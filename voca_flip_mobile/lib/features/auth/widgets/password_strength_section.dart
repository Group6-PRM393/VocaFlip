import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';
import 'package:voca_flip_mobile/features/auth/utils/password_strength_utils.dart';

class PasswordStrengthSection extends StatelessWidget {
  const PasswordStrengthSection({
    super.key,
    required this.result,
    this.guideText,
  });

  final PasswordStrengthResult result;
  final String? guideText;

  Color get _strengthColor {
    switch (result.level) {
      case PasswordStrengthLevel.weak:
        return AppColors.buttonForgot;
      case PasswordStrengthLevel.medium:
        return AppColors.primary;
      case PasswordStrengthLevel.strong:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength',
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              result.label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _strengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            final isActive = index < result.score;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 4),
                decoration: BoxDecoration(
                  color: isActive ? _strengthColor : AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
        if (guideText != null) ...[
          const SizedBox(height: 8),
          Text(
            guideText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
