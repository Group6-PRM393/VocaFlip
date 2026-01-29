package com.vocaflipbackend.dto.response;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class StudySessionResponse {
    private String id;
    private Integer totalCards;
    private Integer rememberedCount;
    private Integer forgotCount;
    private Integer durationSeconds;
    private LocalDateTime completedAt;
    private String userId;
    private String deckId;
}
