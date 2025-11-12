package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.WorksheetCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface WorksheetCategoryRepository extends JpaRepository<WorksheetCategory, String> {
    Optional<WorksheetCategory> findByName(String name);
}
