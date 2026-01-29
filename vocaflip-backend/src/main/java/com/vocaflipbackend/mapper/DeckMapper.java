package com.vocaflipbackend.mapper;

import com.vocaflipbackend.dto.request.DeckRequest;
import com.vocaflipbackend.dto.response.DeckResponse;
import com.vocaflipbackend.entity.Deck;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface DeckMapper {
    Deck toEntity(DeckRequest request);
    
    @Mapping(target = "userId", source = "user.id")
    DeckResponse toResponse(Deck deck);
}
