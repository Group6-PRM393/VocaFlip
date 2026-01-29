package com.vocaflipbackend.dto.response;

import lombok.Data;

@Data
public class UserResponse {
    private String id;
    private String name;
    private String email;
    private String avatarUrl;
    private Integer totalWords;
    private Integer masteredWords;
    private Integer learningWords;
    private Integer streakDays;
}
