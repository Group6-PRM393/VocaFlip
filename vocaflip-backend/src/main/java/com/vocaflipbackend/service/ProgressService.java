package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.response.LearningProgressStatsResponse;

public interface ProgressService {
    LearningProgressStatsResponse getLearningProgressStats(String userId);
}