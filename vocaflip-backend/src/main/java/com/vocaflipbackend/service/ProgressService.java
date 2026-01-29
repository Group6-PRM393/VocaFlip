package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.response.UserProgressResponse;
import com.vocaflipbackend.enums.LearningStatus;

import java.util.Optional;

public interface ProgressService {
    void updateProgress(String userId, String cardId, LearningStatus status);
    Optional<UserProgressResponse> getProgress(String userId, String cardId);
}
