package com.vocaflipbackend.dto.response;

import com.vocaflipbackend.enums.LearningStatus;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class UserProgressResponse {
    private String id;
    private LearningStatus status;
    private Integer reviewCount;
    private Integer correctCount;
    private Integer incorrectCount;
    private LocalDateTime lastReviewedAt;
    private LocalDateTime nextReviewAt;
    private BigDecimal easeFactor;
    private Integer intervalDays;
    private String userId;
    private String cardId;
}
