import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';
import 'package:voca_flip_mobile/features/quiz/models/quiz_result.dart';
import 'package:voca_flip_mobile/features/quiz/models/quiz_review.dart';
import 'package:voca_flip_mobile/features/quiz/models/quiz_session.dart';

class QuizService {
  Future<QuizSession> generateQuiz(
    String deckId,
    int numberOfQuestions,
    int timeLimitSeconds,
    String questionType,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final api = ApiService(prefs);

    final response = await api.post(
      '/api/quiz/generate',
      queryParameters: {
        'userId':
            'user-test', // TODO: remove hardcoded userId when backend relies on token
        'deckId': deckId,
        'numberOfQuestions': numberOfQuestions,
        'timeLimitSeconds': timeLimitSeconds,
        'questionType': questionType,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data['result'] != null) {
      return QuizSession.fromJson(data['result']);
    } else {
      throw Exception('Invalid response format');
    }
  }

  Future<QuizResult> submitQuiz(
    String attemptId,
    int timeTaken,
    List<Map<String, String>> answers,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final api = ApiService(prefs);

    final response = await api.post(
      '/api/quiz/$attemptId/submit',
      data: {'timeTakenSeconds': timeTaken, 'answers': answers},
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data['result'] != null) {
      return QuizResult.fromJson(data['result']);
    } else {
      throw Exception('Invalid response format');
    }
  }

  Future<QuizReview> getReview(String attemptId) async {
    final prefs = await SharedPreferences.getInstance();
    final api = ApiService(prefs);

    final response = await api.get('/api/quiz/$attemptId/review');

    final data = response.data;
    if (data is Map<String, dynamic> && data['result'] != null) {
      return QuizReview.fromJson(data['result']);
    } else {
      throw Exception('Invalid response format');
    }
  }
}
