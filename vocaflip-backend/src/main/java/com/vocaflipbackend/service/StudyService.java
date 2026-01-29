package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.response.StudySessionResponse;

public interface StudyService {
    StudySessionResponse startSession(String userId, String deckId);
    void submitCardResult(String sessionId, String cardId, boolean isRemembered, int responseTimeSeconds);
    StudySessionResponse completeSession(String sessionId);
}
