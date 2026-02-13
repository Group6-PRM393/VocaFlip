package com.vocaflipbackend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CardRequest {
    @NotBlank(message = "CARD_FRONT_REQUIRED")
    private String front;

    @NotBlank(message = "CARD_BACK_REQUIRED")
    private String back;

    private String phonetic;
    private String exampleSentence;
    private String audioUrl;
    private String imageUrl;
}
