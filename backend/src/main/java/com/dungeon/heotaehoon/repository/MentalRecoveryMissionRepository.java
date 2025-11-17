package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.MentalRecoveryMission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MentalRecoveryMissionRepository extends JpaRepository<MentalRecoveryMission, String> {
    List<MentalRecoveryMission> findByMissionTypeAndIsActiveTrue(String missionType);
    List<MentalRecoveryMission> findByIsActiveTrue();
}
