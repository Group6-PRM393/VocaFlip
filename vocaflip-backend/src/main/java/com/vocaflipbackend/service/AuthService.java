package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.GoogleLoginRequest;
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
     * register
     */
    AuthResponse register(UserRegisterRequest request);

    /**
     * login
     */
    AuthResponse login(LoginRequest request);

    /**
     * Google OAuth login
     */
    AuthResponse authenticateGoogle(GoogleLoginRequest request) throws Exception;

    /**
     * Refresh access token
     */
    AuthResponse refreshToken(RefreshTokenRequest request);

    /**
     * Logout
     */
    void logout(String token);

    /**
     * Get current user's information
     */
    UserResponse getCurrentUser();

    /**
     * Reset Password with OTP code
     */
    void resetPassword(String email, String otpCode, String newPassword);

    /**
     * verify email with OTP code
     */
    boolean verifyEmail(String email, String otpCode);
}
