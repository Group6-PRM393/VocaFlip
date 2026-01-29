package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.UserRegisterRequest;
import com.vocaflipbackend.dto.response.UserResponse;

import java.util.Optional;

public interface UserService {
    UserResponse createUser(UserRegisterRequest request);
    Optional<UserResponse> getUserById(String id);
    Optional<UserResponse> getUserByEmail(String email);
    UserResponse updateUser(String id, UserRegisterRequest request);
}
