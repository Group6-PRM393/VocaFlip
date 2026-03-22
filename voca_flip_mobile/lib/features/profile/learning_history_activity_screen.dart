import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';

class LearningHistoryActivityScreen extends StatelessWidget {
  const LearningHistoryActivityScreen({super.key});

  static const _horizontalPadding = 16.0;

  static const List<_HistoryStat> _stats = [
    _HistoryStat(
      value: '12',
      label: 'STREAK 🔥',
      valueColor: AppColors.primary,
    ),
    _HistoryStat(value: '2.4k', label: 'LEARNED'),
    _HistoryStat(value: '85%', label: 'RETENTION'),
  ];

  static const List<_HistoryActivity> _activities = [
    _HistoryActivity(
      icon: Icons.menu_book_rounded,
      iconBg: AppColors.authHeroBg,
      iconColor: AppColors.primary,
      title: 'Daily Review',
      subtitle: '120 Cards Reviewed',
      duration: '45m',
      date: 'Yesterday',
    ),
    _HistoryActivity(
      icon: Icons.style_rounded,
      iconBg: Color(0xFFDCFCE7),
      iconColor: Color(0xFF059669),
      title: 'Flashcard Quiz',
      subtitle: '30 Cards • Perfect Score',
      duration: '15m',
      date: 'Oct 22',
    ),
    _HistoryActivity(
      icon: Icons.add_circle_rounded,
      iconBg: Color(0xFFEDE9FE),
      iconColor: Color(0xFF7C3AED),
      title: 'New Vocabulary',
      subtitle: '15 New Words Added',
      duration: '10m',
      date: 'Oct 20',
    ),
    _HistoryActivity(
      icon: Icons.hotel_class_rounded,
      iconBg: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
      title: 'Level Up!',
      subtitle: 'Intermediate II Reached',
      duration: '-',
      date: 'Oct 18',
    ),
  ];

  Widget _buildStatCard(_HistoryStat stat) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              stat.value,
              style: AppTextStyles.heading2.copyWith(
                fontSize: 24,
                color: stat.valueColor ?? AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.heading2),
          if (trailing != null) ...[const Spacer(), trailing],
        ],
      ),
    );
  }

  Widget _buildActivityCard(_HistoryActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: activity.iconBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(activity.icon, color: activity.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.duration,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(activity.date, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        centerTitle: true,
        // leading: IconButton(
        //   onPressed: () => Navigator.of(context).pop(),
        //   icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        // ),
        title: Text('Learning History', style: AppTextStyles.authHeroTitle),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                ),
                child: Row(
                  children: [
                    _buildStatCard(_stats[0]),
                    const SizedBox(width: 10),
                    _buildStatCard(_stats[1]),
                    const SizedBox(width: 10),
                    _buildStatCard(_stats[2]),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionHeader(
                title: 'Recent Activities',
                trailing: TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                ),
                child: Column(
                  children: _activities.map(_buildActivityCard).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryStat {
  final String value;
  final String label;
  final Color? valueColor;

  const _HistoryStat({
    required this.value,
    required this.label,
    this.valueColor,
  });
}

class _HistoryActivity {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String duration;
  final String date;

  const _HistoryActivity({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.date,
  });
}
