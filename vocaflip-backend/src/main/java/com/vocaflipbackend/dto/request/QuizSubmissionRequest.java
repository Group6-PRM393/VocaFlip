package com.vocaflipbackend.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

import java.util.List;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
public class QuizSubmissionRequest {

    @NotNull(message = "Time taken cannot be null")
    Integer timeTakenSeconds;

    @NotNull(message = "Answers list cannot be null")
    List<UserAnswerRequest> answers;
}
