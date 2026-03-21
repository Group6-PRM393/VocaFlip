package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.QuizAttempt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuizAttemptRepository extends JpaRepository<QuizAttempt, String> {
    List<QuizAttempt> findByUserId(String userId);

    long countByUserId(String userId);

    @Query("SELECT COALESCE(SUM(qa.totalQuestions), 0) FROM QuizAttempt qa WHERE qa.user.id = :userId AND qa.completedAt IS NOT NULL")
    long sumTotalQuestionsByUserId(@Param("userId") String userId);

    @Query("SELECT COALESCE(SUM(qa.correctAnswers), 0) FROM QuizAttempt qa WHERE qa.user.id = :userId AND qa.completedAt IS NOT NULL")
    long sumCorrectAnswersByUserId(@Param("userId") String userId);
}
