package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.Deck;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DeckRepository extends JpaRepository<Deck, String> {

    List<Deck> findByUserIdAndIsRemovedFalse(String userId);

    List<Deck> findByUserIdAndCategoryIdAndIsRemovedFalse(String userId, String categoryId);

    Optional<Deck> findByIdAndIsRemovedFalse(String id);

    @Query("SELECT d FROM Deck d WHERE d.isRemoved = false " +
            "AND d.user.id = :userId " +
            "AND (LOWER(d.title) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
            "OR LOWER(d.description) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Deck> searchDecks(@Param("keyword") String keyword, @Param("userId") String userId, Pageable pageable);

    Page<Deck> findByUserIdAndIsRemovedFalse(String userId, Pageable pageable);

    @Query(value = "select d.* " +
            "from decks d " +
            "where d.user_id = :userId " +
            "and d.is_removed = false " +
            "and (select count(*) from cards c " +
            "     where c.deck_id = d.id " +
            "       and c.is_removed = false " +
            "       and c.front is not null and c.back is not null) >= :minCards " +
            "order by d.updated_at desc nulls last, d.created_at desc nulls last", nativeQuery = true)
    List<Deck> findEligibleDecksByUserId(@Param("userId") String userId, @Param("minCards") int minCards);
}
