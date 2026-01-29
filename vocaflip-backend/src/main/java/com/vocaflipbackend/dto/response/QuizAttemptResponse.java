package com.vocaflipbackend.dto.response;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class QuizAttemptResponse {
    private String id;
    private Integer totalQuestions;
    private Integer correctAnswers;
    private Integer incorrectAnswers;
    private BigDecimal scorePercentage;
    private Integer timeTakenSeconds;
    private String answersJson;
    private LocalDateTime completedAt;
    private String userId;
    private String quizId;
    private String deckId;
}
