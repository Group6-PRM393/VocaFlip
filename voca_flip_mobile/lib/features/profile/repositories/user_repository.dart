import 'package:dio/dio.dart';
import 'package:voca_flip_mobile/core/services/api_service.dart';
import 'package:voca_flip_mobile/features/auth/models/auth_model.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  Future<UserModel> getCurrentUser() async {
    final res = await _apiService.get('/api/user/me');
    final body = res.data;
    if (body is Map<String, dynamic> && body['result'] != null) {
      return UserModel.fromJson(body['result']);
    }
    throw Exception('Invalid user response');
  }

  Future<UserModel> updateProfile({
    required String name,
    String? avatarUrl,
  }) async {
    final data = <String, dynamic>{'name': name};
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

    final res = await _apiService.put('/api/user/me', data: data);

    final body = res.data;
    if (body is Map<String, dynamic> && body['result'] != null) {
      return UserModel.fromJson(body['result']);
    }
    throw Exception('Invalid update profile response');
  }

  Future<UserModel> uploadAvatar({
    required List<int> bytes,
    String? fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: fileName ?? 'avatar.jpg',
      ),
    });

    // Dùng dio trực tiếp để kiểm soát contentType multipart
    final dio = _apiService.dio;
    final res = await dio.put('/api/user/me/avatar', data: formData);

    final body = res.data;
    if (body is Map<String, dynamic> && body['result'] != null) {
      return UserModel.fromJson(body['result']);
    }
    throw Exception('Invalid upload avatar response');
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _apiService.put(
      '/api/user/me/password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
    final body = res.data;
    if (body is Map<String, dynamic> && body['code'] != 1000) {
      throw Exception(body['message'] ?? 'Lỗi đổi mật khẩu');
    }
  }
}
