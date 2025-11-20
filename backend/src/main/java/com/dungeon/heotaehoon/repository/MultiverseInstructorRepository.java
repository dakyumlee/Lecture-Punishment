package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.MultiverseInstructor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MultiverseInstructorRepository extends JpaRepository<MultiverseInstructor, String> {
    List<MultiverseInstructor> findByIsUnlockedTrue();
    Optional<MultiverseInstructor> findByUniverseType(String universeType);
}
