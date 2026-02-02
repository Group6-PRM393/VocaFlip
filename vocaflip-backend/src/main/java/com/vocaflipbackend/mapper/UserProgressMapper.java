package com.vocaflipbackend.mapper;

import com.vocaflipbackend.dto.response.UserProgressResponse;
import com.vocaflipbackend.entity.UserProgress;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface UserProgressMapper {
    @Mapping(target = "userId", source = "user.id")
    @Mapping(target = "cardId", source = "card.id")
    UserProgressResponse toResponse(UserProgress progress);
}
