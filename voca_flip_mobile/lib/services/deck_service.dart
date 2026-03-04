import 'dart:io';
import 'package:dio/dio.dart';
import '../models/deck_model.dart';

class DeckService {
  final Dio dio;
  DeckService(this.dio);

 Future<List<DeckModel>> getDecksByUser(String userId) async {
  final res = await dio.get('/api/decks/user/$userId');
  final body = res.data;

  final list = (body is Map<String, dynamic>) ? body['result'] : body;

  if (list is List) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(DeckModel.fromJson)
        .toList();
  }

  throw Exception('Invalid decks response: ${body.runtimeType} - $body');
}


 Future<DeckModel> createDeck({
  required String userId,
  required String title,
  required String description,
  required String categoryId, 
  File? coverFile,
}) async {
    Response res;

    if (coverFile != null) {
      final fileName = coverFile.path.split(Platform.pathSeparator).last;

      final form = FormData.fromMap({
        'title': title,
        'description': description,
        'category': categoryId,
        'cover': await MultipartFile.fromFile(coverFile.path, filename: fileName),
      });

      res = await dio.post(
        '/api/decks/user/$userId',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
    } else {
      res = await dio.post(
        '/api/decks/user/$userId',
        data: {
          'title': title,
          'description': description,
          'category': categoryId,
          'coverImageUrl': null,
        },
      );
    }

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
  Future<DeckModel> getDeckById(String deckId) async {
  final res = await dio.get('/api/decks/$deckId');
  print('DECK DETAIL BODY ${res.data}');
  final body = res.data;

  // API của bạn trả dạng { code, message, result: {...} }
  final result = (body is Map<String, dynamic>) ? body['result'] : null;

  if (result is Map<String, dynamic>) {
    return DeckModel.fromJson(result);
  }

  throw Exception('Invalid deck detail response: ${body.runtimeType} - $body');
}
Future<DeckModel> updateDeck({
    required String deckId,
    required String title,
    required String description,
    required String category,
    File? coverImage,
  }) async {
    final form = FormData.fromMap({
      'title': title,
      'description': description,
      'category': category,
      if (coverImage != null)
        'coverImage': await MultipartFile.fromFile(coverImage.path),
    });
print('FORM fields: ${form.fields}');
print('FORM files: ${form.files.map((e) => e.key).toList()}');

    final res = await dio.put(
  '/api/decks/$deckId',
  data: form,
  options: Options(
    headers: {
      Headers.acceptHeader: 'application/json',
    },
  ),
);


    final body = res.data;
    final result = (body is Map<String, dynamic>) ? body['result'] : null;
    if (result is Map<String, dynamic>) return DeckModel.fromJson(result);

    throw Exception('Invalid update deck response: $body');
  }
  Future<void> deleteDeck(String deckId) async {
  final res = await dio.delete('/api/decks/$deckId');

  final body = res.data;
  // nếu API của bạn luôn trả {code, message, result}
  if (body is Map && (body['code'] == 1000 || body['code'] == 0)) return;

  // Nếu bạn không chắc code success là gì thì bỏ check trên và chỉ return luôn:
  // return;

  throw Exception('Delete failed: $body');
}


}
