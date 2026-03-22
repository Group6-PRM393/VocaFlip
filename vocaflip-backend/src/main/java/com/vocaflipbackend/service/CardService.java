package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.CardRequest;
import com.vocaflipbackend.dto.request.FlipMatchGameResultRequest;
import com.vocaflipbackend.dto.response.CardResponse;
import com.vocaflipbackend.dto.response.FlipMatchDeckResponse;
import com.vocaflipbackend.dto.response.FlipMatchGameHistoryResponse;
import com.vocaflipbackend.dto.response.FlipMatchGameSummaryResponse;
import com.vocaflipbackend.dto.response.TranslationResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface CardService {
    CardResponse createCard(CardRequest request, MultipartFile image, String userId, String deckId);

    List<CardResponse> getCardsByDeckId(String deckId);

    List<CardResponse> getFlipMatchCardsForCurrentUser(int limit);

    List<CardResponse> getFlipMatchCardsByDeckForCurrentUser(String deckId, int limit);

    List<FlipMatchDeckResponse> getEligibleFlipMatchDecksForCurrentUser(int minCards);

    FlipMatchGameSummaryResponse saveFlipMatchResultForCurrentUser(FlipMatchGameResultRequest request);

    List<FlipMatchGameHistoryResponse> getFlipMatchHistoryForCurrentUser(int limit);

    FlipMatchGameSummaryResponse getFlipMatchSummaryForCurrentUser();

    CardResponse updateCard(String id, CardRequest request, MultipartFile image);

    void deleteCard(String id);

    TranslationResponse fetchDictionaryData(String word);
}
