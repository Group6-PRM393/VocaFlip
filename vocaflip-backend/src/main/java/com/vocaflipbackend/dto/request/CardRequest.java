package com.vocaflipbackend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CardRequest {
    @NotBlank(message = "Front content is required")
    private String front;

    @NotBlank(message = "Back content is required")
    private String back;

    private String phonetic;
    private String exampleSentence;
    private String audioUrl;
    private String imageUrl;
}
