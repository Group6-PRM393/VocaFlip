package com.vocaflipbackend.service.impl;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.vocaflipbackend.config.CustomUserDetails;
import com.vocaflipbackend.dto.request.GoogleLoginRequest;
import com.vocaflipbackend.entity.SocialAccount;
import com.vocaflipbackend.enums.Provider;
import com.vocaflipbackend.repository.SocialAccountRepository;
import com.vocaflipbackend.service.GoogleOAuthService;
import com.vocaflipbackend.utils.JwtUtils;
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
    private final GoogleOAuthService googleOAuthService;
    private final SocialAccountRepository socialAccountRepository;

    @Override
    @Transactional
    public AuthResponse register(UserRegisterRequest request) {
        log.info("Registering new user with email: {}", request.getEmail());

        // Reject if email is already registered
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new AppException(ErrorCode.USER_EXISTED);
        }

        // Build and persist the new user
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

        // Remove any existing refresh tokens before issuing a new one
        refreshTokenService.deleteAllUserTokens(user);
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

        // Remove stale tokens before issuing new one (prevent token litter)
        refreshTokenService.deleteAllUserTokens(user);
        refreshTokenService.createRefreshToken(user, refreshTokenString);

        log.info("User logged in successfully: {}", user.getEmail());

        return buildAuthResponse(accessToken, refreshTokenString, user);
    }

    @Override
    @Transactional
    public AuthResponse authenticateGoogle(GoogleLoginRequest request) throws Exception {
        log.info("Attempting Google authentication");

        try {
            //Verify ID Token with Google
//            GoogleIdToken.Payload payload = googleOAuthService.verifyIdToken(request.getIdToken());

            //Verify ID Token / Access Token with Google
            GoogleIdToken.Payload payload = googleOAuthService.verifyToken(request.getIdToken());

            //Extract information from payload
            String googleId = payload.getSubject();      // Google User ID (unique)
            String email = payload.getEmail();           // Email
            String name = (String) payload.get("name");  // Tên đầy đủ
            String pictureUrl = (String) payload.get("picture"); // Avatar URL
            Boolean emailVerified = payload.getEmailVerified();  // Email verified?

            log.info("Google token verified for email: {}", email);

            // find social account base on Google ID
            SocialAccount socialAccount = socialAccountRepository
                    .findByProviderAndProviderId(Provider.GOOGLE, googleId)
                    .orElse(null);

            User user = new User();

            if (socialAccount != null) {
                // User đã từng đăng nhập bằng Google
                user = socialAccount.getUser();
                log.info("Existing Google user found: {}", user.getEmail());

            } else {
                //Lần đầu đăng nhập bằng Google
                //Kiểm tra email đã tồn tại trong hệ thống chưa
                user = userRepository.findByEmail(email).orElse(null);

                if (user != null) {
                    // Email đã tồn tại (đã đăng ký bằng email/password)
                    // Link Google account vào user hiện tại
                    log.info("Email exists, linking Google account to: {}", email);

                } else {
                    // SUB-CASE B: User hoàn toàn mới
                    // Tạo user mới
                    log.info("Creating new user from Google: {}", email);
                    user = User.builder()
                            .email(email)
                            .name(name)
                            .avatarUrl(pictureUrl)
                            .passwordHash(passwordEncoder.encode("GOOGLE_OAUTH_NO_PASSWORD")) // Placeholder cho Google users
                            .totalWords(0)
                            .masteredWords(0)
                            .learningWords(0)
                            .streakDays(0)
                            .isConfirmedEmail(emailVerified) // Lấy từ Google
                            .build();
                    user = userRepository.save(user);
                }

                // Tạo và link social account
                socialAccount = SocialAccount.builder()
                        .provider(Provider.GOOGLE)
                        .providerId(googleId)  // Lưu Google User ID
                        .user(user)
                        .build();
                socialAccountRepository.save(socialAccount);

                log.info("Google social account created and linked");
            }

            // Generate JWT tokens của hệ thống VocaFlip
            UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
            String accessToken = jwtUtils.generateAccessToken(userDetails);
            String refreshTokenString = jwtUtils.generateRefreshToken(userDetails);

            // Lưu refresh token vào DB
            refreshTokenService.deleteAllUserTokens(user); // Xóa token cũ
            refreshTokenService.createRefreshToken(user, refreshTokenString);

            log.info("Google authentication successful for: {}", user.getEmail());

            // Return auth response
            return buildAuthResponse(accessToken, refreshTokenString, user);

        } catch (Exception e) {
            log.error("Google authentication failed: {}", e.getMessage());
            throw new AppException(ErrorCode.GOOGLE_AUTH_FAILED);
        }
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
        // Delete the refresh token from DB on logout
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
     * Helper to build a consistent AuthResponse — avoids duplication (DRY).
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
