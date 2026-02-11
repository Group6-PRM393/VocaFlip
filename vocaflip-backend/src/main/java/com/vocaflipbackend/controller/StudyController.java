package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.response.StudySessionResponse;
import com.vocaflipbackend.service.StudyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controller quản lý các phiên học tập (Study Sessions)
 */
@RestController
@RequestMapping("/api/study")
@RequiredArgsConstructor
@Tag(name = "Study Sessions", description = "Quản lý phiên học tập và ghi nhận kết quả ôn tập")
public class StudyController {

    private final StudyService studyService;

    @Operation(summary = "Bắt đầu phiên học", 
               description = "Tạo một phiên học tập mới với bộ thẻ được chọn")
    @PostMapping("/start")
    public ResponseEntity<StudySessionResponse> startSession(
            @Parameter(description = "ID của người dùng") @RequestParam String userId, 
            @Parameter(description = "ID của Deck để học") @RequestParam String deckId) {
        return ResponseEntity.ok(studyService.startSession(userId, deckId));
    }

    @Operation(summary = "Ghi nhận kết quả ôn thẻ", 
               description = "Ghi lại kết quả ôn tập một thẻ trong phiên học")
    @PostMapping("/{sessionId}/submit")
    public ResponseEntity<Void> submitResult(
            @Parameter(description = "ID của phiên học") @PathVariable String sessionId, 
            @Parameter(description = "ID của thẻ đã ôn") @RequestParam String cardId,
            @Parameter(description = "Có nhớ được không") @RequestParam boolean isRemembered,
            @Parameter(description = "Thời gian phản hồi (giây)") @RequestParam int responseTimeSeconds) {
        studyService.submitCardResult(sessionId, cardId, isRemembered, responseTimeSeconds);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Hoàn thành phiên học", 
               description = "Kết thúc và lưu lại kết quả của phiên học")
    @PostMapping("/{sessionId}/complete")
    public ResponseEntity<StudySessionResponse> completeSession(
            @Parameter(description = "ID của phiên học") @PathVariable String sessionId) {
        return ResponseEntity.ok(studyService.completeSession(sessionId));
    }
}
