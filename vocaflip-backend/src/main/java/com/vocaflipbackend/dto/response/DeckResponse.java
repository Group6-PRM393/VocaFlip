package com.vocaflipbackend.dto.response;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class DeckResponse {
    private String id;
    private String title;
    private String description;
    private String category;
    private String coverImageUrl;
    private Integer totalCards;

    private LocalDateTime createdAt;
    private String userId; // Or UserResponse if strict nesting needed
}
