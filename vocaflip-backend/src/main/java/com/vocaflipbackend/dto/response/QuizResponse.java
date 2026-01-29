package com.vocaflipbackend.dto.response;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class QuizResponse {
    private String id;
    private String title;
    private Integer totalQuestions;
    private Integer timeLimitSeconds;
    private LocalDateTime createdAt;
    private String deckId;
}
