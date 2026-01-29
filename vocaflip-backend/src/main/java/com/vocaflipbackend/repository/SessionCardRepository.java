package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.SessionCard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SessionCardRepository extends JpaRepository<SessionCard, String> {
}
