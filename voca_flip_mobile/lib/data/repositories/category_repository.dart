import '../../models/category_model.dart';
import '../services/api_service.dart';

/// Repository quản lý các thao tác liên quan đến Category.
/// Sử dụng ApiService (có JWT Interceptor) thay vì raw Dio.
class CategoryRepository {
  final ApiService _apiService;
  CategoryRepository(this._apiService);

  /// Lấy danh sách Category theo userId
  Future<List<CategoryModel>> getCategories(String userId) async {
    final res = await _apiService.get(
      '/api/categories',
      queryParameters: {'userId': userId},
    );
    final body = res.data;

    // Trường hợp backend trả list thuần
    if (body is List) {
      return body
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
    }

    // Trường hợp backend bọc trong {code: ..., result: ...}
    if (body is Map<String, dynamic>) {
      final list = body['result'] ?? body['data'] ?? body['items'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => CategoryModel.fromJson(e))
            .toList();
      }
    }

    throw Exception('Invalid categories response: ${body.runtimeType} - $body');
  }
}
