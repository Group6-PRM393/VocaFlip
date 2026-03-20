package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.UpdateProfileRequest;
import com.vocaflipbackend.dto.request.UserRegisterRequest;
import com.vocaflipbackend.dto.response.UserResponse;

import java.util.Optional;

public interface UserService {
    UserResponse createUser(UserRegisterRequest request);

    Optional<UserResponse> getUserById(String id);

    Optional<UserResponse> getUserByEmail(String email);

    UserResponse updateUser(String id, UserRegisterRequest request);

    UserResponse updateProfile(String userId, UpdateProfileRequest request);

    /** Cập nhật avatarUrl sau khi upload ảnh lên Cloudinary thành công. */
    UserResponse updateAvatar(String userId, String avatarUrl);

    void changePassword(String userId, com.vocaflipbackend.dto.request.ChangePasswordRequest request);
}