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

    @Query(value = "select * from cards where deck_id = :deckId and is_removed = false order by rand() limit :limit", nativeQuery = true)
    List<Card> findRandomCardsByDeckId(@Param("deckId") String deckId, @Param("limit") int limit);

    @Query(value = "select * fromt cards where deck_id = :deckId and id != :correctCardId and is_removed = false order by rand() limit 3", nativeQuery = true)
    List<Card> findDistractors(@Param("deckId") String deckId, @Param("correctCardId") String correctCardId);

}
