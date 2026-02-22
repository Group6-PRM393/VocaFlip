import '../models/responses/study_session_response.dart';
import '../services/api_service.dart';

class StudyRepository {
  final ApiService _apiService;

  StudyRepository(this._apiService);

  Future<StudySessionResponse> startSession(String deckId) async {
    final response = await _apiService.post(
      '/api/study/start',
      queryParameters: {'deckId': deckId},
    );
    return StudySessionResponse.fromJson(response.data['result']);
  }

  Future<StudySessionResponse> startDailyReview() async {
    final response = await _apiService.post('/api/study/daily-review');
    return StudySessionResponse.fromJson(response.data['result']);
  }


  /// (0=Forgot, 1=Hard, 2=Good, 3=Easy)
  Future<void> submitCardResult({
    required String sessionId,
    required String cardId,
    required int grade,
    required int responseTimeSeconds,
  }) async {
    await _apiService.post(
      '/api/study/$sessionId/submit',
      queryParameters: {
        'cardId': cardId,
        'grade': grade,
        'responseTimeSeconds': responseTimeSeconds,
      },
    );
  }

  Future<StudySessionResponse> completeSession(String sessionId) async {
    final response = await _apiService.post('/api/study/$sessionId/complete');
    return StudySessionResponse.fromJson(response.data['result']);
  }
}
