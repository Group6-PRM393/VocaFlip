package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.StudySession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface StudySessionRepository extends JpaRepository<StudySession, String> {
    // Lấy tất cả phiên học của user sắp xếp theo ngày giảm dần để tính Streak
    @Query("SELECT s FROM StudySession s WHERE s.user.id = :userId ORDER BY s.createdAt DESC")
    List<StudySession> findAllByUserIdDesc(@Param("userId") String userId);

    // Tìm các phiên học bị bỏ dở (completed_at = null) và tạo trước thời điểm cutoff
    List<StudySession> findByCompletedAtIsNullAndCreatedAtBefore(LocalDateTime cutoff);
}