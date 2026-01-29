package com.vocaflipbackend.dto.response;

import lombok.Data;

@Data
public class CardResponse {
    private String id;
    private String front;
    private String back;
    private String phonetic;
    private String exampleSentence;
    private String audioUrl;
    private String imageUrl;
    private String deckId;
}
