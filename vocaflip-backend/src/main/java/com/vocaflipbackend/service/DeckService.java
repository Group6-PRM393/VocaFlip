package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.DeckRequest;
import com.vocaflipbackend.dto.response.DeckResponse;

import java.util.List;
import java.util.Optional;

public interface DeckService {
    DeckResponse createDeck(DeckRequest request, String userId);
    Optional<DeckResponse> getDeckById(String id);
    
    List<DeckResponse> getDecksByUserId(String userId);
    void deleteDeck(String id);
}
