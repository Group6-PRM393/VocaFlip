package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.response.StudySessionResponse;

public interface StudyService {
    StudySessionResponse startSession(String userId, String deckId);
    StudySessionResponse startDailyReview(String userId);
    void submitCardResult(String sessionId, String cardId, int grade, int responseTimeSeconds);
    StudySessionResponse completeSession(String sessionId);
}

