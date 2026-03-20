package com.vocaflipbackend.service.impl;

import com.vocaflipbackend.dto.response.LearningProgressStatsResponse;
import com.vocaflipbackend.dto.response.LearningTrajectoryPointResponse;
import com.vocaflipbackend.dto.response.LearningTrajectoryResponse;
import com.vocaflipbackend.entity.StudySession;
import com.vocaflipbackend.repository.QuizAttemptRepository;
import com.vocaflipbackend.repository.StudySessionRepository;
import com.vocaflipbackend.repository.UserProgressRepository;
import com.vocaflipbackend.service.ProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProgressServiceImpl implements ProgressService {

    private final UserProgressRepository progressRepository;
    private final StudySessionRepository sessionRepository;
    private final QuizAttemptRepository quizAttemptRepository;

    @Override
    public LearningProgressStatsResponse getLearningProgressStats(String userId) {
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

        // 2. Lấy dữ liệu phiên học để tính Streak & Learning Trajectory
        List<StudySession> sessions = sessionRepository.findAllByUserIdDesc(userId);

        int streak = calculateStreak(sessions);

        // Tính tổng thời gian học (giả sử durationSeconds lưu trong StudySession)
        long totalSeconds = sessions.stream().mapToLong(StudySession::getDurationSeconds).sum();
        double accuracyPercent = calculateQuizAccuracy(userId);
        LearningTrajectoryResponse trajectory = buildLearningTrajectory(sessions);

        return LearningProgressStatsResponse.builder()
                .streakDays(streak)
                .totalWords((int) totalWords)
                .totalStudyTime(formatDuration(totalSeconds))
                .accuracyPercent(accuracyPercent)
                .wordMastery(masteryMap)
                .learningTrajectory(trajectory)
                .build();
    }


    private double calculateQuizAccuracy(String userId) {
        long totalQuestions = quizAttemptRepository.sumTotalQuestionsByUserId(userId);
        long totalCorrectAnswers = quizAttemptRepository.sumCorrectAnswersByUserId(userId);

        double accuracyPercent = 0.0;
        if (totalQuestions > 0) {
            accuracyPercent = (totalCorrectAnswers * 100.0) / totalQuestions;
            accuracyPercent = Math.round(accuracyPercent * 10.0) / 10.0;
        }

       return accuracyPercent;
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

    private LearningTrajectoryResponse buildLearningTrajectory(List<StudySession> sessions) {
        YearMonth currentMonth = YearMonth.now();
        YearMonth previousMonth = currentMonth.minusMonths(1);

        int currentMonthLearnedWords = 0;
        int previousMonthLearnedWords = 0;

        Map<LocalDate, Integer> dailySeriesMap = new HashMap<>();

        for (StudySession session : sessions) {
            LocalDate date = session.getCreatedAt().toLocalDate();
            int value = session.getTotalCards() != null ? session.getTotalCards() : 0;

            YearMonth ym = YearMonth.from(date);
            if (ym.equals(currentMonth)) {
                currentMonthLearnedWords += value;
            } else if (ym.equals(previousMonth)) {
                previousMonthLearnedWords += value;
            }

            dailySeriesMap.put(date, dailySeriesMap.getOrDefault(date, 0) + value);
        }

        List<LearningTrajectoryPointResponse> series = dailySeriesMap.entrySet()
                .stream()
                .sorted(Map.Entry.comparingByKey())
                .map(entry -> LearningTrajectoryPointResponse.builder()
                        .date(entry.getKey().toString())
                        .value(entry.getValue())
                        .build())
                .collect(Collectors.toList());

        double trendPercent;
        if (previousMonthLearnedWords == 0) {
            trendPercent = currentMonthLearnedWords > 0 ? 100.0 : 0.0;
        } else {
            trendPercent = ((currentMonthLearnedWords - previousMonthLearnedWords) * 100.0)
                    / previousMonthLearnedWords;
        }

        trendPercent = Math.round(trendPercent * 10.0) / 10.0;

        return LearningTrajectoryResponse.builder()
                .currentMonthLearnedWords(currentMonthLearnedWords)
                .previousMonthLearnedWords(previousMonthLearnedWords)
                .trendPercent(trendPercent)
                .series(series)
                .build();
    }

    private String formatDuration(long totalSeconds) {
        long hours = totalSeconds / 3600;
        long minutes = (totalSeconds % 3600) / 60;
        if (hours > 0) return String.format("%dh %dm", hours, minutes);
        return String.format("%dm", minutes);
    }
}