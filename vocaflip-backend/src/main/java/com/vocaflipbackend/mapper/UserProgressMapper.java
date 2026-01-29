package com.vocaflipbackend.mapper;

import com.vocaflipbackend.dto.response.UserProgressResponse;
import com.vocaflipbackend.entity.UserProgress;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UserProgressMapper {
    @Mapping(target = "userId", source = "user.id")
    @Mapping(target = "cardId", source = "card.id")
    UserProgressResponse toResponse(UserProgress progress);
}
