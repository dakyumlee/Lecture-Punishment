package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.RaidParticipation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface RaidParticipationRepository extends JpaRepository<RaidParticipation, Long> {
    List<RaidParticipation> findByRaidId(Long raidId);
    Optional<RaidParticipation> findByRaidIdAndStudentId(Long raidId, String studentId);
    long countByRaidId(Long raidId);
}
