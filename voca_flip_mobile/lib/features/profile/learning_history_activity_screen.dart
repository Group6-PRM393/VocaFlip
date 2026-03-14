import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';

class LearningHistoryActivityScreen extends StatelessWidget {
  const LearningHistoryActivityScreen({super.key});

  static const _horizontalPadding = 16.0;
  static const _bottomNavHeight = 64.0;
  static const _heatCellSize = 14.0;
  static const _heatCellGap = 4.0;
  static const List<String> _weekdayLabels = ['Mon', 'Wed', 'Fri'];

  static const List<_HistoryStat> _stats = [
    _HistoryStat(
      value: '12',
      label: 'STREAK 🔥',
      valueColor: AppColors.primary,
    ),
    _HistoryStat(value: '2.4k', label: 'LEARNED'),
    _HistoryStat(value: '85%', label: 'RETENTION'),
  ];

  static const List<List<int>> _heatmapData = [
    [1, 3, 2, 0, 3, 1, 0],
    [0, 0, 1, 2, 3, 3, 2],
    [3, 3, 3, 0, 0, 1, 1],
    [0, 2, 2, 3, 3, 0, 0],
    [1, 3, 2, 0, 3, 1, 0],
    [0, 0, 1, 2, 3, 3, 2],
    [3, 3, 3, 0, 0, 1, 1],
    [0, 2, 2, 3, 3, 0, 0],
    [1, 3, 2, 0, 3, 1, 0],
    [0, 0, 1, 2, 3, 3, 2],
    [3, 3, 3, 0, 0, 1, 1],
    [0, 2, 2, 3, 3, 0, 1],
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

  static const List<_BottomNavItemData> _bottomNavItems = [
    _BottomNavItemData(icon: Icons.home_rounded, label: 'Home'),
    _BottomNavItemData(icon: Icons.bar_chart_rounded, label: 'Stats'),
    _BottomNavItemData(
      icon: Icons.history_rounded,
      label: 'History',
      active: true,
    ),
    _BottomNavItemData(icon: Icons.person_rounded, label: 'Profile'),
  ];

  Color _heatColor(int level) {
    switch (level) {
      case 1:
        return AppColors.primary.withValues(alpha: 0.3);
      case 2:
        return AppColors.primary.withValues(alpha: 0.6);
      case 3:
        return AppColors.primary;
      default:
        return AppColors.imageOverlay;
    }
  }

  TextStyle get _heatmapCaptionStyle =>
      AppTextStyles.caption.copyWith(fontSize: 10);

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

  Widget _buildHeatLegend() {
    return Row(
      children: [
        const Spacer(),
        Text('Less', style: _heatmapCaptionStyle),
        const SizedBox(width: 4),
        for (var i = 0; i < 4; i++) ...[
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: _heatColor(i),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
        Text('More', style: _heatmapCaptionStyle),
      ],
    );
  }

  Widget _buildHeatColumn(List<int> column) {
    return Padding(
      padding: const EdgeInsets.only(right: _heatCellGap),
      child: Column(
        children: column.map((level) {
          return Container(
            width: _heatCellSize,
            height: _heatCellSize,
            margin: const EdgeInsets.only(bottom: _heatCellGap),
            decoration: BoxDecoration(
              color: _heatColor(level),
              borderRadius: BorderRadius.circular(3),
              border: level == 0
                  ? Border.all(color: AppColors.inputBorder)
                  : null,
            ),
          );
        }).toList(),
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

  Widget _buildStudyActivityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Study Activity',
                style: AppTextStyles.heading2.copyWith(fontSize: 20),
              ),
              Expanded(child: _buildHeatLegend()),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 116,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _weekdayLabels
                      .map((label) => Text(label, style: _heatmapCaptionStyle))
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _heatmapData.map(_buildHeatColumn).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "You've studied 80% of the last 30 days. Keep it up!",
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
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

  Widget _buildBottomNav() {
    return Container(
      height: _bottomNavHeight,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.inputBorder)),
      ),
      child: Row(
        children: _bottomNavItems
            .map((item) => _BottomNavItem(item: item))
            .toList(),
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
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text('Learning History', style: AppTextStyles.authTopBarTitle),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
              const SizedBox(height: 16),
              _buildStudyActivityCard(),
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

class _BottomNavItem extends StatelessWidget {
  final _BottomNavItemData item;

  const _BottomNavItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.active ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () {},
        child: SizedBox(
          height: LearningHistoryActivityScreen._bottomNavHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: color,
                  fontWeight: item.active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItemData {
  final IconData icon;
  final String label;
  final bool active;

  const _BottomNavItemData({
    required this.icon,
    required this.label,
    this.active = false,
  });
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
