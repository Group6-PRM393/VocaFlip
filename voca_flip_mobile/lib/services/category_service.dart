import 'package:dio/dio.dart';
import '../models/category_model.dart';

class CategoryService {
  final Dio dio;
  CategoryService(this.dio);

  Future<List<CategoryModel>> getCategories(String userId) async {
    final res = await dio.get('/api/categories/user/$userId');

    print('CATEGORIES RAW: ${res.data}'); // debug

    final body = res.data;

    // nếu backend trả list thuần
    if (body is List) {
      return body
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
    }

    // nếu backend bọc trong data/result/items
    if (body is Map<String, dynamic>) {
      final list = body['data'] ?? body['result'] ?? body['items'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .toList();
      }
    }

    throw Exception('Invalid categories response: ${body.runtimeType} - $body');
  }
}
