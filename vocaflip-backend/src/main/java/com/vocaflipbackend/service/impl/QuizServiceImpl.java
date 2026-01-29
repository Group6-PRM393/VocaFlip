package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.request.QuizAttemptRequest;
import com.vocaflipbackend.dto.request.QuizRequest;
import com.vocaflipbackend.dto.response.QuizAttemptResponse;
import com.vocaflipbackend.dto.response.QuizResponse;
import com.vocaflipbackend.entity.Deck;
import com.vocaflipbackend.entity.Quiz;
import com.vocaflipbackend.entity.QuizAttempt;
import com.vocaflipbackend.entity.User;
import com.vocaflipbackend.mapper.QuizMapper;
import com.vocaflipbackend.repository.DeckRepository;
import com.vocaflipbackend.repository.QuizAttemptRepository;
import com.vocaflipbackend.repository.QuizRepository;
import com.vocaflipbackend.repository.UserRepository;
import com.vocaflipbackend.service.QuizService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class QuizServiceImpl implements QuizService {

    private final QuizRepository quizRepository;
    private final QuizAttemptRepository quizAttemptRepository;
    private final DeckRepository deckRepository;
    private final UserRepository userRepository;
    private final QuizMapper quizMapper;

    @Override
    public QuizResponse createQuiz(QuizRequest request, String deckId) {
        Deck deck = deckRepository.findById(deckId)
                .orElseThrow(() -> new RuntimeException("Deck not found"));
        
        Quiz quiz = quizMapper.toEntity(request);
        quiz.setDeck(deck);
        Quiz savedQuiz = quizRepository.save(quiz);
        return quizMapper.toResponse(savedQuiz);
    }

    @Override
    public QuizAttemptResponse startAttempt(String userId, String quizId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz not found"));

        QuizAttempt attempt = QuizAttempt.builder()
                .user(user)
                .quiz(quiz)
                .deck(quiz.getDeck())
                .totalQuestions(quiz.getTotalQuestions())
                .build();
        
        QuizAttempt savedAttempt = quizAttemptRepository.save(attempt);
        return toAttemptResponse(savedAttempt);
    }

    @Override
    public QuizAttemptResponse submitAttempt(String attemptId, QuizAttemptRequest request) {
        QuizAttempt attempt = quizAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new RuntimeException("Attempt not found"));

        attempt.setCorrectAnswers(request.getCorrectAnswers());
        attempt.setIncorrectAnswers(request.getIncorrectAnswers());
        attempt.setScorePercentage(request.getScorePercentage());
        attempt.setTimeTakenSeconds(request.getTimeTakenSeconds());
        attempt.setAnswersJson(request.getAnswersJson());
        
        QuizAttempt savedAttempt = quizAttemptRepository.save(attempt);
        return toAttemptResponse(savedAttempt);
    }

    // Manual mapper for QuizAttempt since we didn't create MapStruct for it yet
    // To strictly follow "move mapper logic to impl", this manual mapping stays here 
    // or we create a real mapper. Given the flow, I'll keep this helper here for now.
    private QuizAttemptResponse toAttemptResponse(QuizAttempt attempt) {
        QuizAttemptResponse response = new QuizAttemptResponse();
        response.setId(attempt.getId());
        response.setTotalQuestions(attempt.getTotalQuestions());
        response.setCorrectAnswers(attempt.getCorrectAnswers());
        response.setIncorrectAnswers(attempt.getIncorrectAnswers());
        response.setScorePercentage(attempt.getScorePercentage());
        response.setTimeTakenSeconds(attempt.getTimeTakenSeconds());
        response.setAnswersJson(attempt.getAnswersJson());
        response.setCompletedAt(attempt.getCompletedAt());
        if (attempt.getUser() != null) response.setUserId(attempt.getUser().getId());
        if (attempt.getQuiz() != null) response.setQuizId(attempt.getQuiz().getId());
        if (attempt.getDeck() != null) response.setDeckId(attempt.getDeck().getId());
        return response;
    }
}
