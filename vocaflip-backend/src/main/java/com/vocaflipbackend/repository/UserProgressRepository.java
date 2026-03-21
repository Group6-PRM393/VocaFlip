package com.vocaflipbackend.repository;

import com.vocaflipbackend.enums.LearningStatus;
import com.vocaflipbackend.entity.UserProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserProgressRepository extends JpaRepository<UserProgress, String> {
    Optional<UserProgress> findByUserIdAndCardId(String userId, String cardId);

    /**
     * Lấy tiến độ học của user cho danh sách thẻ
     */
    List<UserProgress> findByUserIdAndCardIdIn(String userId, List<String> cardIds);

    /**
     * Lấy tất cả thẻ đến hạn ôn tập (nextReviewAt <= now) và chưa bị xóa
     */
    List<UserProgress> findByUserIdAndNextReviewAtBeforeAndCard_IsRemovedFalse(String userId, LocalDateTime dateTime);

        List<UserProgress> findByUserIdAndNextReviewAtAfterAndNextReviewAtBeforeAndCard_IsRemovedFalseOrderByNextReviewAtAsc(
            String userId,
            LocalDateTime from,
            LocalDateTime to
        );

    @Query("SELECT up.status, COUNT(up) FROM UserProgress up WHERE up.user.id = :userId GROUP BY up.status")
    List<Object[]> countByStatus(@Param("userId") String userId);

        @Query("SELECT up.status, COUNT(up) FROM UserProgress up " +
            "WHERE up.user.id = :userId AND up.card.isRemoved = false GROUP BY up.status")
        List<Object[]> countByStatusWithActiveCards(@Param("userId") String userId);

    @Query("SELECT COUNT(up) FROM UserProgress up " +
            "WHERE up.user.id = :userId " +
            "AND up.card.deck.id = :deckId " +
            "AND up.card.isRemoved = false " +
            "AND up.status <> com.vocaflipbackend.enums.LearningStatus.NEW")
    long countLearnedCardsByUserAndDeck(@Param("userId") String userId, @Param("deckId") String deckId);

    long countByUserIdAndStatus(String userId, LearningStatus status);
}
