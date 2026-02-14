package com.vocaflipbackend.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Response DTO cho authentication - chứa access token, refresh token và thông
 * tin user
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AuthResponse {

  private String accessToken;

  private String refreshToken;

  private String tokenType;

  private Long expiresIn; // Thời gian hết hạn tính bằng giây

  private UserResponse user;

  private LocalDateTime issuedAt;
}
