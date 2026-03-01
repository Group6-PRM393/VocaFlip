package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.LoginRequest;
import com.vocaflipbackend.dto.request.RefreshTokenRequest;
import com.vocaflipbackend.dto.request.UserRegisterRequest;
import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.AuthResponse;
import com.vocaflipbackend.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Authentication Controller
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Authentication", description = "API quản lý đăng ký, đăng nhập, đăng xuất")
public class AuthController {

    private final AuthService authService;

    /**
     * Register
     */
    @PostMapping("/register")
    @Operation(summary = "Đăng ký tài khoản mới", description = "Tạo tài khoản người dùng mới với email, mật khẩu và tên")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody UserRegisterRequest request) {
        log.info("Register request received for email: {}", request.getEmail());
        AuthResponse authResponse = authService.register(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.<AuthResponse>builder()
                        .code(1000)
                        .message("User registered successfully")
                        .result(authResponse)
                        .build());
    }

    /**
     * Login
     */
    @PostMapping("/login")
    @Operation(summary = "Đăng nhập", description = "Đăng nhập vào hệ thống với email và mật khẩu")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        log.info("Login request received for email: {}", request.getEmail());
        AuthResponse authResponse = authService.login(request);
        return ResponseEntity
                .ok()
                .body(ApiResponse.<AuthResponse>builder()
                        .code(1000)
                        .message("Login successful")
                        .result(authResponse)
                        .build());
    }

    /**
     * Refresh access token
     */
    @PostMapping("/refresh-token")
    @Operation(summary = "Refresh access token", description = "Tạo access token mới từ refresh token")
    public ResponseEntity<ApiResponse<AuthResponse>> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        log.info("Refresh token request received");
        AuthResponse authResponse = authService.refreshToken(request);
        return ResponseEntity
                .ok()
                .body(ApiResponse.<AuthResponse>builder()
                        .code(1000)
                        .message("Token refreshed successfully")
                        .result(authResponse)
                        .build());
    }

    /**
     * Logout — client gửi refreshToken trong body để server xóa khỏi DB.
     * Access token sẽ tự hết hạn sau 1 ngày (stateless — không thể revoke sớm hơn).
     */
    @PostMapping("/logout")
    @Operation(summary = "Đăng xuất", description = "Xóa refresh token khỏi DB. Client cần tự xóa access token ở local storage / secure storage.")
    public ResponseEntity<ApiResponse<Void>> logout(@Valid @RequestBody RefreshTokenRequest request) {
        log.info("Logout request received");
        authService.logout(request.getRefreshToken());
        return ResponseEntity
                .ok()
                .body(ApiResponse.<Void>builder()
                        .code(1000)
                        .message("Logout successful")
                        .build());
    }
}
