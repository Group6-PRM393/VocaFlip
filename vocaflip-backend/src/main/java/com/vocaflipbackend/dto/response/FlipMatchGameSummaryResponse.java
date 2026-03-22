package com.vocaflipbackend.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class FlipMatchGameSummaryResponse {
    private long totalScore;
    private long totalGames;
    private int bestScore;
    private List<Integer> top3Scores;
}
