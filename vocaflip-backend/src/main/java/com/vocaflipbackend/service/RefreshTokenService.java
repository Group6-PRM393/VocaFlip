package com.vocaflipbackend.service;

import com.vocaflipbackend.entity.RefreshToken;
import com.vocaflipbackend.entity.User;

/**
 * Service để quản lý Refresh Tokens - đơn giản hóa
 */
public interface RefreshTokenService {

  /**
   * Tạo và lưu refresh token mới
   */
  RefreshToken createRefreshToken(User user, String tokenString);

  /**
   * Validate refresh token
   */
  RefreshToken validateRefreshToken(String token);

  /**
   * Xóa một refresh token (logout)
   */
  void deleteRefreshToken(String token);

  /**
   * Xóa tất cả refresh tokens của user (logout all devices)
   */
  void deleteAllUserTokens(User user);

  /**
   * Xóa các refresh tokens đã hết hạn (scheduled task)
   */
  void cleanupExpiredTokens();
}
