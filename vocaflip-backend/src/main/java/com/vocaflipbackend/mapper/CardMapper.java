package com.vocaflipbackend.mapper;

import com.vocaflipbackend.dto.request.CardRequest;
import com.vocaflipbackend.dto.response.CardResponse;
import com.vocaflipbackend.entity.Card;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface CardMapper {
    Card toEntity(CardRequest request);
    
    @Mapping(target = "deckId", source = "deck.id")
    CardResponse toResponse(Card card);
}
