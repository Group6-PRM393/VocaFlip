package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.request.QuizSubmissionRequest;
import com.vocaflipbackend.dto.request.UserAnswerRequest;
import com.vocaflipbackend.dto.response.*;
import com.vocaflipbackend.entity.*;
import com.vocaflipbackend.exception.AppException;
import com.vocaflipbackend.exception.ErrorCode;
import com.vocaflipbackend.repository.*;
import com.vocaflipbackend.service.QuizService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class QuizServiceImpl implements QuizService {

    private final DeckRepository deckRepository;
    private final QuizRepository quizRepository;
    private final UserRepository userRepository;
    private final CardRepository cardRepository;
    private final QuizAttemptRepository quizAttemptRepository;
    private final ObjectMapper objectMapper;

    @Override
    @Transactional
    public QuizSessionResponse generateQuiz(String userId, String deckId, int numberOfQuestions, int timeLimitSeconds) {
        Deck deck = deckRepository.findByIdAndIsRemovedFalse(deckId)
                .orElseThrow(() -> new AppException(ErrorCode.DECK_NOT_FOUND));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND));

        List<Card> questions = cardRepository.findRandomCardsByDeckId(deckId, numberOfQuestions);
        if (questions.isEmpty()) {
            throw new RuntimeException("Deck is empty, please add more card to create quiz!");
        }
        Quiz newQuiz = com.vocaflipbackend.entity.Quiz.builder()
                .title("Practice: " + deck.getTitle())
                .totalQuestions(questions.size())
                .timeLimitSeconds(timeLimitSeconds)
                .deck(deck)
                .isRemoved(false)
                .createdAt(LocalDateTime.now())
                .build();
        newQuiz = quizRepository.save(newQuiz);

        QuizAttempt attempt = QuizAttempt.builder()
                .quiz(newQuiz)
                .user(user)
                .deck(deck)
                .totalQuestions(questions.size())
                .correctAnswers(0)
                .incorrectAnswers(0)
                .scorePercentage(BigDecimal.ZERO)
                .timeTakenSeconds(0)
                .createdAt(LocalDateTime.now())
                .build();
        attempt = quizAttemptRepository.save(attempt);

        List<QuizQuestionResponse> questionsResponses = new ArrayList<>();

        for (Card card : questions) {
            List<QuizOptionResponse> options = new ArrayList<>();
            options.add(QuizOptionResponse.builder()
                    .optionId(card.getId())
                    .content(card.getBack())
                    .build());
            List<Card> distractors = cardRepository.findDistractors(deckId, card.getId());
            distractors.forEach(distractor -> options.add(QuizOptionResponse.builder()
                    .optionId(distractor.getId())
                    .content(distractor.getBack())
                    .build()));

            Collections.shuffle(options);

            questionsResponses.add(QuizQuestionResponse.builder()
                    .questionId(card.getId())
                    .questionText(card.getFront())
                    .questionType("MULTIPLE_CHOICE")
                    .audioUrl(card.getAudioUrl())
                    .options(options)
                    .build());
        }

        return QuizSessionResponse.builder()
                .attemptId(attempt.getId())
                .quizTitle(newQuiz.getTitle())
                .totalQuestions(questions.size())
                .timeLimitSeconds(timeLimitSeconds)
                .questions(questionsResponses)
                .build();
    }

    @Override
    public QuizAttemptResponse submitQuizAndGrade(String attemptId, QuizSubmissionRequest request) {
        QuizAttempt attempt = quizAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new RuntimeException("Attempt not found"));

        List<String> questionIds = request.getAnswers().stream()
                .map(UserAnswerRequest::getQuestionId).toList();
        Map<String, Card> cardMap = cardRepository.findAllById(questionIds).stream()
                .collect(Collectors.toMap(Card::getId, c -> c));

        int correctCount = 0;
        List<Map<String, Object>> detailedResults = new ArrayList<>();

        for (var userAnswer : request.getAnswers()) {
            Card card = cardMap.get(userAnswer.getQuestionId());
            String userInput = userAnswer.getSelectedOptionId() != null ? userAnswer.getSelectedOptionId().trim() : "";

            boolean isCorrect = false;
            if (card != null) {
                if (userInput.equals(card.getId())) {
                    isCorrect = true;
                } else if (userInput.equalsIgnoreCase(card.getBack().trim())) {
                    isCorrect = true;
                }
            }

            if (isCorrect) correctCount++;

            Map<String, Object> detail = new HashMap<>();
            detail.put("questionId", userAnswer.getQuestionId());
            detail.put("selected", userInput);
            detail.put("isCorrect", isCorrect);
            detailedResults.add(detail);
        }

        int total = attempt.getTotalQuestions();
        int incorrectCount = total - correctCount;
        double scorePercentage = (double) correctCount / (double) total * 100;

        attempt.setCorrectAnswers(correctCount);
        attempt.setIncorrectAnswers(incorrectCount);
        attempt.setScorePercentage(BigDecimal.valueOf(scorePercentage));
        attempt.setTimeTakenSeconds(request.getTimeTakenSeconds());
        attempt.setCompletedAt(LocalDateTime.now());

        attempt.setAnswersJson(objectMapper.writeValueAsString(detailedResults));

        quizAttemptRepository.save(attempt);

        QuizAttemptResponse response = new QuizAttemptResponse();
        response.setId(attemptId);
        response.setTotalQuestions(total);
        response.setCorrectAnswers(correctCount);
        response.setIncorrectAnswers(incorrectCount);
        response.setScorePercentage(BigDecimal.valueOf(scorePercentage));
        response.setTimeTakenSeconds(request.getTimeTakenSeconds());
        response.setCompletedAt(LocalDateTime.now());
        return response;
    }

    @Override
    public QuizReviewResponse getQuizReview(String attemptId) {
        QuizAttempt attempt = quizAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new RuntimeException("Attempt not found"));

        if (attempt.getAnswersJson() == null) {
            throw new RuntimeException("No details found for this attempt");
        }

        List<QuizReviewDetailResponse> reviewDetails = new ArrayList<>();

        try {
            List<Map<String, Object>> rawDetails = objectMapper.readValue(
                    attempt.getAnswersJson(),
                    new TypeReference<List<Map<String, Object>>>() {
                    }
            );

            Set<String> allPotentialIds = new HashSet<>();
            for (Map<String, Object> detail : rawDetails) {
                allPotentialIds.add((String) detail.get("questionId"));
                String selected = (String) detail.get("selected");
                if (selected != null && !selected.isEmpty()) {
                    allPotentialIds.add(selected);
                }
            }

            Map<String, Card> cardMap = cardRepository.findAllById(allPotentialIds).stream()
                    .collect(Collectors.toMap(Card::getId, card -> card));

            for (Map<String, Object> detail : rawDetails) {
                String questionId = (String) detail.get("questionId");
                String selected = (String) detail.get("selected");
                Card questionCard = cardMap.get(questionId);

                if (questionCard == null) continue;

                String userAnswerDisplay = "No Answer";
                boolean isCorrect = false;

                if (selected != null && !selected.isEmpty()) {
                    Card selectedCard = cardMap.get(selected);

                    if (selectedCard != null) {
                        userAnswerDisplay = selectedCard.getBack();
                        isCorrect = questionId.equals(selected);
                    } else {
                        userAnswerDisplay = selected;
                        isCorrect = selected.trim().equalsIgnoreCase(questionCard.getBack().trim());
                    }
                }

                reviewDetails.add(QuizReviewDetailResponse.builder()
                        .questionId(questionId)
                        .questionText(questionCard.getFront())
                        .correctAnswerText(questionCard.getBack())
                        .userAnswerText(userAnswerDisplay)
                        .isCorrect(isCorrect)
                        .build());
            }
        } catch (Exception e) {
            throw new RuntimeException("Error processing quiz review data: " + e.getMessage());
        }

        return QuizReviewResponse.builder()
                .attemptId(attempt.getId())
                .scorePercentage(attempt.getScorePercentage().doubleValue())
                .details(reviewDetails)
                .build();
    }
}
