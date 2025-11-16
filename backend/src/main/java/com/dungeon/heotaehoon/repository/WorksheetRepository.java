package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.Worksheet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorksheetRepository extends JpaRepository<Worksheet, String> {
    List<Worksheet> findByGroupId(String groupId);
    List<Worksheet> findByCategory(String category);
}
