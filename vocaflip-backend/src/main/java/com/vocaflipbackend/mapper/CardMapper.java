package com.vocaflipbackend.mapper;

import com.vocaflipbackend.dto.request.CardRequest;
import com.vocaflipbackend.dto.response.CardResponse;
import com.vocaflipbackend.entity.Card;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CardMapper {
    Card toEntity(CardRequest request);
    
    @Mapping(target = "deckId", source = "deck.id")
    CardResponse toResponse(Card card);
}
