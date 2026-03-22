import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:voca_flip_mobile/features/deck/models/deck_model.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';

/// Repository quản lý các thao tác CRUD liên quan đến Deck.
/// Sử dụng ApiService (có JWT Interceptor) thay vì raw Dio.
/// URL endpoint được căn chỉnh theo DeckController.java trên backend.
class DeckRepository {
  final ApiService _apiService;
  DeckRepository(this._apiService);

  /// Lấy danh sách Deck của user hiện tại (tự xác định qua JWT Token)
  /// Backend: GET /api/decks/my-decks (không cần truyền userId)
  Future<List<DeckModel>> getMyDecks() async {
    final res = await _apiService.get('/api/decks/my-decks');
    final body = res.data;

    final list = (body is Map<String, dynamic>) ? body['result'] : body;

    if (list is List) {
      return list
          .map((e) => DeckModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    throw Exception('Invalid decks response: ${body.runtimeType} - $body');
  }

  Future<List<DeckModel>> getMyDecksByCategory(String categoryId) async {
    final res = await _apiService.get(
      '/api/decks/my-decks/category/$categoryId',
    );
    final body = res.data;

    final list = (body is Map<String, dynamic>) ? body['result'] : body;

    if (list is List) {
      return list
          .map((e) => DeckModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    throw Exception(
      'Invalid decks by category response: ${body.runtimeType} - $body',
    );
  }

  /// Lấy chi tiết Deck theo deckId
  /// Backend: GET /api/decks/{deckId}
  Future<DeckModel> getDeckById(String deckId) async {
    final res = await _apiService.get('/api/decks/$deckId');
    final body = res.data;

    final result = (body is Map<String, dynamic>) ? body['result'] : null;

    if (result is Map<String, dynamic>) {
      return DeckModel.fromJson(result);
    }

    throw Exception(
      'Invalid deck detail response: ${body.runtimeType} - $body',
    );
  }

  /// Tạo Deck mới (hỗ trợ upload ảnh bìa)
  /// Backend: POST /api/decks (multipart/form-data, dùng JWT, không cần userId)
  /// Params: title, description, categoryId, coverImage (optional)
  Future<DeckModel> createDeck({
    required String title,
    required String description,
    required String categoryId,
    File? coverFile,
  }) async {
    final formMap = <String, dynamic>{
      'title': title,
      'description': description,
      'categoryId': categoryId,
    };

    if (coverFile != null) {
      final fileName = coverFile.path.split(Platform.pathSeparator).last;
      formMap['coverImage'] = await MultipartFile.fromFile(
        coverFile.path,
        filename: fileName,
      );
    }

    final form = FormData.fromMap(formMap);

    final res = await _apiService.dio.post(
      '/api/decks',
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

    return DeckModel.fromJson(result);
  }

  /// Tạo Deck mới từ bytes (dùng cho Flutter Web)
  /// Web không hỗ trợ dart:io File, nên dùng bytes trực tiếp
  Future<DeckModel> createDeckFromBytes({
    required String title,
    required String description,
    required String categoryId,
    Uint8List? coverBytes,
    String? coverFileName,
  }) async {
    final formMap = <String, dynamic>{
      'title': title,
      'description': description,
      'categoryId': categoryId,
    };

    if (coverBytes != null) {
      formMap['coverImage'] = MultipartFile.fromBytes(
        coverBytes,
        filename: coverFileName ?? 'cover.jpg',
      );
    }

    final form = FormData.fromMap(formMap);

    final res = await _apiService.dio.post(
      '/api/decks',
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

    return DeckModel.fromJson(result);
  }

  /// Cập nhật thông tin Deck (hỗ trợ cả Web lẫn Mobile)
  /// Backend: PUT /api/decks/{id} (multipart/form-data)
  Future<DeckModel> updateDeckFromBytes({
    required String deckId,
    required String title,
    required String description,
    required String categoryId,
    Uint8List? coverImageBytes,
    String? coverFileName,
  }) async {
    final formMap = <String, dynamic>{
      'title': title,
      'description': description,
      'categoryId': categoryId,
    };

    if (coverImageBytes != null) {
      formMap['coverImage'] = MultipartFile.fromBytes(
        coverImageBytes,
        filename: coverFileName ?? 'cover.jpg',
      );
    }

    final form = FormData.fromMap(formMap);

    final res = await _apiService.dio.put(
      '/api/decks/$deckId',
      data: form,
      options: Options(headers: {Headers.acceptHeader: 'application/json'}),
    );

    final body = res.data;
    final result = (body is Map<String, dynamic>) ? body['result'] : null;
    if (result is Map<String, dynamic>) return DeckModel.fromJson(result);

    throw Exception('Invalid update deck response: $body');
  }

  /// Xóa Deck theo deckId
  /// Backend: DELETE /api/decks/{id}
  Future<void> deleteDeck(String deckId) async {
    await _apiService.delete('/api/decks/$deckId');
  }
}
