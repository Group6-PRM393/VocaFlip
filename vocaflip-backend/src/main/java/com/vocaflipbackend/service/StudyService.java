package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.response.StudySessionResponse;

public interface StudyService {
    StudySessionResponse startSession(String deckId);

    StudySessionResponse startDailyReview();

    void submitCardResult(String sessionId, String cardId, int grade, int responseTimeSeconds);

    StudySessionResponse completeSession(String sessionId);

    int getDueCardsCount();

    int cleanupAbandonedSessions();
}

