package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.CardRequest;
import com.vocaflipbackend.dto.response.CardResponse;
import com.vocaflipbackend.service.CardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller quản lý các thao tác với Card (Thẻ flashcard)
 */
@RestController
@RequestMapping("/api/cards")
@RequiredArgsConstructor
@Tag(name = "Cards", description = "Quản lý thẻ flashcard trong bộ thẻ")
public class CardController {

    private final CardService cardService;

    @Operation(summary = "Tạo thẻ mới", description = "Tạo một thẻ flashcard mới trong bộ thẻ")
    @PostMapping
    public ResponseEntity<CardResponse> createCard(
            @Parameter(description = "Thông tin thẻ") @Valid @RequestBody CardRequest request, 
            @Parameter(description = "ID của Deck chứa thẻ") @RequestParam String deckId) {
        return ResponseEntity.ok(cardService.createCard(request, deckId));
    }

    @Operation(summary = "Lấy danh sách thẻ trong Deck", 
               description = "Trả về tất cả các thẻ thuộc một bộ thẻ cụ thể")
    @GetMapping("/deck/{deckId}")
    public ResponseEntity<List<CardResponse>> getCardsByDeck(
            @Parameter(description = "ID của Deck") @PathVariable String deckId) {
        return ResponseEntity.ok(cardService.getCardsByDeckId(deckId));
    }

    @Operation(summary = "Cập nhật thẻ", description = "Cập nhật thông tin của một thẻ flashcard")
    @PutMapping("/{id}")
    public ResponseEntity<CardResponse> updateCard(
            @Parameter(description = "ID của thẻ") @PathVariable String id, 
            @Parameter(description = "Thông tin cập nhật") @RequestBody CardRequest request) {
        return ResponseEntity.ok(cardService.updateCard(id, request));
    }

    @Operation(summary = "Xóa thẻ", description = "Xóa một thẻ flashcard khỏi bộ thẻ")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCard(
            @Parameter(description = "ID của thẻ cần xóa") @PathVariable String id) {
        cardService.deleteCard(id);
        return ResponseEntity.noContent().build();
    }
}
