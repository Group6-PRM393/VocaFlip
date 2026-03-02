package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.UserResponse;
import com.vocaflipbackend.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * UserController — Các endpoint liên quan đến thông tin người dùng đang đăng
 * nhập.
 * Toàn bộ endpoints ở đây yêu cầu authentication (JWT Bearer token).
 */
@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "User", description = "API thông tin người dùng (yêu cầu authentication)")
public class UserController {

    private final AuthService authService;

    /**
     * Lấy thông tin user đang đăng nhập từ SecurityContext.
     * Endpoint này nằm ngoài /api/auth/** nên luôn được bảo vệ bởi
     * JwtAuthenticationFilter.
     */
    @GetMapping("/me")
    @Operation(summary = "Lấy thông tin user hiện tại", description = "Trả về thông tin user đang đăng nhập dựa trên JWT access token.", security = @SecurityRequirement(name = "Bearer Authentication"))
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser() {
        log.info("Get current user request received");
        UserResponse userResponse = authService.getCurrentUser();
        return ResponseEntity
                .ok()
                .body(ApiResponse.<UserResponse>builder()
                        .code(1000)
                        .message("Success")
                        .result(userResponse)
                        .build());
    }
}
