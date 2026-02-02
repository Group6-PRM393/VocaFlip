package com.vocaflipbackend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategoryResponse {
    private String id;
    private String categoryName;
    private String userId;
    private boolean isRemoved;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
