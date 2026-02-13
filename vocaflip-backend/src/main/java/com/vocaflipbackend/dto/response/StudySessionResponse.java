package com.vocaflipbackend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;


//DTO phiên học Deck
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StudySessionResponse {
    private String id;
    private Integer totalCards;
    private Integer rememberedCount;
    private Integer forgotCount;
    private Integer durationSeconds;
    private LocalDateTime completedAt;
    private LocalDateTime createdAt;
    private String userId;
    private String deckId;

    // Danh sách thẻ cần học trong phiên này
    private List<StudyCardResponse> cards;
}
