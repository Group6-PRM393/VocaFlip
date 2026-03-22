import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../config/google_config.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  late GoogleSignIn _googleSignIn;

  /// Khởi tạo GoogleSignIn với config
  void initialize() {
    _googleSignIn = GoogleSignIn(
      // Web: chỉ dùng clientId
      // Mobile: dùng serverClientId để lấy ID Token
      clientId: kIsWeb ? GoogleConfig.webClientId : null,
      serverClientId: kIsWeb ? null : GoogleConfig.webClientId,

      // Các field cần thiết
      scopes: [
        'email', // Lấy email
        'profile', // Lấy tên và avatar
        'openid', // Bắt buộc để có ID Token
      ],
    );
  }

  /// Sign in với Google
  /// Returns: Token để gửi lên backend (ID Token cho mobile, Access Token cho web)
  Future<String?> signIn() async {
    log("GoogleSignIn called in Service");
    try {
      // Xóa cache tài khoản trước
      await _googleSignIn.signOut();

      // Hiển thị Google Account Picker
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        // User cancel việc sign in
        return null;
      }

      // Lấy authentication tokens
      final GoogleSignInAuthentication auth = await account.authentication;

      // Mobile: Có ID Token
      // Web: Chỉ có Access Token
      final String? token = auth.idToken ?? auth.accessToken;

      if (token == null) {
        throw Exception('Failed to get authentication token from Google');
      }

      log(
        'Token type: ${auth.idToken != null ? "ID Token (Mobile)" : "Access Token (Web)"}',
      );
      return token;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  /// Sign out khỏi Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google Sign-Out Error: $e');
    }
  }

  /// Disconnect - Revoke access hoàn toàn
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      print('Google Disconnect Error: $e');
    }
  }
}
