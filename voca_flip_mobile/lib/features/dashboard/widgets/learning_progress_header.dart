import 'package:flutter/material.dart';
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
    return Text(
      'Learning Progress',
      style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
