package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.QuizAttemptRequest;
import com.vocaflipbackend.dto.request.QuizRequest;
import com.vocaflipbackend.dto.response.QuizAttemptResponse;
import com.vocaflipbackend.dto.response.QuizResponse;
import com.vocaflipbackend.service.QuizService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controller quản lý Quiz (Bài kiểm tra) và các lần làm quiz
 */
@RestController
@RequestMapping("/api/quizzes")
@RequiredArgsConstructor
@Tag(name = "Quizzes", description = "Quản lý bài kiểm tra và ghi nhận kết quả làm bài")
public class QuizController {

    private final QuizService quizService;

    @Operation(summary = "Tạo Quiz mới", description = "Tạo một bài kiểm tra mới từ bộ thẻ")
    @PostMapping
    public ResponseEntity<QuizResponse> createQuiz(
            @Parameter(description = "Thông tin Quiz") @Valid @RequestBody QuizRequest request, 
            @Parameter(description = "ID của Deck để tạo Quiz") @RequestParam String deckId) {
        return ResponseEntity.ok(quizService.createQuiz(request, deckId));
    }

    @Operation(summary = "Bắt đầu làm Quiz", 
               description = "Tạo một phiên làm bài quiz mới cho người dùng")
    @PostMapping("/{quizId}/start")
    public ResponseEntity<QuizAttemptResponse> startAttempt(
            @Parameter(description = "ID của Quiz") @PathVariable String quizId, 
            @Parameter(description = "ID của người dùng") @RequestParam String userId) {
        return ResponseEntity.ok(quizService.startAttempt(userId, quizId));
    }

    @Operation(summary = "Nộp bài Quiz", description = "Nộp kết quả sau khi hoàn thành bài quiz")
    @PostMapping("/attempt/{attemptId}/submit")
    public ResponseEntity<QuizAttemptResponse> submitAttempt(
            @Parameter(description = "ID của phiên làm bài") @PathVariable String attemptId, 
            @Parameter(description = "Kết quả làm bài") @RequestBody QuizAttemptRequest request) {
        return ResponseEntity.ok(quizService.submitAttempt(attemptId, request));
    }
}
