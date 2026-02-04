package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.UserRegisterRequest;
import com.vocaflipbackend.dto.response.UserResponse;
import com.vocaflipbackend.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controller xử lý các endpoint liên quan đến xác thực người dùng
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Các API liên quan đến xác thực và đăng ký người dùng")
public class AuthController {

    private final UserService userService;

    @Operation(summary = "Đăng ký tài khoản mới", description = "Tạo tài khoản người dùng mới với email và mật khẩu")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Đăng ký thành công"),
            @ApiResponse(responseCode = "400", description = "Dữ liệu đầu vào không hợp lệ"),
            @ApiResponse(responseCode = "409", description = "Email đã tồn tại")
    })
    @PostMapping("/register")
    public ResponseEntity<UserResponse> register(
            @Parameter(description = "Thông tin đăng ký người dùng") 
            @Valid @RequestBody UserRegisterRequest request) {
        return ResponseEntity.ok(userService.createUser(request));
    }
    
    @Operation(summary = "Đăng nhập", description = "Đăng nhập vào hệ thống (Placeholder)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Đăng nhập thành công"),
            @ApiResponse(responseCode = "401", description = "Thông tin đăng nhập không hợp lệ")
    })
    @PostMapping("/login")
    public ResponseEntity<String> login() {
        return ResponseEntity.ok("Login endpoint placeholder");
    }
}
