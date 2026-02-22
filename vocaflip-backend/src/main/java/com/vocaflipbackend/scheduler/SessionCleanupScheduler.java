package com.vocaflipbackend.scheduler;

import com.vocaflipbackend.service.StudyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Scheduler tự động dọn dẹp các phiên học bị bỏ dở.
 *
 * Chạy lúc 3h sáng mỗi ngày, tìm các session có completed_at = null
 * và tạo trước 2 giờ → tự động gán completed_at.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class SessionCleanupScheduler {

    private final StudyService studyService;

    /**
     * Cron expression: "0 0 3 * * *" = 3h sáng mỗi ngày.
     * Dọn các phiên học bị bỏ dở quá 2 giờ.
     */
    @Scheduled(cron = "0 0 3 * * *")
    public void cleanupAbandonedSessions() {
        log.info("[Session Cleanup] Starting to scan abandoned sessions...");
        int cleaned = studyService.cleanupAbandonedSessions();
        log.info("[Session Cleanup] Automatically completed {} abandoned sessions.", cleaned);
    }
}
