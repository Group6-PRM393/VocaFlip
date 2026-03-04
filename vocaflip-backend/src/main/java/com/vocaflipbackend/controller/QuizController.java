package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.request.QuizSubmissionRequest;
import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.QuizAttemptResponse;
import com.vocaflipbackend.dto.response.QuizReviewResponse;
import com.vocaflipbackend.dto.response.QuizSessionResponse;
import com.vocaflipbackend.service.QuizService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/quiz")
@RequiredArgsConstructor
@Tag(name = "Quiz Controller", description = "Quản lý tạo đề và nộp bài Quiz")
public class QuizController {

    private final QuizService quizService;

    @PostMapping("/generate")
    @Operation(summary = "Tạo đề thi mới", description = "Tạo ngẫu nhiên câu hỏi từ Deck, bao gồm cả đáp án nhiễu.")
    public ApiResponse<QuizSessionResponse> generateQuiz(
            @RequestParam String userId,
            @RequestParam String deckId,
            @RequestParam(defaultValue = "10") @Min(value = 1, message = "Minimum of number question is 1") int numberOfQuestions,
            @RequestParam(defaultValue = "300") @Min(value = 10, message = "Minimum of time is 10 seconds") int timeLimitSeconds
    ) {
        QuizSessionResponse response = quizService.generateQuiz(userId, deckId, numberOfQuestions, timeLimitSeconds);

        return ApiResponse.<QuizSessionResponse>builder()
                .code(1000)
                .result(response)
                .message("Quiz session created successfully")
                .build();
    }

    @PostMapping("/{attemptId}/submit")
    @Operation(summary = "Nộp bài và chấm điểm", description = "Gửi danh sách đáp án user chọn, server sẽ chấm điểm và trả về kết quả.")
    public ApiResponse<QuizAttemptResponse> submitQuiz(
            @PathVariable String attemptId,
            @RequestBody @Valid QuizSubmissionRequest request
    ) {
        QuizAttemptResponse response = quizService.submitQuizAndGrade(attemptId, request);

        return ApiResponse.<QuizAttemptResponse>builder()
                .code(1000)
                .result(response)
                .message("Quiz submitted successfully")
                .build();
    }

    @GetMapping("/{attemptId}/review")
    @Operation(summary = "Xem lại kết quả bài thi", description = "Lấy chi tiết danh sách câu hỏi, đáp án đã chọn và đáp án đúng của một lần làm bài.")
    public ApiResponse<QuizReviewResponse> getQuizReview(
            @PathVariable String attemptId
    ) {
        QuizReviewResponse response = quizService.getQuizReview(attemptId);

        return ApiResponse.<QuizReviewResponse>builder()
                .code(1000)
                .result(response)
                .message("Quiz review retrieved successfully")
                .build();
    }
}