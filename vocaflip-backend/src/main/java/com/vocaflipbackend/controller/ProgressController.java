package com.vocaflipbackend.controller;

import com.vocaflipbackend.dto.response.ApiResponse;
import com.vocaflipbackend.dto.response.DashboardStatsResponse;
import com.vocaflipbackend.service.ProgressService;
import com.vocaflipbackend.utils.SecurityUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

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

    @GetMapping("/dashboard/me")
    @Operation(summary = "Lấy dữ liệu thống kê Dashboard của user hiện tại")
    public ApiResponse<DashboardStatsResponse> getMyDashboardStats() {
        String userId = SecurityUtils.getCurrentUserId();
        return ApiResponse.<DashboardStatsResponse>builder()
                .code(1000)
                .result(progressService.getDashboardStats(userId))
                .message("Stats fetched successfully")
                .build();
    }
}