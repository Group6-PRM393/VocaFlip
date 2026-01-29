package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.response.StudySessionResponse;
import com.vocaflipbackend.entity.*;
import com.vocaflipbackend.mapper.StudyMapper;
import com.vocaflipbackend.repository.*;
import com.vocaflipbackend.service.StudyService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class StudyServiceImpl implements StudyService {

    private final StudySessionRepository studySessionRepository;
    private final SessionCardRepository sessionCardRepository;
    private final UserRepository userRepository;
    private final CardRepository cardRepository;
    private final DeckRepository deckRepository;
    private final StudyMapper studyMapper;

    @Override
    public StudySessionResponse startSession(String userId, String deckId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Deck deck = deckRepository.findById(deckId)
                .orElseThrow(() -> new RuntimeException("Deck not found"));
        
        StudySession session = StudySession.builder()
                .user(user)
                .deck(deck)
                .totalCards(deck.getTotalCards())
                .build();
        
        StudySession savedSession = studySessionRepository.save(session);
        return studyMapper.toResponse(savedSession);
    }

    @Override
    public void submitCardResult(String sessionId, String cardId, boolean isRemembered, int responseTimeSeconds) {
        StudySession session = studySessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));
        
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));
        
        // Record this specific interaction
        SessionCard sessionCard = SessionCard.builder()
                .session(session)
                .card(card)
                .isRemembered(isRemembered)
                .responseTimeSeconds(responseTimeSeconds)
                .build();
        
        sessionCardRepository.save(sessionCard);
        
        // Update session live stats
        if (isRemembered) {
            session.setRememberedCount(session.getRememberedCount() + 1);
        } else {
            session.setForgotCount(session.getForgotCount() + 1);
        }
        studySessionRepository.save(session);
    }

    @Override
    public StudySessionResponse completeSession(String sessionId) {
        StudySession session = studySessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));
        
        session.setCompletedAt(LocalDateTime.now());
        // Calculate duration if needed, e.g. from createdAt to now
        StudySession savedSession = studySessionRepository.save(session);
        return studyMapper.toResponse(savedSession);
    }
}
