package com.vocaflipbackend.mapper;

import com.vocaflipbackend.dto.request.QuizRequest;
import com.vocaflipbackend.dto.response.QuizResponse;
import com.vocaflipbackend.entity.Quiz;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface QuizMapper {
    Quiz toEntity(QuizRequest request);
    
    @Mapping(target = "deckId", source = "deck.id")
    QuizResponse toResponse(Quiz quiz);
}
