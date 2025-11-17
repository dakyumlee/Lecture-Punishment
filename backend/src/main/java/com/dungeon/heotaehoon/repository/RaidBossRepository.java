package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.RaidBoss;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RaidBossRepository extends JpaRepository<RaidBoss, String> {
    List<RaidBoss> findByIsActiveTrueAndIsDefeatedFalse();
}
