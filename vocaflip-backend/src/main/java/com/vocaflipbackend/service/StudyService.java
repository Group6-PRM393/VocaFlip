package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.response.StudySessionResponse;
import com.vocaflipbackend.dto.response.StudyCardResponse;

import java.util.List;

public interface StudyService {
    StudySessionResponse startSession(String deckId);

    StudySessionResponse startDailyReview();

    void submitCardResult(String sessionId, String cardId, int grade, int responseTimeSeconds);

    StudySessionResponse completeSession(String sessionId);

    int getDueCardsCount();

    List<StudyCardResponse> getUpcomingDueCards(int withinHours);

    int cleanupAbandonedSessions();
}

