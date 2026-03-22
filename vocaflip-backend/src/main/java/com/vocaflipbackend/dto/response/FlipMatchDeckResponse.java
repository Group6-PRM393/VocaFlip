package com.vocaflipbackend.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FlipMatchDeckResponse {
    private String id;
    private String title;
    private String coverImageUrl;
    private Integer totalCards;
}
