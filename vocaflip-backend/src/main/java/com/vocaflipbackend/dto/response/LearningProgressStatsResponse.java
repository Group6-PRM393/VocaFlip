package com.vocaflipbackend.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.Map;

@Data
@Builder
public class LearningProgressStatsResponse {
    private int streakDays;
    private int totalWords;
    private String totalStudyTime;
    private double accuracyPercent;

    // Data cho Pie Chart: { "MASTERED": 10, "LEARNING": 5 ... }
    private Map<String, Long> wordMastery;

    private LearningTrajectoryResponse learningTrajectory;
}
