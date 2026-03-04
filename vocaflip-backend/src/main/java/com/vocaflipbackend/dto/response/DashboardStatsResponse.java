package com.vocaflipbackend.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
@Builder
public class DashboardStatsResponse {
    private int streakDays;
    private int totalWords;
    private String totalStudyTime;

    // Data cho Pie Chart: { "MASTERED": 10, "LEARNING": 5 ... }
    private Map<String, Long> wordMastery;

    // Data cho Heatmap: [{date: "2023-10-25", count: 15, level: 2}]
    private List<Map<String, Object>> activityLog;
}