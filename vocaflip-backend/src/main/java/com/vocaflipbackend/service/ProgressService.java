package com.vocaflipbackend.service;

import com.vocaflipbackend.dto.response.DashboardStatsResponse;

public interface ProgressService {
    DashboardStatsResponse getDashboardStats(String userId);
}