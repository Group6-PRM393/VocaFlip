package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.LoginRequest;
import com.vocaflipbackend.dto.request.RefreshTokenRequest;
import com.vocaflipbackend.dto.request.UserRegisterRequest;
import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.AuthResponse;
import com.vocaflipbackend.dto.response.UserResponse;
import com.vocaflipbackend.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Authentication Controller - Xử lý các endpoint liên quan đến authentication
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Authentication", description = "API quản lý đăng ký, đăng nhập, đăng xuất")
public class AuthController {

    private final AuthService authService;

    /**
     * Đăng ký tài khoản mới
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
     * Đăng nhập
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
     * Đăng xuất (optional)
     */
    @PostMapping("/logout")
    @Operation(summary = "Đăng xuất", description = "Đăng xuất khỏi hệ thống và vô hiệu hóa token")
    public ResponseEntity<ApiResponse<Void>> logout(@RequestHeader("Authorization") String authHeader) {
        log.info("Logout request received");

        // Extract token from "Bearer <token>"
        String token = authHeader.substring(7);
        authService.logout(token);

        return ResponseEntity
                .ok()
                .body(ApiResponse.<Void>builder()
                        .code(1000)
                        .message("Logout successful")
                        .build());
    }

    /**
     * Kiểm tra trạng thái authentication
     */
    @GetMapping("/check-me")
    @Operation(summary = "Lấy thông tin user hiện tại", description = "Lấy thông tin của user đang đăng nhập")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser() {
        // User info sẽ được lấy từ SecurityContext trong service layer
        return ResponseEntity
                .ok()
                .body(ApiResponse.<UserResponse>builder()
                        .code(1000)
                        .message("Authenticated")
                        .result(authService.getCurrentUser())
                        .build());
    }
}
