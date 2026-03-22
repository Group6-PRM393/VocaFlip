package com.vocaflipbackend.dto.response;

import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FlipMatchGameHistoryResponse {
    private String deckId;
    private String deckTitle;
    private Integer score;
    private Integer seconds;
    private Integer cardCount;
    private Integer moves;
    private String playedAt;
}
