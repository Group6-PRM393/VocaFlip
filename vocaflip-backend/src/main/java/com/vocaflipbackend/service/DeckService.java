package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.DeckRequest;
import com.vocaflipbackend.dto.response.DeckResponse;
import com.vocaflipbackend.dto.response.PageResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface DeckService {
    DeckResponse createDeck(DeckRequest request, String userId);
    
    // Create Deck with cover image upload
    DeckResponse createDeck(DeckRequest request, String userId, MultipartFile coverImage);
    
    DeckResponse getDeckById(String id);
    DeckResponse updateDeck(String id, DeckRequest request);
    
    // Update Deck with cover image upload
    DeckResponse updateDeck(String id, DeckRequest request, MultipartFile coverImage);
    
    List<DeckResponse> getDecksByUserId(String userId);
    void deleteDeck(String id);
    
    PageResponse<DeckResponse> searchDecks(String keyword, int page, int pageSize);
}


