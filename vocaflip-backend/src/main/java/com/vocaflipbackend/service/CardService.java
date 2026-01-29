package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.CardRequest;
import com.vocaflipbackend.dto.response.CardResponse;

import java.util.List;

public interface CardService {
    CardResponse createCard(CardRequest request, String deckId);
    List<CardResponse> getCardsByDeckId(String deckId);
    CardResponse updateCard(String id, CardRequest request);
    void deleteCard(String id);
}
