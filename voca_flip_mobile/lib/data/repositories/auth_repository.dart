import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';
import '../services/api_service.dart';
import '../../config/app_config.dart';

class AuthRepository {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  AuthRepository(this._apiService, this._prefs);

  /// POST /api/auth/login
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    // BE wraps result in ApiResponse { code, message, result }
    final result = data['result'] as Map<String, dynamic>;
    final authResponse = AuthResponseModel.fromJson(result);

    // Persist tokens
    await _prefs.setString(AppConfig.tokenKey, authResponse.accessToken);
    await _prefs.setString(
      AppConfig.refreshTokenKey,
      authResponse.refreshToken,
    );

    // Lưu userId vào SharedPreferences để dùng ở các màn hình khác
    if (authResponse.user != null) {
      await _prefs.setString(AppConfig.userIdKey, authResponse.user!.id);
    }

    return authResponse;
  }

  /// POST /api/auth/register
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/api/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    final result = data['result'] as Map<String, dynamic>;
    final authResponse = AuthResponseModel.fromJson(result);

    return authResponse;
  }

  /// POST /api/auth/logout
  Future<void> logout() async {
    final refreshToken = _prefs.getString(AppConfig.refreshTokenKey);
    if (refreshToken != null) {
      try {
        await _apiService.post(
          '/api/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } catch (_) {
        // Even if server call fails, clear local tokens
      }
    }
    await _prefs.remove(AppConfig.tokenKey);
    await _prefs.remove(AppConfig.refreshTokenKey);
    await _prefs.remove(AppConfig.userIdKey);
  }

  bool get isLoggedIn =>
      (_prefs.getString(AppConfig.tokenKey) ?? '').isNotEmpty;
}
