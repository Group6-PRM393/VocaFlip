package com.vocaflipbackend.mapper;

import com.vocaflipbackend.dto.request.QuizRequest;
import com.vocaflipbackend.dto.response.QuizResponse;
import com.vocaflipbackend.entity.Quiz;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface QuizMapper {
    Quiz toEntity(QuizRequest request);
    
    @Mapping(target = "deckId", source = "deck.id")
    QuizResponse toResponse(Quiz quiz);
}
