package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.RaidSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RaidSessionRepository extends JpaRepository<RaidSession, String> {
    List<RaidSession> findBySessionStatusIn(List<String> statuses);
    Optional<RaidSession> findByIdAndSessionStatus(String id, String status);
}
