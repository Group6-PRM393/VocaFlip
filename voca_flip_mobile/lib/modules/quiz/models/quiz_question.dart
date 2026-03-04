import 'package:voca_flip_mobile/models/quiz/quiz_option.dart';

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
      questionId: json['questionId'],
      questionText: json['questionText'],
      audioUrl: json['audioUrl'],
      questionType: json['questionType'] ?? "MULTIPLE_CHOICE",
      options: (json['options'] as List)
          .map((o) => QuizOption.fromJson(o))
          .toList(),
    );
  }
}
