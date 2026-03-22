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
         * Lấy tất cả thẻ đến hạn ôn tập (nextReviewAt <= now), chỉ tính card/deck/category còn active.
         */
        @Query("SELECT up FROM UserProgress up " +
            "WHERE up.user.id = :userId " +
            "AND up.nextReviewAt <= :dateTime " +
            "AND up.card.isRemoved = false " +
            "AND up.card.deck.isRemoved = false " +
            "AND up.card.deck.category.isRemoved = false")
        List<UserProgress> findByUserIdAndNextReviewAtBeforeAndCard_IsRemovedFalse(
            @Param("userId") String userId,
            @Param("dateTime") LocalDateTime dateTime);

        @Query("SELECT up FROM UserProgress up " +
            "WHERE up.user.id = :userId " +
            "AND up.nextReviewAt > :from " +
            "AND up.nextReviewAt <= :to " +
            "AND up.card.isRemoved = false " +
            "AND up.card.deck.isRemoved = false " +
            "AND up.card.deck.category.isRemoved = false " +
            "ORDER BY up.nextReviewAt ASC")
        List<UserProgress> findByUserIdAndNextReviewAtAfterAndNextReviewAtBeforeAndCard_IsRemovedFalseOrderByNextReviewAtAsc(
            @Param("userId") String userId,
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to
        );

    @Query("SELECT up.status, COUNT(up) FROM UserProgress up WHERE up.user.id = :userId GROUP BY up.status")
    List<Object[]> countByStatus(@Param("userId") String userId);

    @Query("SELECT up.status, COUNT(up) FROM UserProgress up " +
            "WHERE up.user.id = :userId " +
            "AND up.card.isRemoved = false " +
            "AND up.card.deck.isRemoved = false " +
            "AND up.card.deck.category.isRemoved = false " +
            "GROUP BY up.status")
    List<Object[]> countByStatusWithActiveCards(@Param("userId") String userId);

    @Query("SELECT COUNT(up) FROM UserProgress up " +
            "WHERE up.user.id = :userId " +
            "AND up.card.deck.id = :deckId " +
            "AND up.card.isRemoved = false " +
            "AND up.card.deck.isRemoved = false " +
            "AND up.card.deck.category.isRemoved = false " +
            "AND up.status <> com.vocaflipbackend.enums.LearningStatus.NEW")
    long countLearnedCardsByUserAndDeck(@Param("userId") String userId, @Param("deckId") String deckId);

    long countByUserIdAndStatus(String userId, LearningStatus status);
}
