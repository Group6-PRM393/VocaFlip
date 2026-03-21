import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';
import 'package:voca_flip_mobile/features/dashboard/widgets/activity_trend_card.dart';
import 'package:voca_flip_mobile/features/dashboard/widgets/learning_progress_header.dart';
import 'package:voca_flip_mobile/features/dashboard/widgets/learning_progress_top_stats.dart';
import 'package:voca_flip_mobile/features/dashboard/widgets/word_mastery_card.dart';

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

      final statsRes = await api.get('/api/learning-progress/me');

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

    _last14DaySeries = _buildLast14DaysSeriesFromSeries(trajectorySeries);
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
          LearningProgressHeader(userName: _userName, avatarUrl: _avatarUrl),
          const SizedBox(height: 14),
          LearningProgressTopStats(
            streakDays: _streakDays,
            totalStudyTime: _totalStudyTime,
            accuracyPercent: _accuracyPercent,
          ),
          const SizedBox(height: 18),
          WordMasteryCard(
            totalWords: _totalWords,
            mastered: _mastered,
            review: _review,
            learning: _learning,
            newWords: _newWords,
          ),
          const SizedBox(height: 18),
          ActivityTrendCard(
            thisMonthActivity: _thisMonthActivity,
            trendPercent: _trendPercent,
            last14DaySeries: _last14DaySeries,
          ),
        ],
      ),
    );
  }
}
