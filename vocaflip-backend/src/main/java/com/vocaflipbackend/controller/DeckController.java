package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.DeckRequest;
import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.DeckResponse;
import com.vocaflipbackend.dto.response.PageResponse;
import com.vocaflipbackend.service.DeckService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/decks")
@RequiredArgsConstructor
public class DeckController {

    private final DeckService deckService;

    // Get List Deck by user ID
    @GetMapping("/user/{userId}")
    public ApiResponse<List<DeckResponse>> getUserDecks(@PathVariable String userId) {
        return ApiResponse.<List<DeckResponse>>builder()
                .result(deckService.getDecksByUserId(userId))
                .build();
    }

    // Get Deck by Deck ID
    @GetMapping("/{deckId}")
    public ApiResponse<DeckResponse> getDeck(@PathVariable String deckId) {
        return ApiResponse.<DeckResponse>builder()
                .result(deckService.getDeckById(deckId))
                .build();
    }

    // Create Deck
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<DeckResponse> createDeck(
            @Valid @RequestPart("deck") DeckRequest request,
            @RequestParam String userId,
            @RequestPart(value = "coverImage", required = false) MultipartFile coverImage) {
        return ApiResponse.<DeckResponse>builder()
                .message("Deck created successfully")
                .result(deckService.createDeck(request, userId, coverImage))
                .build();
    }

    // Delete Deck (soft delete)
    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteDeck(@PathVariable String id) {
        deckService.deleteDeck(id);
        return ApiResponse.<Void>builder()
                .message("Deck deleted successfully")
                .build();
    }

    // Update Deck
    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<DeckResponse> updateDeck(
            @PathVariable String id,
            @Valid @RequestPart("deck") DeckRequest request,
            @RequestPart(value = "coverImage", required = false) MultipartFile coverImage) {
        return ApiResponse.<DeckResponse>builder()
                .message("Deck updated successfully")
                .result(deckService.updateDeck(id, request, coverImage))
                .build();
    }

    // Search Decks with pagination
    @GetMapping("/search")
    public ApiResponse<PageResponse<DeckResponse>> searchDecks(
            @RequestParam(required = false, defaultValue = "") String keyword,
            @RequestParam(required = false, defaultValue = "0") int page,
                    @RequestParam(required = false, defaultValue = "5") int pageSize) {
            return ApiResponse.<PageResponse<DeckResponse>>builder()
                            .result(deckService.searchDecks(keyword, page, pageSize))
                            .build();
    }

}


