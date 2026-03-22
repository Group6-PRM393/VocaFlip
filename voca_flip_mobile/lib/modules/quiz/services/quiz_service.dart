import 'dart:convert';
import 'package:voca_flip_mobile/config/app_config.dart';
import 'package:voca_flip_mobile/modules/quiz/models/quiz_result.dart';
import 'package:voca_flip_mobile/modules/quiz/models/quiz_review.dart';
import 'package:voca_flip_mobile/modules/quiz/models/quiz_session.dart';
import 'package:http/http.dart' as http;

class QuizService {
  String baseUrl = '${AppConfig.baseUrl}/api/quiz';

  Future<QuizSession> generateQuiz(
    String deckId,
    int numberOfQuestions,
    int timeLimitSeconds,
    String questionType,
  ) async {
    final uri = Uri.parse('$baseUrl/generate').replace(
      queryParameters: {
        'userId': 'user-test',
        'deckId': deckId,
        'numberOfQuestions': numberOfQuestions.toString(),
        'timeLimitSeconds': timeLimitSeconds.toString(),
        'questionType': questionType,
      },
    );

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return QuizSession.fromJson(jsonResponse['result']);
    } else {
      throw Exception('Error creating quiz: ${response.body}');
    }
  }

  Future<QuizResult> submitQuiz(
    String attemptId,
    int timeTaken,
    List<Map<String, String>> answers,
  ) async {
    final url = Uri.parse('$baseUrl/$attemptId/submit');

    final body = json.encode({
      'timeTakenSeconds': timeTaken,
      'answers': answers,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return QuizResult.fromJson(jsonResponse['result']);
    } else {
      throw Exception('Error submitting quiz');
    }
  }

  Future<QuizReview> getReview(String attemptId) async {
    final url = Uri.parse('$baseUrl/$attemptId/review');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return QuizReview.fromJson(jsonResponse['result']);
    } else {
      throw Exception('Error loadding quiz review');
    }
  }
}
