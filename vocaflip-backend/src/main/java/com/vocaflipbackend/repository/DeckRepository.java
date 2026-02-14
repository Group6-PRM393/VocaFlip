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
    Optional<Deck> findByIdAndIsRemovedFalse(String id);

    @Query("SELECT d FROM Deck d WHERE d.isRemoved = false " +
            "AND (LOWER(d.title) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
            "OR LOWER(d.description) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Deck> searchDecks(@Param("keyword") String keyword, Pageable pageable);


    Page<Deck> findByIsRemovedFalse(Pageable pageable);
}
