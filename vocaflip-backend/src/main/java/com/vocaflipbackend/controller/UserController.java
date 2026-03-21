package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.UpdateProfileRequest;
import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.UserResponse;
import com.vocaflipbackend.service.AuthService;
import com.vocaflipbackend.service.CloudinaryService;
import com.vocaflipbackend.service.UserService;
import com.vocaflipbackend.utils.SecurityUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * UserController — Các endpoint liên quan đến thông tin người dùng đang đăng nhập.
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
    private final CloudinaryService cloudinaryService;

    // Các định dạng ảnh được chấp nhận
    private static final List<String> ALLOWED_CONTENT_TYPES = List.of(
            "image/jpeg", "image/png", "image/webp", "image/gif"
    );
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB

    @GetMapping("/me")
    @Operation(summary = "Lấy thông tin user hiện tại",
            description = "Trả về thông tin user đang đăng nhập dựa trên JWT access token.",
            security = @SecurityRequirement(name = "Bearer Authentication"))
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser() {
        log.info("Get current user request received");
        UserResponse userResponse = authService.getCurrentUser();
        return ResponseEntity.ok(ApiResponse.<UserResponse>builder()
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
        return ResponseEntity.ok(ApiResponse.<UserResponse>builder()
                .code(1000)
                .message("Profile updated successfully")
                .result(userResponse)
                .build());
    }

    /**
     * Upload / thay đổi ảnh đại diện.
     * Nhận multipart/form-data với field "file".
     * Trả về UserResponse đã cập nhật avatarUrl mới.
     */
    @PutMapping(value = "/me/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Cập nhật ảnh đại diện",
            description = "Upload ảnh mới lên Cloudinary và cập nhật avatarUrl của user. "
                    + "Chấp nhận: JPEG, PNG, WEBP, GIF. Kích thước tối đa: 5 MB.",
            security = @SecurityRequirement(name = "Bearer Authentication"))
    public ResponseEntity<ApiResponse<UserResponse>> uploadAvatar(
            @RequestParam("file") MultipartFile file) {

        String userId = SecurityUtils.getCurrentUserId();
        log.info("Upload avatar request received for user: {}, file: {}, size: {} bytes",
                userId, file.getOriginalFilename(), file.getSize());

        // --- Validate file ---
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(ApiResponse.<UserResponse>builder()
                    .code(4001)
                    .message("File không được để trống.")
                    .build());
        }
        if (file.getSize() > MAX_FILE_SIZE) {
            return ResponseEntity.badRequest().body(ApiResponse.<UserResponse>builder()
                    .code(4002)
                    .message("File vượt quá kích thước tối đa 5 MB.")
                    .build());
        }
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType)) {
            return ResponseEntity.badRequest().body(ApiResponse.<UserResponse>builder()
                    .code(4003)
                    .message("Định dạng file không hợp lệ. Chấp nhận: JPEG, PNG, WEBP, GIF.")
                    .build());
        }

        // --- Upload lên Cloudinary ---
        String avatarUrl = cloudinaryService.uploadAvatar(file, userId);

        // --- Cập nhật avatarUrl vào DB ---
        UserResponse userResponse = userService.updateAvatar(userId, avatarUrl);

        return ResponseEntity.ok(ApiResponse.<UserResponse>builder()
                .code(1000)
                .message("Avatar updated successfully")
                .result(userResponse)
                .build());
    }

    @PutMapping("/me/password")
    @Operation(summary = "Đổi mật khẩu",
            description = "Đổi mật khẩu của user đang đăng nhập.",
            security = @SecurityRequirement(name = "Bearer Authentication"))
    public ResponseEntity<ApiResponse<Void>> changePassword(
            @Valid @RequestBody com.vocaflipbackend.dto.request.ChangePasswordRequest request) {
        String userId = SecurityUtils.getCurrentUserId();
        log.info("Change password request received for user: {}", userId);
        userService.changePassword(userId, request);
        return ResponseEntity.ok(ApiResponse.<Void>builder()
                .code(1000)
                .message("Password changed successfully")
                .build());
    }
}