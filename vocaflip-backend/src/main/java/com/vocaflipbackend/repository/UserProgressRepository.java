package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.UserProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserProgressRepository extends JpaRepository<UserProgress, String> {
    Optional<UserProgress> findByUserIdAndCardId(String userId, String cardId);

    List<Object[]> countByStatus(String userId);
}
