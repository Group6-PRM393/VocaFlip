package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.response.DashboardStatsResponse;
import com.vocaflipbackend.entity.StudySession;
import com.vocaflipbackend.repository.*;
import com.vocaflipbackend.service.ProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;

@Service
@RequiredArgsConstructor
public class ProgressServiceImpl implements ProgressService {

    private final UserProgressRepository progressRepository;
    private final StudySessionRepository sessionRepository;

    @Override
    public DashboardStatsResponse getDashboardStats(String userId) {
        // 1. Tính Word Mastery (Pie Chart)
        List<Object[]> statusCounts = progressRepository.countByStatus(userId);
        Map<String, Long> masteryMap = new HashMap<>();
        // Init default
        masteryMap.put("NEW", 0L);
        masteryMap.put("LEARNING", 0L);
        masteryMap.put("REVIEW", 0L);
        masteryMap.put("MASTERED", 0L);

        long totalWords = 0;
        for (Object[] row : statusCounts) {
            String status = row[0].toString();
            Long count = (Long) row[1];
            masteryMap.put(status, count);
            totalWords += count;
        }

        // 2. Lấy dữ liệu phiên học để tính Streak & Heatmap
        List<StudySession> sessions = sessionRepository.findAllByUserIdDesc(userId);

        int streak = calculateStreak(sessions);
        List<Map<String, Object>> activityLog = generateHeatmapData(sessions);

        // Tính tổng thời gian học (giả sử durationSeconds lưu trong StudySession)
        long totalSeconds = sessions.stream().mapToLong(StudySession::getDurationSeconds).sum();

        return DashboardStatsResponse.builder()
                .streakDays(streak)
                .totalWords((int) totalWords)
                .totalStudyTime(formatDuration(totalSeconds))
                .wordMastery(masteryMap)
                .activityLog(activityLog)
                .build();
    }

    private int calculateStreak(List<StudySession> sessions) {
        if (sessions.isEmpty()) return 0;

        // Dùng Set để loại bỏ trùng lặp ngày (vì 1 ngày có thể học nhiều lần)
        Set<LocalDate> studyDates = new HashSet<>();
        for (StudySession s : sessions) {
            studyDates.add(s.getCreatedAt().toLocalDate());
        }

        int streak = 0;
        LocalDate checkDate = LocalDate.now();

        // Check nếu hôm nay chưa học thì check từ hôm qua
        if (!studyDates.contains(checkDate)) {
            if (studyDates.contains(checkDate.minusDays(1))) {
                checkDate = checkDate.minusDays(1);
            } else {
                return 0; // Đứt chuỗi
            }
        }

        while (studyDates.contains(checkDate)) {
            streak++;
            checkDate = checkDate.minusDays(1);
        }
        return streak;
    }

    private List<Map<String, Object>> generateHeatmapData(List<StudySession> sessions) {
        Map<String, Integer> dateCounts = new HashMap<>();

        for (StudySession s : sessions) {
            String date = s.getCreatedAt().toLocalDate().toString();
            // Đếm số thẻ học được trong ngày làm chỉ số activity
            dateCounts.put(date, dateCounts.getOrDefault(date, 0) + s.getTotalCards());
        }

        List<Map<String, Object>> result = new ArrayList<>();
        dateCounts.forEach((date, count) -> {
            Map<String, Object> entry = new HashMap<>();
            entry.put("date", date);
            entry.put("count", count);
            // Level màu sắc (GitHub style): 0-4
            int level = count > 50 ? 4 : (count > 25 ? 3 : (count > 10 ? 2 : 1));
            entry.put("level", level);
            result.add(entry);
        });
        return result;
    }

    private String formatDuration(long totalSeconds) {
        long hours = totalSeconds / 3600;
        long minutes = (totalSeconds % 3600) / 60;
        if (hours > 0) return String.format("%dh %dm", hours, minutes);
        return String.format("%dm", minutes);
    }
}