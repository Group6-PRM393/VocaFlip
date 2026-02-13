package com.vocaflipbackend.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.vocaflipbackend.constants.CloudinaryConstants;
import com.vocaflipbackend.dto.request.CardRequest;
import com.vocaflipbackend.dto.response.CardResponse;
import com.vocaflipbackend.dto.response.TranslationResponse;
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
import com.vocaflipbackend.service.CloudinaryService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class CardServiceImpl implements CardService {

    private final CardRepository cardRepository;
    private final DeckRepository deckRepository;
    private final UserRepository userRepository;
    private final CardMapper cardMapper;
    private final CloudinaryService cloudinaryService;
    private final RestTemplate restTemplate;

    @Override
    public CardResponse createCard(CardRequest request, MultipartFile image, String userId, String deckId) {
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

        // Upload image if provided
        if (image != null && !image.isEmpty()) {
            String imageUrl = uploadCardImage(image);
            card.setImageUrl(imageUrl);
        }

        Card savedCard = cardRepository.save(card);

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
    public CardResponse updateCard(String id, CardRequest request, MultipartFile image) {
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

        // Handle image update - prioritize uploaded file over URL
        if (image != null && !image.isEmpty()) {
            String imageUrl = uploadCardImage(image);
            card.setImageUrl(imageUrl);
        } else if (request.getImageUrl() != null) {
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


    @Override
    public TranslationResponse fetchDictionaryData(String word) {
        try {
            String url = "https://api.dictionaryapi.dev/api/v2/entries/en/" + word;
            log.info("Calling dictionary API: {}", url);

            // Get response as String first to debug
            String jsonResponse = restTemplate.getForObject(url, String.class);
            log.info("API response (raw): {}", jsonResponse);

            if (jsonResponse == null || jsonResponse.isEmpty()) {
                log.warn("API returned empty response for word: {}", word);
                return null;
            }

            // Parse JSON manually
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            JsonNode root = mapper.readTree(jsonResponse);
            log.info("Parsed JSON: {}", root);

            if (!root.isArray() || root.size() == 0) {
                log.warn("API response is not a valid array for word: {}", word);
                return null;
            }

            JsonNode first = root.get(0);
            String wordResult = first.path("word").asText(word);
            String phonetic = first.path("phonetic").asText("");

            // Find audio URL
            String audio = "";
            JsonNode phonetics = first.path("phonetics");
            if (phonetics.isArray()) {
                for (JsonNode p : phonetics) {
                    String audioUrl = p.path("audio").asText("");
                    if (!audioUrl.isEmpty()) {
                        audio = audioUrl;
                        break;
                    }
                }
            }

            // Get meaning and example
            String meaning = "";
            String exampleSentence = "";

            JsonNode meanings = first.path("meanings");
            if (meanings.isArray() && meanings.size() > 0) {
                JsonNode firstMeaning = meanings.get(0);
                JsonNode definitions = firstMeaning.path("definitions");
                if (definitions.isArray() && definitions.size() > 0) {
                    JsonNode firstDef = definitions.get(0);
                    meaning = firstDef.path("definition").asText("");
                    exampleSentence = firstDef.path("example").asText("");
                }
            }

            TranslationResponse response = TranslationResponse.builder()
                    .word(wordResult)
                    .phonetic(phonetic)
                    .audioUrl(audio)
                    .meaning(meaning)
                    .exampleSentence(exampleSentence)
                    .build();

            log.info("Successfully fetched dictionary data for: {}", word);
            return response;
        } catch (Exception e) {
            log.error("Error fetching dictionary data for word: {}", word, e);
            return null;
        }
    }

    private String uploadCardImage(MultipartFile image) {
        Map<String, Object> uploadResult = cloudinaryService.uploadImage(
                image,
                CloudinaryConstants.CARDS_FOLDER,
                CloudinaryConstants.COVER_WIDTH, // Custom width for cards
                CloudinaryConstants.COVER_HEIGHT // Custom height for cards
        );
        return (String) uploadResult.get("secure_url");
    }

}
