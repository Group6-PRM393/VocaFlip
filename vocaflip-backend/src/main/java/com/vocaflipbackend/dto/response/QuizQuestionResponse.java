package com.vocaflipbackend.dto.response;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;

import java.util.List;

@Data
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class QuizQuestionResponse {
    String questionId;
    String questionText;
    String questionType;
    String audioUrl;
    List<QuizOptionResponse> options;
}
