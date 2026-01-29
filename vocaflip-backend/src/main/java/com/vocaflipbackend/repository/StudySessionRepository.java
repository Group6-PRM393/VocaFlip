package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.StudySession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StudySessionRepository extends JpaRepository<StudySession, String> {
    List<StudySession> findByUserId(String userId);
}
