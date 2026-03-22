import 'dart:convert';
import 'package:voca_flip_mobile/core/config/app_config.dart';
import 'package:voca_flip_mobile/features/quiz/models/quiz_result.dart';
import 'package:voca_flip_mobile/features/quiz/models/quiz_review.dart';
import 'package:voca_flip_mobile/features/quiz/models/quiz_session.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuizService {
  String baseUrl = '${AppConfig.baseUrl}/api/quiz';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<QuizSession> generateQuiz(
    String deckId,
    int numberOfQuestions,
    int timeLimitSeconds,
    String questionType,
  ) async {
    final uri = Uri.parse('$baseUrl/generate').replace(
      queryParameters: {
        'deckId': deckId,
        'numberOfQuestions': numberOfQuestions.toString(),
        'timeLimitSeconds': timeLimitSeconds.toString(),
        'questionType': questionType,
      },
    );

    final response = await http.post(uri, headers: await _getHeaders());

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
      headers: await _getHeaders(),
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
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return QuizReview.fromJson(jsonResponse['result']);
    } else {
      throw Exception('Error loadding quiz review');
    }
  }
}
