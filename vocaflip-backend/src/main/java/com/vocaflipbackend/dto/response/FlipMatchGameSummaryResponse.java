package com.vocaflipbackend.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FlipMatchGameSummaryResponse {
    private long totalScore;
    private long totalGames;
    private int bestScore;
}
