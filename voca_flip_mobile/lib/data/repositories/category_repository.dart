// import '../models/category_model.dart';
// import '../services/api_service.dart';

// class CategoryRepository {
//   final ApiService _apiService;

//   CategoryRepository(this._apiService);

//   // 1. Lấy danh sách danh mục của 1 User
//   Future<List<CategoryModel>> getCategories(String userId) async {
//     final response = await _apiService.get(
//       '/api/categories',
//       queryParameters: {'userId': userId},
//     );

//     final data = response.data;
//     // Kiểm tra mã code 1000 từ ApiResponse của BE
//     if (data['code'] == 1000) {
//       final List listData = data['result'] ?? [];
//       return listData.map((e) => CategoryModel.fromJson(e)).toList();
//     } else {
//       throw Exception(data['message'] ?? 'Lỗi tải danh mục');
//     }
//   }

//   // 2. Tạo danh mục mới
//   Future<CategoryModel> createCategory(String userId, CategoryModel category) async {
//     final response = await _apiService.post(
//       '/api/categories',
//       queryParameters: {'userId': userId},
//       data: category.toJson(),
//     );

//     final data = response.data;
//     if (data['code'] == 1000) {
//       return CategoryModel.fromJson(data['result']);
//     } else {
//       throw Exception(data['message'] ?? 'Lỗi tạo danh mục');
//     }
//   }

//   // 3. Cập nhật danh mục
//   Future<CategoryModel> updateCategory(String id, CategoryModel category) async {
//     final response = await _apiService.put(
//       '/api/categories/$id',
//       data: category.toJson(),
//     );

//     final data = response.data;
//     if (data['code'] == 1000) {
//       return CategoryModel.fromJson(data['result']);
//     } else {
//       throw Exception(data['message'] ?? 'Lỗi cập nhật danh mục');
//     }
//   }

//   // 4. Xóa danh mục
//   Future<void> deleteCategory(String id) async {
//     final response = await _apiService.delete('/api/categories/$id');
    
//     final data = response.data;
//     if (data['code'] != 1000) {
//       throw Exception(data['message'] ?? 'Lỗi xóa danh mục');
//     }
//   }
// }