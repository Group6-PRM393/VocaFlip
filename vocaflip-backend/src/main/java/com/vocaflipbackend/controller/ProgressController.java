package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.response.UserProgressResponse;
import com.vocaflipbackend.enums.LearningStatus;
import com.vocaflipbackend.service.ProgressService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controller quản lý tiến độ học tập của người dùng
 */
@RestController
@RequestMapping("/api/progress")
@RequiredArgsConstructor
@Tag(name = "Progress", description = "Theo dõi và cập nhật tiến độ học thẻ của người dùng")
public class ProgressController {

    private final ProgressService progressService;

    @Operation(summary = "Cập nhật tiến độ học", 
               description = "Cập nhật trạng thái học tập của một thẻ cho người dùng")
    @PostMapping("/update")
    public ResponseEntity<Void> updateProgress(
            @Parameter(description = "ID của người dùng") @RequestParam String userId,
            @Parameter(description = "ID của thẻ") @RequestParam String cardId,
            @Parameter(description = "Trạng thái học tập (NEW, LEARNING, REVIEW, MASTERED)") 
            @RequestParam LearningStatus status) {
        progressService.updateProgress(userId, cardId, status);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Lấy tiến độ học thẻ", 
               description = "Trả về tiến độ học tập của một thẻ cụ thể cho người dùng")
    @GetMapping
    public ResponseEntity<UserProgressResponse> getProgress(
            @Parameter(description = "ID của người dùng") @RequestParam String userId,
            @Parameter(description = "ID của thẻ") @RequestParam String cardId) {
        return progressService.getProgress(userId, cardId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
