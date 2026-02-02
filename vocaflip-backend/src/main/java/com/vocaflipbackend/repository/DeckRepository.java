package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.Deck;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DeckRepository extends JpaRepository<Deck, String> {

    List<Deck> findByUserIdAndIsRemovedFalse(String userId);

     // Optional: if generic findById needed with soft delete check, need custom implementation or use service logic
}
