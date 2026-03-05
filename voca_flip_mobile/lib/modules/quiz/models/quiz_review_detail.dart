class QuizReviewDetail {
  final String questionText;
  final String userAnswerText;
  final String correctAnswerText;
  final bool isCorrect;

  QuizReviewDetail({
    required this.questionText,
    required this.userAnswerText,
    required this.correctAnswerText,
    required this.isCorrect,
  });

  factory QuizReviewDetail.fromJson(Map<String, dynamic> json) {
    return QuizReviewDetail(
      questionText: json['questionText'],
      userAnswerText: json['userAnswerText'] ?? 'No Answer',
      correctAnswerText: json['correctAnswerText'],
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}
