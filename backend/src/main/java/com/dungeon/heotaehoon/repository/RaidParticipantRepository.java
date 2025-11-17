package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.RaidParticipant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RaidParticipantRepository extends JpaRepository<RaidParticipant, String> {
    List<RaidParticipant> findByRaidSessionId(String raidSessionId);
    Optional<RaidParticipant> findByRaidSessionIdAndStudentId(String raidSessionId, String studentId);
}
