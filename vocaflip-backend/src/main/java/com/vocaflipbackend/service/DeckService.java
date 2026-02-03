package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.DeckRequest;
import com.vocaflipbackend.dto.response.DeckResponse;
import com.vocaflipbackend.dto.response.PageResponse;

import java.util.List;
import java.util.Optional;

public interface DeckService {
    DeckResponse createDeck(DeckRequest request, String userId);
    DeckResponse getDeckById(String id);
    DeckResponse updateDeck(String id, DeckRequest request);
    List<DeckResponse> getDecksByUserId(String userId);
    void deleteDeck(String id);
    
    /**
     * Tìm kiếm Deck theo keyword với phân trang
     * @param keyword từ khóa tìm kiếm (tìm trong title và description)
     * @param page số trang (0-indexed)
     * @param pageSize số lượng phần tử mỗi trang
     * @return PageResponse chứa danh sách DeckResponse và thông tin phân trang
     */
    PageResponse<DeckResponse> searchDecks(String keyword, int page, int pageSize);
}

