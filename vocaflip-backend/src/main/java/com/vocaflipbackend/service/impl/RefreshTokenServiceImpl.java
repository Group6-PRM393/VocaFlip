package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.entity.RefreshToken;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.exception.AppException;
import com.vocaflipbackend.exception.ErrorCode;
import com.vocaflipbackend.repository.RefreshTokenRepository;
import com.vocaflipbackend.service.RefreshTokenService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * RefreshTokenService implementation — stores and manages refresh tokens in the
 * database.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RefreshTokenServiceImpl implements RefreshTokenService {

  private final RefreshTokenRepository refreshTokenRepository;

  @Value("${jwt.refresh-token-expiration}")
  private long refreshTokenExpiration;

  @Override
  @Transactional
  public RefreshToken createRefreshToken(User user, String tokenString) {
    log.info("Creating refresh token for user: {}", user.getEmail());

    // Calculate expiry timestamp from config (ms → seconds)
    LocalDateTime expiresAt = LocalDateTime.now()
        .plusSeconds(refreshTokenExpiration / 1000);

    RefreshToken refreshToken = RefreshToken.builder()
        .token(tokenString)
        .user(user)
        .expiresAt(expiresAt)
        .build();

    return refreshTokenRepository.save(refreshToken);
  }

  @Override
  @Transactional(readOnly = true)
  public RefreshToken validateRefreshToken(String token) {
    log.debug("Validating refresh token");

    RefreshToken refreshToken = refreshTokenRepository.findByToken(token)
        .orElseThrow(() -> new AppException(ErrorCode.INVALID_TOKEN));

    if (refreshToken.isExpired()) {
      log.warn("Refresh token has expired");
      throw new AppException(ErrorCode.INVALID_TOKEN);
    }

    return refreshToken;
  }

  @Override
  @Transactional
  public void deleteRefreshToken(String token) {
    log.info("Deleting refresh token");
    refreshTokenRepository.deleteByToken(token);
  }

  @Override
  @Transactional
  public void deleteAllUserTokens(User user) {
    log.info("Deleting all refresh tokens for user: {}", user.getEmail());
    refreshTokenRepository.deleteByUser(user);
  }

  @Override
  @Transactional
  @Scheduled(cron = "0 0 2 * * ?") // Runs daily at 02:00
  public void cleanupExpiredTokens() {
    log.info("Cleaning up expired refresh tokens");
    refreshTokenRepository.deleteExpiredTokens(LocalDateTime.now());
  }
}
