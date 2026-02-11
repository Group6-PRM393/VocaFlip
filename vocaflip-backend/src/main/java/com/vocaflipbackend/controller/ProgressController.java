package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.DashboardStatsResponse;
import com.vocaflipbackend.service.ProgressService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/stats")
@RequiredArgsConstructor
@Tag(name = "Progress Controller", description = "Thống kê Dashboard")
public class ProgressController {

    private final ProgressService progressService;

    @GetMapping("/dashboard")
    @Operation(summary = "Lấy dữ liệu thống kê Dashboard (Streak, Heatmap, Mastery)")
    public ApiResponse<DashboardStatsResponse> getDashboardStats(
            @RequestParam String userId
    ) {
        return ApiResponse.<DashboardStatsResponse>builder()
                .code(1000)
                .result(progressService.getDashboardStats(userId))
                .message("Stats fetched successfully")
                .build();
    }
}