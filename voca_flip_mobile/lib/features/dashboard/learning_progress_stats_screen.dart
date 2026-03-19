import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';

class LearningProgressStatsScreen extends StatefulWidget {
  const LearningProgressStatsScreen({super.key});

  @override
  State<LearningProgressStatsScreen> createState() =>
      _LearningProgressStatsScreenState();
}

class _LearningProgressStatsScreenState
    extends State<LearningProgressStatsScreen> {
  static DateTime? _lastCacheAt;
  static Map<String, dynamic>? _cachedSnapshot;

  bool _loading = true;
  String? _error;

  String _userName = 'User';
  String? _avatarUrl;

  int _streakDays = 0;
  String _totalStudyTime = '0m';
  double _accuracyPercent = 0;

  int _totalWords = 0;
  int _mastered = 0;
  int _review = 0;
  int _learning = 0;
  int _newWords = 0;

  int _thisMonthActivity = 0;
  double _trendPercent = 0;
  List<int> _last14DaySeries = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (!force && _cachedSnapshot != null && _lastCacheAt != null) {
        final age = DateTime.now().difference(_lastCacheAt!);
        if (age.inSeconds <= 45) {
          _applySnapshot(_cachedSnapshot!);
          setState(() => _loading = false);
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final api = ApiService(prefs);

      final userRes = await api.get('/api/user/me');
      final user = Map<String, dynamic>.from(userRes.data['result'] as Map);

      _userName = user['name']?.toString() ?? 'User';
      _avatarUrl = user['avatarUrl']?.toString();

      final statsRes = await api.get('/api/stats/dashboard/me');

      final stats = Map<String, dynamic>.from(statsRes.data['result'] as Map);

      final snapshot = <String, dynamic>{
        'userName': _userName,
        'avatarUrl': _avatarUrl,
        'stats': stats,
      };

      _applySnapshot(snapshot);
      _cachedSnapshot = snapshot;
      _lastCacheAt = DateTime.now();

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _applySnapshot(Map<String, dynamic> snapshot) {
    _userName = snapshot['userName']?.toString() ?? 'User';
    _avatarUrl = snapshot['avatarUrl']?.toString();

    final stats = Map<String, dynamic>.from(snapshot['stats'] as Map);

    _streakDays = _toInt(stats['streakDays']);
    _totalStudyTime = stats['totalStudyTime']?.toString() ?? '0m';
    _accuracyPercent = _toDouble(stats['accuracyPercent']);

    final masteryRaw = (stats['wordMastery'] is Map)
        ? Map<String, dynamic>.from(stats['wordMastery'] as Map)
        : <String, dynamic>{};

    _mastered = _toInt(masteryRaw['MASTERED']);
    _review = _toInt(masteryRaw['REVIEW']);
    _learning = _toInt(masteryRaw['LEARNING']);
    _newWords = _toInt(masteryRaw['NEW']);

    final totalFromApi = _toInt(stats['totalWords']);
    _totalWords = totalFromApi > 0
        ? totalFromApi
        : (_mastered + _review + _learning + _newWords);

    final activity = (stats['activityLog'] is List)
        ? (stats['activityLog'] as List)
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : <Map<String, dynamic>>[];

    final trajectoryRaw = (stats['learningTrajectory'] is Map)
        ? Map<String, dynamic>.from(stats['learningTrajectory'] as Map)
        : <String, dynamic>{};

    _thisMonthActivity = _toInt(trajectoryRaw['currentMonthLearnedWords']);
    _trendPercent = _toDouble(trajectoryRaw['trendPercent']);

    final trajectorySeries = (trajectoryRaw['series'] is List)
        ? (trajectoryRaw['series'] as List)
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : <Map<String, dynamic>>[];

    if (trajectorySeries.isNotEmpty) {
      _last14DaySeries = _buildLast14DaysSeriesFromSeries(trajectorySeries);
    } else {
      _thisMonthActivity = _thisMonthActivity > 0
          ? _thisMonthActivity
          : _computeCurrentMonthActivity(activity);
      _last14DaySeries = _buildLast14DaysSeries(activity);
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  int _computeCurrentMonthActivity(List<Map<String, dynamic>> activity) {
    final now = DateTime.now();
    var total = 0;
    for (final item in activity) {
      final date = DateTime.tryParse(item['date']?.toString() ?? '');
      if (date == null) continue;
      if (date.year == now.year && date.month == now.month) {
        total += _toInt(item['count']);
      }
    }
    return total;
  }

  List<int> _buildLast14DaysSeries(List<Map<String, dynamic>> activity) {
    final byDate = <String, int>{};
    for (final item in activity) {
      final date = item['date']?.toString();
      if (date == null || date.isEmpty) continue;
      byDate[date] = _toInt(item['count']);
    }

    final today = DateTime.now();
    final result = <int>[];
    for (var i = 13; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final key = _yyyyMmDd(day);
      result.add(byDate[key] ?? 0);
    }
    return result;
  }

  List<int> _buildLast14DaysSeriesFromSeries(
    List<Map<String, dynamic>> series,
  ) {
    final byDate = <String, int>{};
    for (final point in series) {
      final date = point['date']?.toString();
      if (date == null || date.isEmpty) continue;
      byDate[date] = _toInt(point['value']);
    }

    final today = DateTime.now();
    final result = <int>[];
    for (var i = 13; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final key = _yyyyMmDd(day);
      result.add(byDate[key] ?? 0);
    }
    return result;
  }

  String _yyyyMmDd(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(force: true),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildTopStats(),
          const SizedBox(height: 18),
          _buildWordMasteryCard(),
          const SizedBox(height: 18),
          _buildActivityTrendCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
            child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                ? Image.network(
                    _avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                  )
                : _buildAvatarFallback(),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback() {
    final c = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';
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

  Widget _buildTopStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.local_fire_department,
            label: 'STREAK',
            value: '$_streakDays Days',
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.schedule,
            label: 'TIME',
            value: _totalStudyTime,
            iconColor: AppColors.buttonEasy,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.ads_click,
            label: 'ACCURACY',
            value: '${_accuracyPercent.toStringAsFixed(1)}%',
            iconColor: AppColors.primaryLight,
            helperText: 'Remembered / Total answers',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    String? helperText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (helperText != null) ...[
            const SizedBox(height: 2),
            Text(
              helperText,
              style: AppTextStyles.caption.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWordMasteryCard() {
    final total = _totalWords <= 0 ? 1 : _totalWords;
    final masteredPercent = (_mastered / total) * 100;
    final reviewPercent = (_review / total) * 100;
    final learningPercent = (_learning / total) * 100;
    final newPercent = (_newWords / total) * 100;

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
            'Word Mastery',
            style: AppTextStyles.heading2.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          _masteryDonutChart(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _masteryInfo(
                  'Mastered',
                  _mastered,
                  masteredPercent,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _masteryInfo(
                  'Review',
                  _review,
                  reviewPercent,
                  AppColors.buttonGood,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _masteryInfo(
                  'Learning',
                  _learning,
                  learningPercent,
                  AppColors.buttonEasy,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _masteryInfo(
                  'New',
                  _newWords,
                  newPercent,
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _masteryDonutChart() {
    return Center(
      child: SizedBox(
        width: 170,
        height: 170,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(170, 170),
              painter: _WordMasteryDonutPainter(
                values: [_mastered, _review, _learning, _newWords],
                colors: const [
                  AppColors.primary,
                  AppColors.buttonGood,
                  AppColors.buttonEasy,
                  AppColors.textSecondary,
                ],
                emptyColor: AppColors.imageOverlay,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_totalWords',
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'TOTAL WORDS',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _masteryInfo(String label, int count, double percent, Color dotColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.imageOverlay,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$count',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: dotColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: dotColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTrendCard() {
    final maxValue = _last14DaySeries.isEmpty
        ? 1
        : _last14DaySeries.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);

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
                '+$_thisMonthActivity',
                style: AppTextStyles.heading1.copyWith(fontSize: 32),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _trendPercent >= 0
                      ? AppColors.buttonEasyBg
                      : AppColors.buttonForgotBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_trendPercent >= 0 ? '+' : ''}${_trendPercent.toStringAsFixed(1)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: _trendPercent >= 0
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
            child: _last14DaySeries.isEmpty
                ? Center(
                    child: Text(
                      'No activity data',
                      style: AppTextStyles.caption,
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final value in _last14DaySeries)
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

class _WordMasteryDonutPainter extends CustomPainter {
  final List<int> values;
  final List<Color> colors;
  final Color emptyColor;

  _WordMasteryDonutPainter({
    required this.values,
    required this.colors,
    required this.emptyColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (sum, value) => sum + value);
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 20.0;
    final radius = (size.width / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = emptyColor;

    canvas.drawCircle(center, radius, trackPaint);

    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    const gap = 0.035;

    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value <= 0) continue;

      var sweep = (value / total) * (2 * math.pi);
      if (sweep > gap) {
        sweep -= gap;
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = colors[i % colors.length];

      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += (value / total) * (2 * math.pi);
    }
  }

  @override
  bool shouldRepaint(covariant _WordMasteryDonutPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.colors != colors ||
        oldDelegate.emptyColor != emptyColor;
  }
}
