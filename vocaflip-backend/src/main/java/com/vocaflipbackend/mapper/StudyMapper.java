package com.vocaflipbackend.mapper;

import com.vocaflipbackend.dto.response.StudySessionResponse;
import com.vocaflipbackend.entity.StudySession;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface StudyMapper {
    @Mapping(target = "userId", source = "user.id")
    @Mapping(target = "deckId", source = "deck.id")
    StudySessionResponse toResponse(StudySession session);
}
