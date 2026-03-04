package com.vocaflipbackend.dto.response;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;

import java.util.List;

@Data
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class QuizSessionResponse {
    String attemptId;
    String quizTitle;
    Integer totalQuestions;
    Integer timeLimitSeconds;
    List<QuizQuestionResponse> questions;
}
