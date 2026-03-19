import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
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
  Future<CardModel> createCard({
    required String deckId,
    required String front,
    required String back,
    String? phonetic,
    String? exampleSentence,
    String? audioUrl,
    String? imageUrl,
    File? imageFile,
  }) async {
    final queryParams = <String, dynamic>{
      'deckId': deckId,
      'front': front.trim(),
      'back': back.trim(),
      if (phonetic != null && phonetic.trim().isNotEmpty)
        'phonetic': phonetic.trim(),
      if (exampleSentence != null && exampleSentence.trim().isNotEmpty)
        'exampleSentence': exampleSentence.trim(),
      if (audioUrl != null && audioUrl.trim().isNotEmpty)
        'audioUrl': audioUrl.trim(),
      if (imageUrl != null && imageUrl.trim().isNotEmpty)
        'imageUrl': imageUrl.trim(),
    };

    final formMap = <String, dynamic>{};

    if (imageFile != null) {
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      formMap['image'] = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      );
    }

    final form = FormData.fromMap(formMap);

    final res = await _apiService.dio.post(
      '/api/cards',
      queryParameters: queryParams,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }

    final result = data['result'];
    if (result is! Map<String, dynamic>) {
      throw Exception('Missing result in response');
    }

    return CardModel.fromJson(result);
  }

  Future<CardModel> createCardFromBytes({
    required String deckId,
    required String front,
    required String back,
    String? phonetic,
    String? exampleSentence,
    String? audioUrl,
    String? imageUrl,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final queryParams = <String, dynamic>{
      'deckId': deckId,
      'front': front.trim(),
      'back': back.trim(),
      if (phonetic != null && phonetic.trim().isNotEmpty)
        'phonetic': phonetic.trim(),
      if (exampleSentence != null && exampleSentence.trim().isNotEmpty)
        'exampleSentence': exampleSentence.trim(),
      if (audioUrl != null && audioUrl.trim().isNotEmpty)
        'audioUrl': audioUrl.trim(),
      if (imageUrl != null && imageUrl.trim().isNotEmpty)
        'imageUrl': imageUrl.trim(),
    };

    final formMap = <String, dynamic>{};

    if (imageBytes != null) {
      formMap['image'] = MultipartFile.fromBytes(
        imageBytes,
        filename: imageFileName ?? 'card.jpg',
      );
    }

    final form = FormData.fromMap(formMap);

    final res = await _apiService.dio.post(
      '/api/cards',
      queryParameters: queryParams,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }

    final result = data['result'];
    if (result is! Map<String, dynamic>) {
      throw Exception('Missing result in response');
    }

    return CardModel.fromJson(result);
  }

}
