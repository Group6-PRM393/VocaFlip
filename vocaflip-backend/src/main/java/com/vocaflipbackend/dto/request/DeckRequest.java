package com.vocaflipbackend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class DeckRequest {
    @NotBlank(message = "Title is required")
    private String title;
    
    private String description;
    
    @NotBlank(message = "Category is required")
    private String category;
    
    private String coverImageUrl;

}
