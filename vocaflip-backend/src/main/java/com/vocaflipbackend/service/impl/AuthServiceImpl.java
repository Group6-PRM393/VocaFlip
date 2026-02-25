package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.config.CustomUserDetails;
import com.vocaflipbackend.config.JwtUtils;
import com.vocaflipbackend.dto.request.LoginRequest;
import com.vocaflipbackend.dto.request.RefreshTokenRequest;
import com.vocaflipbackend.dto.request.UserRegisterRequest;
import com.vocaflipbackend.dto.response.AuthResponse;
import com.vocaflipbackend.dto.response.UserResponse;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.exception.AppException;
import com.vocaflipbackend.exception.ErrorCode;
import com.vocaflipbackend.mapper.UserMapper;
import com.vocaflipbackend.repository.UserRepository;
import com.vocaflipbackend.service.AuthService;
import com.vocaflipbackend.service.RefreshTokenService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * Authentication Service Implementation
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {

  private final UserRepository userRepository;
  private final PasswordEncoder passwordEncoder;
  private final JwtUtils jwtUtils;
  private final AuthenticationManager authenticationManager;
  private final UserDetailsService userDetailsService;
  private final UserMapper userMapper;
  private final RefreshTokenService refreshTokenService;

  @Override
  @Transactional
  public AuthResponse register(UserRegisterRequest request) {
    log.info("Registering new user with email: {}", request.getEmail());

    // Kiểm tra email đã tồn tại chưa
    if (userRepository.findByEmail(request.getEmail()).isPresent()) {
      throw new AppException(ErrorCode.USER_EXISTED);
    }

    // Tạo user mới
    User user = User.builder()
        .email(request.getEmail())
        .name(request.getName())
        .passwordHash(passwordEncoder.encode(request.getPassword()))
        .totalWords(0)
        .masteredWords(0)
        .learningWords(0)
        .streakDays(0)
        .isConfirmedEmail(false)
        .build();

    user = userRepository.save(user);
    log.info("User registered successfully with id: {}", user.getId());

    // Generate tokens
    UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
    String accessToken = jwtUtils.generateAccessToken(userDetails);
    String refreshTokenString = jwtUtils.generateRefreshToken(userDetails);

    // Lưu refresh token vào database
    refreshTokenService.createRefreshToken(user, refreshTokenString);

    return buildAuthResponse(accessToken, refreshTokenString, user);
  }

  @Override
  public AuthResponse login(LoginRequest request) {
    log.info("Attempting login for email: {}", request.getEmail());

    // Authenticate user
    authenticationManager.authenticate(
        new UsernamePasswordAuthenticationToken(
            request.getEmail(),
            request.getPassword()));

    // Load user
    User user = userRepository.findByEmail(request.getEmail())
        .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));

    // Generate tokens
    UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
    String accessToken = jwtUtils.generateAccessToken(userDetails);
    String refreshTokenString = jwtUtils.generateRefreshToken(userDetails);

    // Lưu refresh token vào database
    refreshTokenService.createRefreshToken(user, refreshTokenString);

    log.info("User logged in successfully: {}", user.getEmail());

    return buildAuthResponse(accessToken, refreshTokenString, user);
  }

  @Override
  public AuthResponse refreshToken(RefreshTokenRequest request) {
    log.info("Attempting to refresh token");

    String refreshTokenString = request.getRefreshToken();

    // Validate refresh token from database
    var refreshToken = refreshTokenService.validateRefreshToken(refreshTokenString);
    User user = refreshToken.getUser();

    // Generate new access token
    UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
    String newAccessToken = jwtUtils.generateAccessToken(userDetails);

    log.info("Token refreshed successfully for user: {}", user.getEmail());

    return buildAuthResponse(newAccessToken, refreshTokenString, user);
  }

  @Override
  public void logout(String token) {
    // Xóa refresh token khi logout
    refreshTokenService.deleteRefreshToken(token);
    log.info("User logged out - refresh token deleted");
  }

  @Override
  public UserResponse getCurrentUser() {
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
    User user = userDetails.getUser();
    return userMapper.toUserResponse(user);
  }

  /**
   * Helper method để build AuthResponse - DRY principle
   */
  private AuthResponse buildAuthResponse(String accessToken, String refreshToken, User user) {
    return AuthResponse.builder()
        .accessToken(accessToken)
        .refreshToken(refreshToken)
        .tokenType("Bearer")
        .expiresIn(jwtUtils.getAccessTokenExpiration() / 1000) // Convert to seconds
        .user(userMapper.toUserResponse(user))
        .issuedAt(LocalDateTime.now())
        .build();
  }
}
