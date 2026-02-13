package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.CardRequest;
import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.CardResponse;
import com.vocaflipbackend.dto.response.TranslationResponse;
import com.vocaflipbackend.service.CardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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

    @Operation(summary = "Tạo thẻ mới", description = "Tạo một thẻ flashcard mới với tùy chọn upload ảnh")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<CardResponse> createCard(
            @Parameter(description = "ID của Deck chứa thẻ") @RequestParam String deckId,
            @Parameter(description = "Mặt trước của thẻ") @RequestParam String front,
            @Parameter(description = "Mặt sau của thẻ") @RequestParam String back,
            @Parameter(description = "Phiên âm") @RequestParam(required = false) String phonetic,
            @Parameter(description = "Câu ví dụ") @RequestParam(required = false) String exampleSentence,
            @Parameter(description = "URL audio") @RequestParam(required = false) String audioUrl,
            @Parameter(description = "URL ảnh") @RequestParam(required = false) String imageUrl,
            @Parameter(description = "File ảnh (tùy chọn)") @RequestPart(required = false) MultipartFile image) {

        CardRequest request = CardRequest.builder()
                .front(front)
                .back(back)
                .phonetic(phonetic)
                .exampleSentence(exampleSentence)
                .audioUrl(audioUrl)
                .imageUrl(imageUrl)
                .build();

        String userId = "u001"; // Hardcoded user ID for demonstration
        return ApiResponse.<CardResponse>builder()
                .message("Card created successfully")
                .result(cardService.createCard(request, image, userId, deckId))
                .build();
    }

    @Operation(summary = "Lấy danh sách thẻ trong Deck", description = "Trả về tất cả các thẻ thuộc một bộ thẻ cụ thể")
    @GetMapping("/deck/{deckId}")
    public ApiResponse<List<CardResponse>> getCardsByDeck(
            @Parameter(description = "ID của Deck") @PathVariable String deckId) {
        return ApiResponse.<List<CardResponse>>builder()
                .result(cardService.getCardsByDeckId(deckId))
                .build();
    }

    @Operation(summary = "Cập nhật thẻ", description = "Cập nhật thông tin của một thẻ flashcard với tùy chọn thay đổi ảnh")
    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<CardResponse> updateCard(
            @Parameter(description = "ID của thẻ cần cập nhật") @PathVariable String id,
            @Parameter(description = "Mặt trước mới") @RequestParam(required = false) String front,
            @Parameter(description = "Mặt sau mới") @RequestParam(required = false) String back,
            @Parameter(description = "Phiên âm mới") @RequestParam(required = false) String phonetic,
            @Parameter(description = "Câu ví dụ mới") @RequestParam(required = false) String exampleSentence,
            @Parameter(description = "URL audio mới") @RequestParam(required = false) String audioUrl,
            @Parameter(description = "URL ảnh mới") @RequestParam(required = false) String imageUrl,
            @Parameter(description = "File ảnh mới (tùy chọn)") @RequestPart(required = false) MultipartFile image) {

        CardRequest request = CardRequest.builder()
                .front(front)
                .back(back)
                .phonetic(phonetic)
                .exampleSentence(exampleSentence)
                .audioUrl(audioUrl)
                .imageUrl(imageUrl)
                .build();

        return ApiResponse.<CardResponse>builder()
                .message("Card updated successfully")
                .result(cardService.updateCard(id, request, image))
                .build();
    }

    @Operation(summary = "Dịch từ vựng", description = "Tự động dịch từ vựng, cung cấp phiên âm và ví dụ")
    @GetMapping("/translate")
    public ApiResponse<TranslationResponse> translate(
            @Parameter(description = "Từ cần dịch") @RequestParam String word) {
        return ApiResponse.<TranslationResponse>builder()
                .result(cardService.fetchDictionaryData(word))
                .build();
    }

    @Operation(summary = "Xóa thẻ", description = "Xóa một thẻ flashcard khỏi bộ thẻ")
    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteCard(
            @Parameter(description = "ID của thẻ cần xóa") @PathVariable String id) {
        cardService.deleteCard(id);
        return ApiResponse.<Void>builder()
                .message("Card deleted successfully")
                .build();
    }
}
