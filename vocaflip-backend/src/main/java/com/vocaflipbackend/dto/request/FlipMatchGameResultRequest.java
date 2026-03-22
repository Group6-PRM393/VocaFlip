package com.vocaflipbackend.dto.request;

import lombok.Data;

@Data
public class FlipMatchGameResultRequest {
    private String deckId;
    private Integer score;
    private Integer seconds;
    private Integer cardCount;
    private Integer moves;
    private String playedAt;
}
