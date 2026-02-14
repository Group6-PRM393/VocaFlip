package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.StudySessionResponse;
import com.vocaflipbackend.service.StudyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/study")
@RequiredArgsConstructor
@Tag(name = "Study Sessions", description = "Quản lý phiên học tập và ghi nhận kết quả ôn tập")
public class StudyController {

    private final StudyService studyService;

    @Operation(summary = "Bắt đầu phiên học",
               description = "Tạo phiên học mới và trả về danh sách tất cả thẻ trong Deck")
    @PostMapping("/start")
    public ApiResponse<StudySessionResponse> startSession(
            @Parameter(description = "ID của người dùng") @RequestParam String userId,
            @Parameter(description = "ID của Deck để học") @RequestParam String deckId) {
        return ApiResponse.<StudySessionResponse>builder()
                .message("Phiên học đã được tạo thành công")
                .result(studyService.startSession(userId, deckId))
                .build();
    }

    @Operation(summary = "Ôn tập hàng ngày",
               description = "Tổng hợp tất cả thẻ đến hạn ôn tập (từ mọi Deck) và tạo phiên học mới")
    @PostMapping("/daily-review")
    public ApiResponse<StudySessionResponse> startDailyReview(
            @Parameter(description = "ID của người dùng") @RequestParam String userId) {
        return ApiResponse.<StudySessionResponse>builder()
                .message("Phiên ôn tập hàng ngày đã được tạo")
                .result(studyService.startDailyReview(userId))
                .build();
    }

    @Operation(summary = "Ghi nhận kết quả ôn thẻ",
               description = "Ghi lại kết quả ôn tập một thẻ trong phiên học. Grade: 0=Forgot, 1=Hard, 2=Good, 3=Easy")
    @PostMapping("/{sessionId}/submit")
    public ApiResponse<Void> submitResult(
            @Parameter(description = "ID của phiên học") @PathVariable String sessionId,
            @Parameter(description = "ID của thẻ đã ôn") @RequestParam String cardId,
            @Parameter(description = "Mức độ nhớ (0-3)") @RequestParam int grade,
            @Parameter(description = "Thời gian phản hồi (giây)") @RequestParam int responseTimeSeconds) {
        studyService.submitCardResult(sessionId, cardId, grade, responseTimeSeconds);
        return ApiResponse.<Void>builder()
                .message("Kết quả đã được ghi nhận")
                .build();
    }

    @Operation(summary = "Hoàn thành phiên học",
               description = "Kết thúc và lưu lại kết quả của phiên học")
    @PostMapping("/{sessionId}/complete")
    public ApiResponse<StudySessionResponse> completeSession(
            @Parameter(description = "ID của phiên học") @PathVariable String sessionId) {
        return ApiResponse.<StudySessionResponse>builder()
                .message("Phiên học đã hoàn thành")
                .result(studyService.completeSession(sessionId))
                .build();
    }
}


