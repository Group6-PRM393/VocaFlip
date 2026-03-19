package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.*;
import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.AuthResponse;
import com.vocaflipbackend.exception.ErrorCode;
import com.vocaflipbackend.service.AuthService;
import com.vocaflipbackend.service.IEmailService;
import com.vocaflipbackend.service.IRedisOtpService;
import com.vocaflipbackend.utils.OtpUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

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
    private final OtpUtil otpUtil;
    private final IRedisOtpService redisOtpService;
    private final IEmailService emailService;


    /**
     * Auth with Google
     */
    @PostMapping("/google")
    @Operation(
            summary = "Đăng nhập bằng Google",
            description = "Authenticate user với Google ID Token"
    )
    public ResponseEntity<ApiResponse<AuthResponse>> authenticateGoogle(
            @Valid @RequestBody GoogleLoginRequest request) {
        try {
            log.info("Google authentication request received");
            AuthResponse authResponse = authService.authenticateGoogle(request);
            return ResponseEntity
                    .ok()
                    .body(ApiResponse.<AuthResponse>builder()
                            .code(1000)
                            .message("Google authentication successful")
                            .result(authResponse)
                            .build());
        } catch (Exception e) {
            log.error("Google authentication failed: {}", e.getMessage());
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.<AuthResponse>builder()
                            .code(HttpStatus.UNAUTHORIZED.value())
                            .message("Google authentication failed: " + e.getMessage())
                            .build());
        }
    }

    /**
     * Register
     */
    @PostMapping("/register")
    @Operation(summary = "Đăng ký tài khoản mới", description = "Tạo tài khoản người dùng mới với email, mật khẩu và tên")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody UserRegisterRequest request) {
        log.info("Register request received for email: {}", request.getEmail());
        AuthResponse authResponse = authService.register(request);

        // Send 4-digit OTP immediately after successful registration.
        String otp = otpUtil.generateOtp();
        redisOtpService.saveOtp(request.getEmail(), otp);
        emailService.sendOtpEmail(request.getEmail(), otp);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.<AuthResponse>builder()
                        .code(HttpStatus.CREATED.value())
                        .message("User registered successfully. Please verify your email with OTP")
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


    /**
     * Request OTP to verify email or reset password
     * OTP will be expired after 5 minute
     */

    @PostMapping("/request-otp")
    @Operation(summary = "Yêu cầu mã xác thực OTP")
    public ResponseEntity<ApiResponse<Void>> requestOtp(@RequestBody OtpRequest body){

        String email = body.getEmail();

        String otp = otpUtil.generateOtp();

        redisOtpService.saveOtp(email, otp);

        emailService.sendOtpEmail(email, otp);

        return ResponseEntity
                .ok()
                .body(ApiResponse.<Void>builder()
                        .code(1000)
                        .message("OTP code sent successfully")
                        .build());
    }

    @PostMapping("/verify-otp")
    @Operation(summary = "Xác thực OTP")
    public ResponseEntity<ApiResponse<Void>> verifyOtp(@RequestBody VerifyRequest body){
        boolean verified = authService.verifyEmail(body.getEmail(), body.getOtpCode());

        if (!verified) {
            return ResponseEntity
                    .badRequest()
                    .body(ApiResponse.<Void>builder()
                            .code(ErrorCode.INVALID_OTP.getCode())
                            .message(ErrorCode.INVALID_OTP.getMessage())
                            .build());
        }

        return ResponseEntity
                .ok()
                .body(ApiResponse.<Void>builder()
                        .code(1000)
                        .message("Email verified successfully")
                        .build());
    }

    @PostMapping("/reset-password/{OTP}")
    @Operation(summary = "Đặt lại mật khẩu", description = "Đặt lại mật khẩu mới cho tài khoản đã xác thực OTP thành công")
    public ResponseEntity<ApiResponse<Void>> resetPassword(@RequestBody ResetPasswordRequest request,
                                                           @PathVariable String OTP) {
        String email = request.getEmail();
        String newPassword = request.getNewPassword();

        authService.resetPassword(email, OTP, newPassword);
        return ResponseEntity
                .ok()
                .body(ApiResponse.<Void>builder()
                        .code(1000)
                        .message("Password reset successfully")
                        .build());
    }

}
