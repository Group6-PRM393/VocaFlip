package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.request.UpdateProfileRequest;
import com.vocaflipbackend.dto.request.UserRegisterRequest;
import com.vocaflipbackend.dto.response.UserResponse;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.exception.AppException;
import com.vocaflipbackend.exception.ErrorCode;
import com.vocaflipbackend.mapper.UserMapper;
import com.vocaflipbackend.repository.UserRepository;
import com.vocaflipbackend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;

    @Override
    public UserResponse createUser(UserRegisterRequest request) {
        User user = userMapper.toEntity(request);
        // Here you might want to encode the password before saving
        User savedUser = userRepository.save(user);
        return userMapper.toResponse(savedUser);
    }

    @Override
    public Optional<UserResponse> getUserById(String id) {
        return userRepository.findById(id).map(userMapper::toResponse);
    }

    @Override
    public Optional<UserResponse> getUserByEmail(String email) {
        return userRepository.findByEmail(email).map(userMapper::toResponse);
    }

    @Override
    public UserResponse updateUser(String id, UserRegisterRequest request) {
        return userRepository.findById(id).map(user -> {
            user.setName(request.getName());
            // Update other fields as needed
            User savedUser = userRepository.save(user);
            return userMapper.toResponse(savedUser);
        }).orElseThrow(() -> new RuntimeException("User not found with id " + id));
    }

    @Override
    @Transactional
    public UserResponse updateProfile(String userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));

        userMapper.updateEntity(request, user);
        User savedUser = userRepository.save(user);
        return userMapper.toResponse(savedUser);
    }
}
