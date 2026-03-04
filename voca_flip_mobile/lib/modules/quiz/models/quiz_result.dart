class QuizResult {
  final String id;
  final int correctAnswers;
  final int incorrectAnswers;
  final double scorePercentage;
  final int timeTakenSeconds;

  QuizResult({
    required this.id,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.scorePercentage,
    required this.timeTakenSeconds,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'],
      correctAnswers: json['correctAnswers'],
      incorrectAnswers: json['incorrectAnswers'],
      scorePercentage: (json['scorePercentage'] as num).toDouble(),
      timeTakenSeconds: json['timeTakenSeconds'],
    );
  }
}
