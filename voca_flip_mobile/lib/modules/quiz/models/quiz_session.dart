import 'package:voca_flip_mobile/models/quiz/quiz_question.dart';

class QuizSession {
  final String attempId;
  final String quizTitle;
  final int totalQuestions;
  final int timeLimitSeconds;
  final List<QuizQuestion> questions;

  QuizSession({
    required this.attempId,
    required this.quizTitle,
    required this.totalQuestions,
    required this.timeLimitSeconds,
    required this.questions,
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      attempId: json['attemptId'],
      quizTitle: json['quizTitle'] ?? 'Quiz',
      totalQuestions: json['totalQuestions'],
      timeLimitSeconds: json['timeLimitSeconds'],
      questions: (json['question'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
    );
  }
}
