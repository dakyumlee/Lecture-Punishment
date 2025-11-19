package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Raid;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface RaidRepository extends JpaRepository<Raid, Long> {
    List<Raid> findByStatusOrderByCreatedAtDesc(String status);
    Optional<Raid> findFirstByStatusOrderByCreatedAtDesc(String status);
}
