package com.vocaflipbackend.repository;

import com.vocaflipbackend.entity.SessionCard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface SessionCardRepository extends JpaRepository<SessionCard, String> {
	@Query("SELECT COUNT(sc) FROM SessionCard sc WHERE sc.session.user.id = :userId")
	long countAllByUserId(@Param("userId") String userId);

	@Query("SELECT COUNT(sc) FROM SessionCard sc WHERE sc.session.user.id = :userId AND sc.isRemembered = true")
	long countRememberedByUserId(@Param("userId") String userId);
}
