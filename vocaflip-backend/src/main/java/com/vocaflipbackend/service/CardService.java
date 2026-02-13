package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.CardRequest;
import com.vocaflipbackend.dto.response.CardResponse;
import com.vocaflipbackend.dto.response.TranslationResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface CardService {
    CardResponse createCard(CardRequest request, MultipartFile image, String userId, String deckId);
    List<CardResponse> getCardsByDeckId(String deckId);
    CardResponse updateCard(String id, CardRequest request, MultipartFile image);
    void deleteCard(String id);
    TranslationResponse translate(String word);
}
