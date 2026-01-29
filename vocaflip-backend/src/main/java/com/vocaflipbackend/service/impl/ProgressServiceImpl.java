package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.response.UserProgressResponse;
import com.vocaflipbackend.entity.Card;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.entity.UserProgress;
import com.vocaflipbackend.enums.LearningStatus;
import com.vocaflipbackend.mapper.UserProgressMapper;
import com.vocaflipbackend.repository.CardRepository;
import com.vocaflipbackend.repository.UserProgressRepository;
import com.vocaflipbackend.repository.UserRepository;
import com.vocaflipbackend.service.ProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProgressServiceImpl implements ProgressService {

    private final UserProgressRepository userProgressRepository;
    private final UserRepository userRepository;
    private final CardRepository cardRepository;
    private final UserProgressMapper userProgressMapper;

    @Override
    public void updateProgress(String userId, String cardId, LearningStatus status) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));
                
        UserProgress progress = userProgressRepository.findByUserIdAndCardId(userId, cardId)
                .orElse(UserProgress.builder()
                        .user(user)
                        .card(card)
                        .easeFactor(BigDecimal.valueOf(2.5))
                        .intervalDays(0)
                        .reviewCount(0)
                        .correctCount(0)
                        .incorrectCount(0)
                        .build());
        
        progress.setStatus(status);
        progress.setLastReviewedAt(LocalDateTime.now());
        // Simple mock Spaced Repetition logic implementation
        if (status == LearningStatus.MASTERED) {
            progress.setIntervalDays(progress.getIntervalDays() == 0 ? 1 : progress.getIntervalDays() * 2);
            progress.setNextReviewAt(LocalDateTime.now().plusDays(progress.getIntervalDays()));
            progress.setCorrectCount(progress.getCorrectCount() + 1);
        } else {
            progress.setIntervalDays(1);
            progress.setNextReviewAt(LocalDateTime.now().plusDays(1));
            progress.setIncorrectCount(progress.getIncorrectCount() + 1);
        }
        
        userProgressRepository.save(progress);
    }

    @Override
    public Optional<UserProgressResponse> getProgress(String userId, String cardId) {
        return userProgressRepository.findByUserIdAndCardId(userId, cardId)
                .map(userProgressMapper::toResponse);
    }
}
