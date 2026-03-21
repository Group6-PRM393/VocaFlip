import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';

class LearningProgressHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;

  const LearningProgressHeader({
    super.key,
    required this.userName,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Learning Progress',
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.authHeroBg,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarFallback(),
                  )
                : _avatarFallback(),
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback() {
    final c = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        c,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
