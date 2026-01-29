package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.QuizAttemptRequest;
import com.vocaflipbackend.dto.request.QuizRequest;
import com.vocaflipbackend.dto.response.QuizAttemptResponse;
import com.vocaflipbackend.dto.response.QuizResponse;

public interface QuizService {
    QuizResponse createQuiz(QuizRequest request, String deckId);
    QuizAttemptResponse startAttempt(String userId, String quizId);
    QuizAttemptResponse submitAttempt(String attemptId, QuizAttemptRequest request);
}
