package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.Card;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CardRepository extends JpaRepository<Card, String> {
    List<Card> findByDeckIdAndIsRemovedFalse(String deckId);

            @Query(value = "select c.* " +
                "from cards c " +
                "join decks d on c.deck_id = d.id " +
                "where d.user_id = :userId " +
                "and c.is_removed = false " +
                "and d.is_removed = false " +
                "and c.front is not null " +
                "and c.back is not null " +
                "order by random() " +
                "limit :limit", nativeQuery = true)
            List<Card> findRandomCardsByUserId(@Param("userId") String userId, @Param("limit") int limit);

    @Query(value = "select * from cards where deck_id = :deckId and is_removed = false order by random() limit :limit", nativeQuery = true)
    List<Card> findRandomCardsByDeckId(@Param("deckId") String deckId, @Param("limit") int limit);

    @Query(value = "select * from cards where deck_id = :deckId and id != :correctCardId and is_removed = false order by random() limit 3", nativeQuery = true)
    List<Card> findDistractors(@Param("deckId") String deckId, @Param("correctCardId") String correctCardId);
}