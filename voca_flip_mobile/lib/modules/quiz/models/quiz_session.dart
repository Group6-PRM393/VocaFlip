import 'quiz_question.dart';

class QuizSession {
  final String attemptId;
  final String quizTitle;
  final int totalQuestions;
  final int timeLimitSeconds;
  final List<QuizQuestion> questions;

  QuizSession({
    required this.attemptId,
    required this.quizTitle,
    required this.totalQuestions,
    required this.timeLimitSeconds,
    required this.questions,
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      attemptId: json['attemptId'] ?? '',
      quizTitle: json['quizTitle'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      timeLimitSeconds: json['timeLimitSeconds'] ?? 0,
      questions: json['questions'] != null
          ? List<QuizQuestion>.from(
              json['questions'].map((x) => QuizQuestion.fromJson(x)),
            )
          : [],
    );
  }
}
