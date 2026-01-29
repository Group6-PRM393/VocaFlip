package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.UserRegisterRequest;
import com.vocaflipbackend.dto.response.UserResponse;
import com.vocaflipbackend.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;

    @PostMapping("/register")
    public ResponseEntity<UserResponse> register(@Valid @RequestBody UserRegisterRequest request) {
        return ResponseEntity.ok(userService.createUser(request));
    }
    
    // Placeholder login endpoint
    @PostMapping("/login")
    public ResponseEntity<String> login() {
        return ResponseEntity.ok("Login endpoint placeholder");
    }
}
