package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.LoginRequest;
import com.vocaflipbackend.dto.request.RefreshTokenRequest;
import com.vocaflipbackend.dto.request.UserRegisterRequest;
import com.vocaflipbackend.dto.response.AuthResponse;
import com.vocaflipbackend.dto.response.UserResponse;

/**
 * Authentication Service Interface
 */
public interface AuthService {

  /**
   * Đăng ký user mới
   */
  AuthResponse register(UserRegisterRequest request);

  /**
   * Đăng nhập
   */
  AuthResponse login(LoginRequest request);

  /**
   * Refresh access token
   */
  AuthResponse refreshToken(RefreshTokenRequest request);

  /**
   * Logout (optional - có thể implement token blacklist nếu cần)
   */
  void logout(String token);

  /**
   * Lấy thông tin user hiện tại
   */
  UserResponse getCurrentUser();
}
