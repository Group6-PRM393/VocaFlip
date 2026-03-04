import 'dart:convert';
import 'package:voca_flip_mobile/models/quiz/quiz_result.dart';
import 'package:voca_flip_mobile/models/quiz/quiz_review.dart';
import 'package:voca_flip_mobile/models/quiz/quiz_session.dart';
import 'package:http/http.dart' as http;

class QuizService {
  static const String baseUrl = 'http://192.168.1.15:8080/api/quiz';

  Future<QuizSession> generateQuiz(String deckId, int count, int time) async {
    final uri = Uri.parse('$baseUrl/generate').replace(
      queryParameters: {
        'deckId': deckId,
        'numberOfQuestion': count.toString(),
        'timeLimitSeconds': time.toString(),
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
    String attempId,
    int timeTaken,
    List<Map<String, String>> answers,
  ) async {
    final url = Uri.parse('$baseUrl/$attempId/submit');

    final body = json.encode({
      'timeTakenSeconds': timeTaken,
      'answer': answers,
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
