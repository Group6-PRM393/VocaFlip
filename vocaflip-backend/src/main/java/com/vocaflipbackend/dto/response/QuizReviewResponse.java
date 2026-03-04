package com.vocaflipbackend.dto.response;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;

import java.util.List;

@Data
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class QuizReviewResponse {
    String attemptId;
    double scorePercentage;
    List<QuizReviewDetailResponse> details;
}
