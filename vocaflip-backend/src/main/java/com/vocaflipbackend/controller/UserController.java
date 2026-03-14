package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.UpdateProfileRequest;
import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.UserResponse;
import com.vocaflipbackend.service.AuthService;
import com.vocaflipbackend.service.UserService;
import com.vocaflipbackend.utils.SecurityUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
    private final UserService userService;

    /**
     * Lấy thông tin user đang đăng nhập từ SecurityContext.
     * Endpoint này nằm ngoài /api/auth/** nên luôn được bảo vệ bởi
     * JwtAuthenticationFilter.
     */
    @GetMapping("/me")
    @Operation(summary = "Lấy thông tin user hiện tại",
               description = "Trả về thông tin user đang đăng nhập dựa trên JWT access token.",
               security = @SecurityRequirement(name = "Bearer Authentication"))
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

    @PutMapping("/me")
    @Operation(summary = "Cập nhật profile user hiện tại",
               description = "Cập nhật tên và avatar của user đang đăng nhập.",
               security = @SecurityRequirement(name = "Bearer Authentication"))
    public ResponseEntity<ApiResponse<UserResponse>> updateProfile(
            @Valid @RequestBody UpdateProfileRequest request) {
        String userId = SecurityUtils.getCurrentUserId();
        log.info("Update profile request received for user: {}", userId);
        UserResponse userResponse = userService.updateProfile(userId, request);
        return ResponseEntity
                .ok()
                .body(ApiResponse.<UserResponse>builder()
                        .code(1000)
                        .message("Profile updated successfully")
                        .result(userResponse)
                        .build());
    }
}
