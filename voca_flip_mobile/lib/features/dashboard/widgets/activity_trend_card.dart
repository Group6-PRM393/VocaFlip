import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';

class ActivityTrendCard extends StatelessWidget {
  final int thisMonthActivity;
  final double trendPercent;
  final List<int> last14DaySeries;

  const ActivityTrendCard({
    super.key,
    required this.thisMonthActivity,
    required this.trendPercent,
    required this.last14DaySeries,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = last14DaySeries.isEmpty
        ? 1
        : last14DaySeries.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Trajectory',
            style: AppTextStyles.heading2.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text('Words learned trend', style: AppTextStyles.caption),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '+$thisMonthActivity',
                style: AppTextStyles.heading1.copyWith(fontSize: 32),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendPercent >= 0
                      ? AppColors.buttonEasyBg
                      : AppColors.buttonForgotBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${trendPercent >= 0 ? '+' : ''}${trendPercent.toStringAsFixed(1)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: trendPercent >= 0
                        ? AppColors.buttonEasy
                        : AppColors.buttonForgot,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Text('Words learned this month', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: last14DaySeries.isEmpty
                ? Center(
                    child: Text(
                      'No activity data',
                      style: AppTextStyles.caption,
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final value in last14DaySeries)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 1.5,
                            ),
                            child: Container(
                              height: 8 + (value / maxValue) * 96,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '14 days ago',
                style: AppTextStyles.caption.copyWith(fontSize: 10),
              ),
              Text(
                'Today',
                style: AppTextStyles.caption.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
