package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.request.CardRequest;
import com.vocaflipbackend.dto.response.CardResponse;
import com.vocaflipbackend.entity.Card;
import com.vocaflipbackend.entity.Deck;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.exception.AppException;
import com.vocaflipbackend.exception.ErrorCode;
import com.vocaflipbackend.mapper.CardMapper;
import com.vocaflipbackend.repository.CardRepository;
import com.vocaflipbackend.repository.DeckRepository;
import com.vocaflipbackend.repository.UserRepository;
import com.vocaflipbackend.service.CardService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class CardServiceImpl implements CardService {

    private final CardRepository cardRepository;
    private final DeckRepository deckRepository;
    private final UserRepository userRepository;
    private final CardMapper cardMapper;

    @Override
    public CardResponse createCard(CardRequest request, String userId, String deckId) {
        // after have Sercurity context will not need pass userId
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));

        Deck deck = deckRepository.findById(deckId)
                .orElseThrow(() -> new AppException(ErrorCode.DECK_NOT_FOUND));
        
        // Check if deck is removed
        if (deck.isRemoved()) {
            throw new AppException(ErrorCode.DECK_NOT_FOUND);
        }
        
        // Validate ownership: user must be owner of the deck
        if (!deck.getUser().getId().equals(userId)) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }
        
        Card card = cardMapper.toEntity(request);
        card.setDeck(deck);
        Card savedCard = cardRepository.save(card); // Need save() for new entity (transient state)
        
        // Update deck total cards & update by user
        int currentTotal = deck.getTotalCards() != null ? deck.getTotalCards() : 0;
        deck.setTotalCards(currentTotal + 1);

        // after have Sercurity context will not need pass userId
        deck.setUpdatedBy(user.getId());
        
        return cardMapper.toResponse(savedCard);
    }

    @Override
    public List<CardResponse> getCardsByDeckId(String deckId) {
        boolean deckExists = deckRepository.findById(deckId)
                .map(deck -> !deck.isRemoved())
                .orElse(false);

        if (!deckExists) {
            throw new AppException(ErrorCode.DECK_NOT_FOUND);
        }
        return cardRepository.findByDeckIdAndIsRemovedFalse(deckId).stream()
                .map(cardMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public CardResponse updateCard(String id, CardRequest request) {
        Card card = cardRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.CARD_NOT_FOUND));

        // Check if card is removed
        if (card.isRemoved()) {
            throw new AppException(ErrorCode.CARD_NOT_FOUND);
        }

        if (request.getFront() != null && !request.getFront().isBlank()) {
            card.setFront(request.getFront());
        }
        if (request.getBack() != null && !request.getBack().isBlank()) {
            card.setBack(request.getBack());
        }
        if (request.getPhonetic() != null) {
            card.setPhonetic(request.getPhonetic());
        }
        if (request.getExampleSentence() != null) {
            card.setExampleSentence(request.getExampleSentence());
        }
        if (request.getAudioUrl() != null) {
            card.setAudioUrl(request.getAudioUrl());
        }
        if (request.getImageUrl() != null) {
            card.setImageUrl(request.getImageUrl());
        }
        
        return cardMapper.toResponse(card);
    }

    @Override
    public void deleteCard(String id) {
        Card card = cardRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.CARD_NOT_FOUND));
        
        // Check if card is already removed to prevent double deletion
        if (card.isRemoved()) {
            throw new AppException(ErrorCode.CARD_NOT_FOUND);
        }
        
        // Soft delete
        card.setRemoved(true);

        Deck deck = card.getDeck();
        if (deck != null && !deck.isRemoved()) {
            // Update total cards count (excluding removed)
            int newTotal = deck.getTotalCards() > 0 ? deck.getTotalCards() - 1 : 0;
            deck.setTotalCards(newTotal);
        }
    }
}
