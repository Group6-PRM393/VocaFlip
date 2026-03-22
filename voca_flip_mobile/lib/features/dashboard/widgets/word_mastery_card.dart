import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/core/constants/app_colors.dart';
import 'package:voca_flip_mobile/core/constants/app_text_styles.dart';

class WordMasteryCard extends StatelessWidget {
  final int totalWords;
  final int mastered;
  final int review;
  final int learning;
  final int newWords;

  const WordMasteryCard({
    super.key,
    required this.totalWords,
    required this.mastered,
    required this.review,
    required this.learning,
    required this.newWords,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalWords <= 0 ? 1 : totalWords;
    final masteredPercent = (mastered / total) * 100;
    final reviewPercent = (review / total) * 100;
    final learningPercent = (learning / total) * 100;
    final newPercent = (newWords / total) * 100;

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
          _MasteryDonutChart(
            totalWords: totalWords,
            values: [mastered, review, learning, newWords],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MasteryInfo(
                  label: 'Mastered',
                  count: mastered,
                  percent: masteredPercent,
                  dotColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MasteryInfo(
                  label: 'Review',
                  count: review,
                  percent: reviewPercent,
                  dotColor: AppColors.buttonGood,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MasteryInfo(
                  label: 'Learning',
                  count: learning,
                  percent: learningPercent,
                  dotColor: AppColors.buttonEasy,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MasteryInfo(
                  label: 'New',
                  count: newWords,
                  percent: newPercent,
                  dotColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MasteryDonutChart extends StatelessWidget {
  final int totalWords;
  final List<int> values;

  const _MasteryDonutChart({required this.totalWords, required this.values});

  @override
  Widget build(BuildContext context) {
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
                values: values,
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
                  '$totalWords',
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
}

class _MasteryInfo extends StatelessWidget {
  final String label;
  final int count;
  final double percent;
  final Color dotColor;

  const _MasteryInfo({
    required this.label,
    required this.count,
    required this.percent,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
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
    const strokeWidth = 20.0;
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
