package com.vocaflipbackend.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class QuizReviewDetailResponse {
    String questionId;
    String questionText;
    String userAnswerText;
    String correctAnswerText;
    @JsonProperty("isCorrect")
    boolean isCorrect;
}
