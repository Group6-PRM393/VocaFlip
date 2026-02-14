package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.RefreshToken;
import com.vocaflipbackend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Repository cho RefreshToken entity - đơn giản hóa
 */
@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {

  /**
   * Tìm refresh token theo token string
   */
  Optional<RefreshToken> findByToken(String token);

  /**
   * Xóa token theo token string
   */
  void deleteByToken(String token);

  /**
   * Xóa tất cả tokens của một user
   */
  void deleteByUser(User user);

  /**
   * Xóa tất cả tokens đã hết hạn
   */
  @Modifying
  @Query("DELETE FROM RefreshToken rt WHERE rt.expiresAt < ?1")
  void deleteExpiredTokens(LocalDateTime now);
}
