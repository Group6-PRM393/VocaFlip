package com.vocaflipbackend.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vocaflipbackend.constants.CloudinaryConstants;
import com.vocaflipbackend.constants.FlipMatchConstants;
import com.vocaflipbackend.dto.request.CardRequest;
import com.vocaflipbackend.dto.request.FlipMatchGameResultRequest;
import com.vocaflipbackend.dto.response.CardResponse;
import com.vocaflipbackend.dto.response.FlipMatchDeckResponse;
import com.vocaflipbackend.dto.response.FlipMatchGameHistoryResponse;
import com.vocaflipbackend.dto.response.FlipMatchGameSummaryResponse;
import com.vocaflipbackend.dto.response.TranslationResponse;
import com.vocaflipbackend.entity.Card;
import com.vocaflipbackend.entity.Deck;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.entity.UserProgress;
import com.vocaflipbackend.enums.LearningStatus;
import com.vocaflipbackend.exception.AppException;
import com.vocaflipbackend.exception.ErrorCode;
import com.vocaflipbackend.mapper.CardMapper;
import com.vocaflipbackend.repository.CardRepository;
import com.vocaflipbackend.repository.DeckRepository;
import com.vocaflipbackend.repository.UserProgressRepository;
import com.vocaflipbackend.repository.UserRepository;
import com.vocaflipbackend.service.CardService;
import com.vocaflipbackend.service.CloudinaryService;
import com.vocaflipbackend.utils.SecurityUtils;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.data.redis.core.StringRedisTemplate;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
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
    private final UserProgressRepository userProgressRepository;
    private final CardMapper cardMapper;
    private final CloudinaryService cloudinaryService;
    private final RestTemplate restTemplate;
    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;

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

        // Auto-fill missing fields from dictionary API (including audio URL)
        if (StringUtils.hasText(request.getFront())) {
            TranslationResponse translation = fetchDictionaryData(request.getFront().trim());
            if (translation != null) {
                if (!StringUtils.hasText(card.getBack()) && StringUtils.hasText(translation.getMeaning())) {
                    card.setBack(translation.getMeaning());
                }
                if (!StringUtils.hasText(card.getPhonetic()) && StringUtils.hasText(translation.getPhonetic())) {
                    card.setPhonetic(translation.getPhonetic());
                }
                if (!StringUtils.hasText(card.getExampleSentence()) && StringUtils.hasText(translation.getExampleSentence())) {
                    card.setExampleSentence(translation.getExampleSentence());
                }
                if (!StringUtils.hasText(card.getAudioUrl()) && StringUtils.hasText(translation.getAudioUrl())) {
                    card.setAudioUrl(translation.getAudioUrl());
                }
            }
        }

        // Upload image if provided
        if (image != null && !image.isEmpty()) {
            String imageUrl = uploadCardImage(image);
            card.setImageUrl(imageUrl);
        }

        Card savedCard = cardRepository.save(card);

        userProgressRepository.findByUserIdAndCardId(userId, savedCard.getId())
            .orElseGet(() -> userProgressRepository.save(
                UserProgress.builder()
                    .user(user)
                    .card(savedCard)
                    .status(LearningStatus.NEW)
                    .reviewCount(0)
                    .intervalDays(0)
                    .easeFactor(BigDecimal.valueOf(2.5))
                    .correctCount(0)
                    .incorrectCount(0)
                    .build()
            ));

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
    public List<CardResponse> getFlipMatchCardsForCurrentUser(int limit) {
        String userId = SecurityUtils.getCurrentUserId();
        if (!userRepository.existsById(userId)) {
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }

        int resolvedLimit = limit <= 0
            ? FlipMatchConstants.DEFAULT_CARD_FETCH_LIMIT
            : Math.min(limit, FlipMatchConstants.MAX_CARD_FETCH_LIMIT);

        return cardRepository.findRandomCardsByUserId(userId, resolvedLimit).stream()
                .map(cardMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<CardResponse> getFlipMatchCardsByDeckForCurrentUser(String deckId, int limit) {
        String userId = SecurityUtils.getCurrentUserId();
        if (!userRepository.existsById(userId)) {
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }

        long validCardCount = cardRepository.countValidCardsByUserIdAndDeckId(userId, deckId);
        if (validCardCount < FlipMatchConstants.DEFAULT_MIN_DECK_CARDS) {
            throw new AppException(ErrorCode.DECK_NOT_FOUND);
        }

        int resolvedLimit = limit <= 0
            ? FlipMatchConstants.DEFAULT_CARD_FETCH_LIMIT
            : Math.min(limit, FlipMatchConstants.MAX_CARD_FETCH_LIMIT);

        return cardRepository.findRandomCardsByUserIdAndDeckId(userId, deckId, resolvedLimit).stream()
                .map(cardMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<FlipMatchDeckResponse> getEligibleFlipMatchDecksForCurrentUser(int minCards) {
        String userId = SecurityUtils.getCurrentUserId();
        if (!userRepository.existsById(userId)) {
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }

        int resolvedMinCards = Math.max(FlipMatchConstants.DEFAULT_MIN_DECK_CARDS, minCards);
        return deckRepository.findEligibleDecksByUserId(userId, resolvedMinCards)
                .stream()
                .map(deck -> FlipMatchDeckResponse.builder()
                        .id(deck.getId())
                        .title(deck.getTitle())
                        .coverImageUrl(deck.getCoverImageUrl())
                        .totalCards(deck.getTotalCards() != null ? deck.getTotalCards() : 0)
                        .build())
                .collect(Collectors.toList());
    }

    @Override
    public FlipMatchGameSummaryResponse saveFlipMatchResultForCurrentUser(FlipMatchGameResultRequest request) {
        String userId = SecurityUtils.getCurrentUserId();
        if (!userRepository.existsById(userId)) {
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }

        int score = request.getScore() != null ? Math.max(0, request.getScore()) : 0;
        int seconds = request.getSeconds() != null ? Math.max(0, request.getSeconds()) : 0;
        int cardCount = request.getCardCount() != null ? Math.max(0, request.getCardCount()) : 0;
        int moves = request.getMoves() != null ? Math.max(0, request.getMoves()) : 0;
        String deckId = request.getDeckId();
        String deckTitle = null;

        if (StringUtils.hasText(deckId)) {
            deckTitle = deckRepository.findByIdAndIsRemovedFalse(deckId)
                    .filter(deck -> deck.getUser() != null && userId.equals(deck.getUser().getId()))
                    .map(Deck::getTitle)
                    .orElse(null);
        }

        FlipMatchGameHistoryResponse historyItem = FlipMatchGameHistoryResponse.builder()
                .deckId(deckId)
                .deckTitle(deckTitle)
                .score(score)
                .seconds(seconds)
                .cardCount(cardCount)
                .moves(moves)
                .playedAt(resolvePlayedAt(request.getPlayedAt()))
                .build();

        try {
            String historyJson = objectMapper.writeValueAsString(historyItem);
            redisTemplate.opsForList().leftPush(getHistoryKey(userId), historyJson);
            redisTemplate.opsForList().trim(getHistoryKey(userId), 0, FlipMatchConstants.MAX_HISTORY_LIMIT - 1);
            redisTemplate.opsForValue().increment(getTotalScoreKey(userId), score);
        } catch (Exception e) {
            throw new RuntimeException(FlipMatchConstants.SAVE_HISTORY_ERROR_MESSAGE, e);
        }

        return getFlipMatchSummaryForCurrentUser();
    }

    @Override
    public List<FlipMatchGameHistoryResponse> getFlipMatchHistoryForCurrentUser(int limit) {
        String userId = SecurityUtils.getCurrentUserId();
        if (!userRepository.existsById(userId)) {
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }

        int resolvedLimit = limit <= 0
            ? FlipMatchConstants.DEFAULT_HISTORY_LIMIT
            : Math.min(limit, FlipMatchConstants.MAX_HISTORY_LIMIT);

        List<String> rawItems = redisTemplate.opsForList().range(getHistoryKey(userId), 0, resolvedLimit - 1);
        if (rawItems == null || rawItems.isEmpty()) {
            return List.of();
        }

        List<FlipMatchGameHistoryResponse> parsed = new ArrayList<>();
        for (String raw : rawItems) {
            try {
                parsed.add(objectMapper.readValue(raw, FlipMatchGameHistoryResponse.class));
            } catch (Exception ignored) {
                // Ignore malformed records.
            }
        }
        return parsed;
    }

    @Override
    public FlipMatchGameSummaryResponse getFlipMatchSummaryForCurrentUser() {
        String userId = SecurityUtils.getCurrentUserId();
        if (!userRepository.existsById(userId)) {
            throw new AppException(ErrorCode.USER_NOT_FOUND);
        }

        String totalRaw = redisTemplate.opsForValue().get(getTotalScoreKey(userId));
        long totalScore = 0L;
        if (StringUtils.hasText(totalRaw)) {
            try {
                totalScore = Long.parseLong(totalRaw);
            } catch (NumberFormatException ignored) {
                totalScore = 0L;
            }
        }

        Long totalGamesRaw = redisTemplate.opsForList().size(getHistoryKey(userId));
        long totalGames = totalGamesRaw != null ? totalGamesRaw : 0L;

        int bestScore = 0;
        List<String> allItems = redisTemplate.opsForList().range(getHistoryKey(userId), 0, FlipMatchConstants.MAX_HISTORY_LIMIT - 1);
        if (allItems != null) {
            for (String raw : allItems) {
                try {
                    FlipMatchGameHistoryResponse item = objectMapper.readValue(raw, FlipMatchGameHistoryResponse.class);
                    int score = item.getScore() != null ? item.getScore() : 0;
                    if (score > bestScore) {
                        bestScore = score;
                    }
                } catch (Exception ignored) {
                    // Ignore malformed records.
                }
            }
        }

        return FlipMatchGameSummaryResponse.builder()
                .totalScore(totalScore)
                .totalGames(totalGames)
                .bestScore(bestScore)
                .build();
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

    private String getHistoryKey(String userId) {
        return FlipMatchConstants.REDIS_HISTORY_KEY_PREFIX + userId;
    }

    private String getTotalScoreKey(String userId) {
        return FlipMatchConstants.REDIS_TOTAL_SCORE_KEY_PREFIX + userId;
    }

    private String resolvePlayedAt(String playedAtRaw) {
        if (StringUtils.hasText(playedAtRaw)) {
            try {
                return LocalDateTime.parse(playedAtRaw).toString();
            } catch (DateTimeParseException ignored) {
                // Fall through to now.
            }
        }
        return LocalDateTime.now().toString();
    }

}
