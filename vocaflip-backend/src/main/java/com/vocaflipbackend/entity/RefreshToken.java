package com.vocaflipbackend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Entity lưu trữ Refresh Token trong database
 * Đơn giản hóa - chỉ lưu thông tin cần thiết
 */
@Entity
@Table(name = "refresh_tokens")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RefreshToken {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false, unique = true, length = 500)
  private String token;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @Column(nullable = false)
  private LocalDateTime expiresAt;

  @Column(nullable = false)
  private LocalDateTime createdAt;

  /**
   * Kiểm tra token đã hết hạn chưa
   */
  public boolean isExpired() {
    return LocalDateTime.now().isAfter(expiresAt);
  }

  @PrePersist
  protected void onCreate() {
    createdAt = LocalDateTime.now();
  }
}
