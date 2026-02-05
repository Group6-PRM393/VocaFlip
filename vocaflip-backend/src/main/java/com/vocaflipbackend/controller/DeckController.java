package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.DeckRequest;
import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.DeckResponse;
import com.vocaflipbackend.dto.response.PageResponse;
import com.vocaflipbackend.service.DeckService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * Controller quản lý các thao tác CRUD với Deck (Bộ thẻ)
 */
@RestController
@RequestMapping("/api/decks")
@RequiredArgsConstructor
@Tag(name = "Decks", description = "Quản lý bộ thẻ flashcard")
public class DeckController {

    private final DeckService deckService;

    @Operation(summary = "Lấy danh sách Deck của người dùng",
            description = "Trả về tất cả các bộ thẻ thuộc về một người dùng cụ thể")
    @GetMapping("/user/{userId}")
    public ApiResponse<List<DeckResponse>> getUserDecks(@Parameter(description = "ID của người dùng") @PathVariable String userId) {
        return ApiResponse.<List<DeckResponse>>builder()
                .result(deckService.getDecksByUserId(userId))
                .build();
    }

    @Operation(summary = "Lấy chi tiết Deck", description = "Trả về thông tin chi tiết của một bộ thẻ theo ID")
    @GetMapping("/{deckId}")
    public ApiResponse<DeckResponse> getDeck(
            @Parameter(description = "ID của Deck") @PathVariable String deckId) {
        return ApiResponse.<DeckResponse>builder()
                .result(deckService.getDeckById(deckId))
                .build();
    }

    @Operation(summary = "Tạo Deck mới",
            description = "Tạo một bộ thẻ flashcard mới với tùy chọn upload ảnh bìa")
    @PostMapping(value = "/user/{userId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<DeckResponse> createDeck(
            @Parameter(description = "ID người dùng tạo Deck") @PathVariable String userId,
            @Parameter(description = "Tiêu đề của Deck") @RequestParam String title,
            @Parameter(description = "Mô tả của Deck") @RequestParam(required = false) String description,
            @Parameter(description = "ID danh mục") @RequestParam String category,
            @Parameter(description = "Ảnh bìa của Deck (tùy chọn)")
            @RequestPart(value = "coverImage", required = false) MultipartFile coverImage) {
        
        // Tạo DeckRequest từ các tham số riêng lẻ
        DeckRequest request = new DeckRequest(title, description, category);
        
        return ApiResponse.<DeckResponse>builder()
                .message("Deck created successfully")
                .result(deckService.createDeck(request, userId, coverImage))
                .build();
    }

    @Operation(summary = "Xóa Deck", description = "Xóa mềm một bộ thẻ (soft delete)")
    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteDeck(
            @Parameter(description = "ID của Deck cần xóa") @PathVariable String id) {
        deckService.deleteDeck(id);
        return ApiResponse.<Void>builder()
                .message("Deck deleted successfully")
                .build();
    }

    @Operation(summary = "Cập nhật Deck",
            description = "Cập nhật thông tin bộ thẻ với tùy chọn thay đổi ảnh bìa")
    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<DeckResponse> updateDeck(
            @Parameter(description = "ID của Deck") @PathVariable String id,
            @Parameter(description = "Tiêu đề mới của Deck") @RequestParam(required = false) String title,
            @Parameter(description = "Mô tả mới của Deck") @RequestParam(required = false) String description,
            @Parameter(description = "ID danh mục mới") @RequestParam(required = false) String category,
            @Parameter(description = "Ảnh bìa mới (tùy chọn)")
            @RequestPart(value = "coverImage", required = false) MultipartFile coverImage) {
        
        // Tạo DeckRequest từ các tham số riêng lẻ
        DeckRequest request = new DeckRequest(title, description, category);
        
        return ApiResponse.<DeckResponse>builder()
                .message("Deck updated successfully")
                .result(deckService.updateDeck(id, request, coverImage))
                .build();
    }

    @Operation(summary = "Tìm kiếm Deck", description = "Tìm kiếm bộ thẻ theo từ khóa với phân trang")
    @GetMapping("/search")
    public ApiResponse<PageResponse<DeckResponse>> searchDecks(
            @Parameter(description = "Từ khóa tìm kiếm")
            @RequestParam(required = false, defaultValue = "") String keyword,
            @Parameter(description = "Số trang (bắt đầu từ 0)")
            @RequestParam(required = false, defaultValue = "0") int page,
            @Parameter(description = "Số lượng kết quả mỗi trang")
            @RequestParam(required = false, defaultValue = "5") int pageSize) {
        return ApiResponse.<PageResponse<DeckResponse>>builder()
                .result(deckService.searchDecks(keyword, page, pageSize))
                .build();
    }
}
