package com.vocaflipbackend.mapper;

import com.vocaflipbackend.dto.request.UserRegisterRequest;
import com.vocaflipbackend.dto.response.UserResponse;
import com.vocaflipbackend.entity.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UserMapper {
    @Mapping(target = "passwordHash", source = "password") // Temporary mapping logic placeholder
    User toEntity(UserRegisterRequest request);
    
    UserResponse toResponse(User user);
}
