package com.vocaflipbackend.dto.request;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class QuizAttemptRequest {
    private Integer correctAnswers;
    private Integer incorrectAnswers;
    private BigDecimal scorePercentage;
    private Integer timeTakenSeconds;
    private String answersJson;
}
