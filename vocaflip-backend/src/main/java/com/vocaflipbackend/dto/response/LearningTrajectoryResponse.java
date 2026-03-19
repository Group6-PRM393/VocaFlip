package com.vocaflipbackend.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class LearningTrajectoryResponse {
    private int currentMonthLearnedWords;
    private int previousMonthLearnedWords;
    private double trendPercent;
    private List<LearningTrajectoryPointResponse> series;
}
