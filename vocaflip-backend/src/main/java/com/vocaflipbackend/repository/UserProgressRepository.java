package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.UserProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserProgressRepository extends JpaRepository<UserProgress, String> {
    Optional<UserProgress> findByUserIdAndCardId(String userId, String cardId);

    /** Lấy tiến độ học của user cho danh sách thẻ */
    List<UserProgress> findByUserIdAndCardIdIn(String userId, List<String> cardIds);

    /** Lấy tất cả thẻ đến hạn ôn tập (nextReviewAt <= now) và chưa bị xóa */
    List<UserProgress> findByUserIdAndNextReviewAtBeforeAndCard_IsRemovedFalse(String userId, LocalDateTime dateTime);

    List<Object[]> countByStatus(String userId);
}
