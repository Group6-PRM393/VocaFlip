package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuizRepository extends JpaRepository<Quiz, String> {
    List<Quiz> findByDeckId(String deckId);
}
