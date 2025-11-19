package com.dungeon.heotaehoon.repository;

import com.dungeon.heotaehoon.entity.CustomizationItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CustomizationItemRepository extends JpaRepository<CustomizationItem, Long> {
    List<CustomizationItem> findByItemType(String itemType);
}
