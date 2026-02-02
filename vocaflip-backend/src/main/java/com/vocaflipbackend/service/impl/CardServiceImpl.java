package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.request.CardRequest;
import com.vocaflipbackend.dto.response.CardResponse;
import com.vocaflipbackend.entity.Card;
import com.vocaflipbackend.entity.Deck;
import com.vocaflipbackend.mapper.CardMapper;
import com.vocaflipbackend.repository.CardRepository;
import com.vocaflipbackend.repository.DeckRepository;
import com.vocaflipbackend.service.CardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CardServiceImpl implements CardService {

    private final CardRepository cardRepository;
    private final DeckRepository deckRepository;
    private final CardMapper cardMapper;

    @Override
    public CardResponse createCard(CardRequest request, String deckId) {
        Deck deck = deckRepository.findById(deckId)
                .orElseThrow(() -> new RuntimeException("Deck not found"));
        
        Card card = cardMapper.toEntity(request);
        card.setDeck(deck);
        Card savedCard = cardRepository.save(card);
        
        // Update deck total cards
        deck.setTotalCards(deck.getCards().size());
        deckRepository.save(deck);
        
        return cardMapper.toResponse(savedCard);
    }

    @Override
    public List<CardResponse> getCardsByDeckId(String deckId) {
        return cardRepository.findByDeckIdAndIsRemovedFalse(deckId).stream()
                .map(cardMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public CardResponse updateCard(String id, CardRequest request) {
        Card card = cardRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Card not found"));
        
        // Manual mapping for update, or use MapStruct @MappingTarget in future
        card.setFront(request.getFront());
        card.setBack(request.getBack());
        card.setImageUrl(request.getImageUrl());
        card.setAudioUrl(request.getAudioUrl());
        
        Card updatedCard = cardRepository.save(card);
        return cardMapper.toResponse(updatedCard);
    }

    @Override
    public void deleteCard(String id) {
        Card card = cardRepository.findById(id).orElseThrow(() -> new RuntimeException("Card not found"));
        
        // Soft delete
        card.setRemoved(true);
        cardRepository.save(card);
        
        Deck deck = card.getDeck();
        if (deck != null) {
            // Update total cards count (excluding removed)
            // Ideally should query count of non-removed cards, but simple decrement works if we assume consistency
            int newTotal = deck.getTotalCards() > 0 ? deck.getTotalCards() - 1 : 0;
            deck.setTotalCards(newTotal);
            deckRepository.save(deck);
        }
    }
}
