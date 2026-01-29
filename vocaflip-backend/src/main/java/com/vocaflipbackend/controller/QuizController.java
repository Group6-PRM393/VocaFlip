package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.QuizAttemptRequest;
import com.vocaflipbackend.dto.request.QuizRequest;
import com.vocaflipbackend.dto.response.QuizAttemptResponse;
import com.vocaflipbackend.dto.response.QuizResponse;
import com.vocaflipbackend.service.QuizService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/quizzes")
@RequiredArgsConstructor
public class QuizController {

    private final QuizService quizService;

    @PostMapping
    public ResponseEntity<QuizResponse> createQuiz(@Valid @RequestBody QuizRequest request, @RequestParam String deckId) {
        return ResponseEntity.ok(quizService.createQuiz(request, deckId));
    }

    @PostMapping("/{quizId}/start")
    public ResponseEntity<QuizAttemptResponse> startAttempt(@PathVariable String quizId, @RequestParam String userId) {
        return ResponseEntity.ok(quizService.startAttempt(userId, quizId));
    }

    @PostMapping("/attempt/{attemptId}/submit")
    public ResponseEntity<QuizAttemptResponse> submitAttempt(@PathVariable String attemptId, @RequestBody QuizAttemptRequest request) {
        return ResponseEntity.ok(quizService.submitAttempt(attemptId, request));
    }
}
