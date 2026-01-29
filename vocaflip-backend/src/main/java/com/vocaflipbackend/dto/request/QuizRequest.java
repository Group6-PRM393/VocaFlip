package com.vocaflipbackend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class QuizRequest {
    @NotBlank(message = "Title is required")
    private String title;

    private Integer totalQuestions;
    private Integer timeLimitSeconds;
}
