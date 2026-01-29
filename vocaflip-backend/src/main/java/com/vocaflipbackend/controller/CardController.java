package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.CardRequest;
import com.vocaflipbackend.dto.response.CardResponse;
import com.vocaflipbackend.service.CardService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cards")
@RequiredArgsConstructor
public class CardController {

    private final CardService cardService;

    @PostMapping
    public ResponseEntity<CardResponse> createCard(@Valid @RequestBody CardRequest request, @RequestParam String deckId) {
        return ResponseEntity.ok(cardService.createCard(request, deckId));
    }

    @GetMapping("/deck/{deckId}")
    public ResponseEntity<List<CardResponse>> getCardsByDeck(@PathVariable String deckId) {
        return ResponseEntity.ok(cardService.getCardsByDeckId(deckId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CardResponse> updateCard(@PathVariable String id, @RequestBody CardRequest request) {
        return ResponseEntity.ok(cardService.updateCard(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCard(@PathVariable String id) {
        cardService.deleteCard(id);
        return ResponseEntity.noContent().build();
    }
}
