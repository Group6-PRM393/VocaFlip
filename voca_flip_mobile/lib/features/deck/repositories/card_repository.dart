import 'package:voca_flip_mobile/features/deck/models/card_model.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';

/// Repository quản lý các thao tác liên quan đến Card (Flashcard).
/// Sử dụng ApiService (có JWT Interceptor) thay vì raw Dio.
class CardRepository {
  final ApiService _apiService;
  CardRepository(this._apiService);

  /// Lấy danh sách Card theo deckId
  Future<List<CardModel>> getCardsByDeck(String deckId) async {
    final res = await _apiService.get('/api/cards/deck/$deckId');
    final body = res.data;

    // Trường hợp API trả list thuần
    if (body is List) {
      return body
          .map((e) => CardModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    // Trường hợp API bọc trong {code, result: [...]}
    if (body is Map<String, dynamic>) {
      final list = body['result'] ?? body['data'] ?? body['items'];
      if (list is List) {
        return list
            .map((e) => CardModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }

    throw Exception('Invalid cards response: ${body.runtimeType} - $body');
  }
}
