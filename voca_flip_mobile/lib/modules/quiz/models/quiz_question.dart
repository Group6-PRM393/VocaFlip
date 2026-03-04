import 'quiz_option.dart';

class QuizQuestion {
  final String questionId;
  final String questionText;
  final String? audioUrl;
  final String questionType;
  final List<QuizOption> options;

  QuizQuestion({
    required this.questionId,
    required this.questionText,
    this.audioUrl,
    this.questionType = "MULTIPLE_CHOICE",
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      questionType: json['questionType'] ?? '',
      audioUrl: json['audioUrl'],
      options: json['options'] != null
          ? List<QuizOption>.from(
              json['options'].map((x) => QuizOption.fromJson(x)),
            )
          : [],
    );
  }
}
