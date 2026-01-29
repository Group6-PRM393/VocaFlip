package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.DeckRequest;
import com.vocaflipbackend.dto.response.DeckResponse;
import com.vocaflipbackend.service.DeckService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/decks")
@RequiredArgsConstructor
public class DeckController {

    private final DeckService deckService;

    @PostMapping
    public ResponseEntity<DeckResponse> createDeck(@Valid @RequestBody DeckRequest request, @RequestParam String userId) {
        return ResponseEntity.ok(deckService.createDeck(request, userId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DeckResponse> getDeck(@PathVariable String id) {
        return deckService.getDeckById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<DeckResponse>> getUserDecks(@PathVariable String userId) {
        return ResponseEntity.ok(deckService.getDecksByUserId(userId));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDeck(@PathVariable String id) {
        deckService.deleteDeck(id);
        return ResponseEntity.noContent().build();
    }
}
