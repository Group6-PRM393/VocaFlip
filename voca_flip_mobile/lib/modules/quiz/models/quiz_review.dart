import 'quiz_review_detail.dart';

class QuizReview {
  final double scorePercentage;
  final List<QuizReviewDetail> details;

  QuizReview({required this.scorePercentage, required this.details});

  factory QuizReview.fromJson(Map<String, dynamic> json) {
    return QuizReview(
      scorePercentage: (json['scorePercentage'] as num).toDouble(),
      details: (json['details'] as List)
          .map((d) => QuizReviewDetail.fromJson(d))
          .toList(),
    );
  }
}
