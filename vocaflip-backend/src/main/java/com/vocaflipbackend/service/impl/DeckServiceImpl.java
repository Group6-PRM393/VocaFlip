package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.request.DeckRequest;
import com.vocaflipbackend.dto.response.DeckResponse;
import com.vocaflipbackend.entity.Deck;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.mapper.DeckMapper;
import com.vocaflipbackend.entity.Category;
import com.vocaflipbackend.repository.CategoryRepository;
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
    private final CategoryRepository categoryRepository;
    private final DeckMapper deckMapper;

    @Override
    public DeckResponse createDeck(DeckRequest request, String userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Deck deck = deckMapper.toEntity(request);
        deck.setUser(user);

        if (request.getCategory() != null) {
            // Assuming request.category is the Category ID
            Category category = categoryRepository.findById(request.getCategory())
                    .orElseThrow(() -> new RuntimeException("Category not found"));
            deck.setCategory(category);
        } else {
             throw new RuntimeException("Category is required");
        }
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
        return deckRepository.findByUserIdAndIsRemovedFalse(userId).stream()
                .map(deckMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public void deleteDeck(String id) {
        Deck deck = deckRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Deck not found"));
        deck.setRemoved(true);
        deckRepository.save(deck);
    }
}
