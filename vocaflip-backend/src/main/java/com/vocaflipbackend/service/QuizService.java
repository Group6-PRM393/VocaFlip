package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.request.QuizAttemptRequest;
import com.vocaflipbackend.dto.request.QuizRequest;
import com.vocaflipbackend.dto.request.QuizSubmissionRequest;
import com.vocaflipbackend.dto.response.QuizAttemptResponse;
import com.vocaflipbackend.dto.response.QuizResponse;
import com.vocaflipbackend.dto.response.QuizReviewResponse;
import com.vocaflipbackend.dto.response.QuizSessionResponse;

public interface QuizService {
    QuizSessionResponse generateQuiz(String userId, String deckId, int numberOfQuestions, int timeLimitSeconds);

    QuizAttemptResponse submitQuizAndGrade(String attemptId, QuizSubmissionRequest request);

    QuizReviewResponse getQuizReview(String attemptId);
}
