package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.response.StudyCardResponse;
import com.vocaflipbackend.dto.response.StudySessionResponse;
import com.vocaflipbackend.entity.*;
import com.vocaflipbackend.enums.LearningStatus;
import com.vocaflipbackend.exception.AppException;
import com.vocaflipbackend.exception.ErrorCode;
import com.vocaflipbackend.mapper.StudyMapper;
import com.vocaflipbackend.repository.*;
import com.vocaflipbackend.service.LearningEngineService;
import com.vocaflipbackend.service.StudyService;
import com.vocaflipbackend.utils.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StudyServiceImpl implements StudyService {

    private final StudySessionRepository studySessionRepository;
    private final SessionCardRepository sessionCardRepository;
    private final UserRepository userRepository;
    private final CardRepository cardRepository;
    private final DeckRepository deckRepository;
    private final UserProgressRepository userProgressRepository;
    private final StudyMapper studyMapper;
    private final LearningEngineService learningEngineService;


    @Override
    @Transactional
    public StudySessionResponse startSession(String deckId) {
        String userId = SecurityUtils.getCurrentUserId();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));
        Deck deck = deckRepository.findById(deckId)
                .orElseThrow(() -> new AppException(ErrorCode.DECK_NOT_FOUND));

        // Lấy tất cả thẻ chưa bị xóa trong Deck
        List<Card> cards = cardRepository.findByDeckIdAndIsRemovedFalse(deckId);
        if (cards.isEmpty()) {
            throw new AppException(ErrorCode.DECK_EMPTY);
        }

        // Lấy tiến độ học của User cho tất cả thẻ này
        List<String> cardIds = cards.stream().map(Card::getId).collect(Collectors.toList());
        Map<String, UserProgress> progressMap = userProgressRepository
                .findByUserIdAndCardIdIn(userId, cardIds)
                .stream()
                .collect(Collectors.toMap(
                        progress -> progress.getCard().getId(),
                        progress -> progress
                ));

        // Map Card + UserProgress -> StudyCardResponse
        List<StudyCardResponse> studyCards = cards.stream()
                .map(card -> buildStudyCardResponse(card, progressMap.get(card.getId())))
                .collect(Collectors.toList());

        // Tạo phiên học mới
        StudySession session = StudySession.builder()
                .user(user)
                .deck(deck)
                .totalCards(cards.size())
                .build();
        StudySession savedSession = studySessionRepository.save(session);

        // Build response
        StudySessionResponse response = studyMapper.toResponse(savedSession);
        response.setCards(studyCards);
        return response;
    }


    @Override
    @Transactional
    public StudySessionResponse startDailyReview() {
        String userId = SecurityUtils.getCurrentUserId();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));

        // Lấy tất cả thẻ đến hạn ôn tập (nextReviewAt <= now) và chưa bị xóa
        List<UserProgress> dueProgress = userProgressRepository
                .findByUserIdAndNextReviewAtBeforeAndCard_IsRemovedFalse(userId, LocalDateTime.now());

        if (dueProgress.isEmpty()) {
            throw new AppException(ErrorCode.NO_CARDS_DUE);
        }

        // Map UserProgress -> StudyCardResponse (kèm trạng thái tiến độ)
        List<StudyCardResponse> studyCards = dueProgress.stream()
                .map(progress -> buildStudyCardResponse(progress.getCard(), progress))
                .collect(Collectors.toList());

        // Tạo phiên học mới (deck = null vì tổng hợp từ nhiều Deck)
        StudySession session = StudySession.builder()
                .user(user)
                .deck(null)
                .totalCards(studyCards.size())
                .build();
        StudySession savedSession = studySessionRepository.save(session);

        // Build response
        StudySessionResponse response = studyMapper.toResponse(savedSession);
        response.setCards(studyCards);
        return response;
    }

    @Override
    @Transactional
    public void submitCardResult(String sessionId, String cardId, int grade, int responseTimeSeconds) {
        String currentUserId = SecurityUtils.getCurrentUserId();
        StudySession session = studySessionRepository.findById(sessionId)
                .orElseThrow(() -> new AppException(ErrorCode.SESSION_NOT_FOUND));

        // Kiểm tra quyền sở hữu: Session phải thuộc về user đang đăng nhập
        if (!session.getUser().getId().equals(currentUserId)) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new AppException(ErrorCode.CARD_NOT_FOUND));

        //Lấy hoặc tạo UserProgress hiện tại
        UserProgress progress = userProgressRepository.findByUserIdAndCardId(session.getUser().getId(), cardId)
                .orElse(UserProgress.builder()
                        .user(session.getUser())
                        .card(card)
                        .status(LearningStatus.NEW)
                        .reviewCount(0)
                        .intervalDays(0)
                        .easeFactor(java.math.BigDecimal.valueOf(2.5))
                        .correctCount(0)
                        .incorrectCount(0)
                        .build());

        //Gọi Learning Engine để tính toán SM-2
        LearningEngineService.SM2Result result = learningEngineService.calculate(
                progress.getIntervalDays(),
                progress.getEaseFactor(),
                progress.getReviewCount(),
                grade
        );

        //Cập nhật UserProgress
        progress.setEaseFactor(result.newEaseFactor());
        progress.setIntervalDays(result.newInterval());
        progress.setReviewCount(result.newReviewCount());
        progress.setLastReviewedAt(LocalDateTime.now());

        // Tính ngày review tiếp theo
        progress.setNextReviewAt(LocalDateTime.now().plusDays(result.newInterval()));

        // Cập nhật trạng thái học (Logic 2 chiều: có thể lên MASTERED hoặc xuống LEARNING)
        if (result.newInterval() > 21) {
            progress.setStatus(LearningStatus.MASTERED);
        } else {
            progress.setStatus(LearningStatus.LEARNING);
        }

        // Cập nhật số câu đúng/sai
        boolean isRemembered = grade >= 2; // 2 (Good) và 3 (Easy) coi như nhớ
        if (isRemembered) {
            progress.setCorrectCount(progress.getCorrectCount() + 1);
        } else {
            progress.setIncorrectCount(progress.getIncorrectCount() + 1);
        }

        userProgressRepository.save(progress);

        //Lưu lịch sử phiên học (SessionCard)
        SessionCard sessionCard = SessionCard.builder()
                .session(session)
                .card(card)
                .isRemembered(isRemembered) // Map grade -> boolean
                .responseTimeSeconds(responseTimeSeconds)
                .build();
        sessionCardRepository.save(sessionCard);

        //Cập nhật thống kê phiên học hiện tại
        if (isRemembered) {
            session.setRememberedCount(session.getRememberedCount() + 1);
        } else {
            session.setForgotCount(session.getForgotCount() + 1);
        }
        studySessionRepository.save(session);
    }

    @Override
    @Transactional
    public StudySessionResponse completeSession(String sessionId) {
        String currentUserId = SecurityUtils.getCurrentUserId();
        StudySession session = studySessionRepository.findById(sessionId)
                .orElseThrow(() -> new AppException(ErrorCode.SESSION_NOT_FOUND));

        // Kiểm tra quyền sở hữu
        if (!session.getUser().getId().equals(currentUserId)) {
            throw new AppException(ErrorCode.UNAUTHORIZED);
        }

        session.setCompletedAt(LocalDateTime.now());

        // Tính thời gian học (từ lúc tạo đến lúc hoàn thành)
        if (session.getCreatedAt() != null) {
            long durationSeconds = Duration.between(
                    session.getCreatedAt(), session.getCompletedAt()
            ).getSeconds();
            session.setDurationSeconds((int) durationSeconds);
        }

        StudySession savedSession = studySessionRepository.save(session);
        return studyMapper.toResponse(savedSession);
    }

    // Build StudyCardResponse từ Card entity + UserProgress (nếu có).

    private StudyCardResponse buildStudyCardResponse(Card card, UserProgress progress) {
        return StudyCardResponse.builder()
                .cardId(card.getId())
                .front(card.getFront())
                .back(card.getBack())
                .phonetic(card.getPhonetic())
                .exampleSentence(card.getExampleSentence())
                .audioUrl(card.getAudioUrl())
                .imageUrl(card.getImageUrl())
                .orderIndex(card.getOrderIndex())
                .learningStatus(progress != null ? progress.getStatus() : LearningStatus.NEW)
                .currentInterval(progress != null ? progress.getIntervalDays() : 0)
                .reviewCount(progress != null ? progress.getReviewCount() : 0)
                .build();
    }
}

