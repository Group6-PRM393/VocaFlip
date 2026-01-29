package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.request.DeckRequest;
import com.vocaflipbackend.dto.response.DeckResponse;
import com.vocaflipbackend.entity.Deck;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.mapper.DeckMapper;
import com.vocaflipbackend.repository.DeckRepository;
import com.vocaflipbackend.repository.UserRepository;
import com.vocaflipbackend.service.DeckService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DeckServiceImpl implements DeckService {

    private final DeckRepository deckRepository;
    private final UserRepository userRepository;
    private final DeckMapper deckMapper;

    @Override
    public DeckResponse createDeck(DeckRequest request, String userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Deck deck = deckMapper.toEntity(request);
        deck.setUser(user);
        // Default totalCards is 0 via builder/entity default
        Deck savedDeck = deckRepository.save(deck);
        return deckMapper.toResponse(savedDeck);
    }

    @Override
    public Optional<DeckResponse> getDeckById(String id) {
        return deckRepository.findById(id).map(deckMapper::toResponse);
    }


    @Override
    public List<DeckResponse> getDecksByUserId(String userId) {
        return deckRepository.findByUserId(userId).stream()
                .map(deckMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public void deleteDeck(String id) {
        deckRepository.deleteById(id);
    }
}
