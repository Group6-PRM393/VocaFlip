package com.vocaflipbackend.mapper;

import com.vocaflipbackend.dto.request.DeckRequest;
import com.vocaflipbackend.dto.response.DeckResponse;
import com.vocaflipbackend.entity.Deck;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface DeckMapper {
    @Mapping(target = "category", ignore = true)
    Deck toEntity(DeckRequest request);
    
    @Mapping(target = "userId", source = "user.id")
    @Mapping(target = "category", source = "category.categoryName")
    DeckResponse toResponse(Deck deck);
}
