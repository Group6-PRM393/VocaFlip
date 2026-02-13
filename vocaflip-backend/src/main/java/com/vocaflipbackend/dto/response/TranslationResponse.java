package com.vocaflipbackend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TranslationResponse {
    private String word;
    private String meaning;
    private String phonetic;
    private String exampleSentence;
    private String audioUrl;
}
