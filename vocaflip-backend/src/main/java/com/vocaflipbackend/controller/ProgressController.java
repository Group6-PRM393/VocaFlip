package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.LearningProgressStatsResponse;
import com.vocaflipbackend.service.ProgressService;
import com.vocaflipbackend.utils.SecurityUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/learning-progress")
@RequiredArgsConstructor
@Tag(name = "Learning Progress Controller", description = "Learning Progress statistics")
public class ProgressController {

    private final ProgressService progressService;

    @GetMapping("/me")
    @Operation(summary = "Lấy dữ liệu learning progress của user hiện tại")
    public ApiResponse<LearningProgressStatsResponse> getMyLearningProgressStats() {
        String userId = SecurityUtils.getCurrentUserId();
        return ApiResponse.<LearningProgressStatsResponse>builder()
                .code(1000)
                .result(progressService.getLearningProgressStats(userId))
                .message("Learning progress fetched successfully")
                .build();
    }


}